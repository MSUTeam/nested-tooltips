# Nested Tooltips Framework - notes

Shared notes and skills: the `bb-agents` repo next to this one (`<workspace>\bb-agents`).

Last review: 2026-11-05, `development` at a732552 (v0.5.4). Fixes are on branch `fix-review-findings`; open items at the end.

## Layout
- `msu/` extends MSU classes in place (to be merged into MSU later); paths mirror MSU's:
  - `msu/systems/tooltips/~nested_tooltips/`: TooltipsSystem and TooltipsModAddon additions (`parseString`, ...).
  - `msu/msu_mod/~nested_tooltips/`: tooltip types, settings, keybind, `::MSU.NestedTooltips`.
  - `msu/utils/~nested_tooltips/`: the dummy player and `regexReplace`.
- `mod_nested_tooltips/hooks/`: vanilla hooks, included via `::IO.enumerateFiles` in `scripts/!mods_preload/mod_nested_tooltips.nut`.
- `ui/mods/msu/nested_tooltips.js` is the whole JS side: `MSU.NestedTooltip` (TooltipStack, Events, TileTooltipDiv, BBCode parsing) and overrides of vanilla `TooltipModule`, `$.fn.bindTooltip/unbindTooltip/updateTooltip` and `XBBCODE.process`. `ui/mods/nested_tooltips/js_hooks/` is registered automatically, one file per vanilla screen hook.
- The settings `showDelay`, `hideDelay`, `graceDelay`, `lockDelay` and `NestedTooltips_*` text styles belong to MSU's mod (`MSU.ID`), page "Nested Tooltips".

## Tooltip syntax (Squirrel `Mod.Tooltips.parseString`)
- `[link text|TooltipID]`: `TooltipID` is a key in the calling mod's `Mod.Tooltips.setTooltips` table, falling back to MSU's. Anything after `+` is extra data (`_data.ExtraData`).
- Built-in IDs (`msu_tooltips.nut`): `Perk+<perk filename>`, `Skill+<skill filename>`, `Item+<item filename>`, `Entity+<id>`, `WorldEntity+<id>`, `CharacterStats+<stat>`, `Obj+<parseObject(obj) key>` (optional `func:<name>` replaces `getTooltip`), `Tooltip+<parseTooltip(array)>`.
- Extra data is `filename,key:value,...` (`parseExtraDataForNestedTooltip`); keys `entityId` (`default` = the root tooltip's), `itemId`, `itemOwner`, `func`, `contentType`, `cssClass`. Values can't contain `,` or `:`.
- Filenames are script filenames without path (`Skill+rotation`); on a collision the later script needs a partial path (`actives/rotation`). Collisions are logged at preload; none in vanilla, Reforged or Legends.
- `Img/` at the start of the link text makes an image link: `[Img/gfx/ui/icons/x.png|Perk+perk_x]`.
- `$ $` in the link text inserts the object's `Name`, `$Field.func()$` a field with calls. Only `Perk`, `Skill`, `Item` (or a mod's `generateNestedTextFromObjCallback`); fields other than `Perk` throw before the first world init.
- Tags and identifiers are encoded as 3-digit byte numbers (safe from `toupper()` etc.); JS decodes them as UTF-8 in `parseEncodedText`. Link text stays plain.
- `removeAllFromString` strips links to their text; `getArticle`/`getArticleCapitalized` use it.
- `parseObject(obj)` keys are `obj + ""` (`(table : 0x...)`), stored as weakrefs in `ParsedObjects`.
- The overwritten `getTooltip(modID, id)` returns `{ Tooltip, Data }`, not MSU's tooltip object; mods call `getTooltip(...).Tooltip`. Restoring MSU's return value (with a `getTooltipAndData` for the table, `d656535`) was reverted for 0.5.5 to stay compatible with the current Reforged release. It comes back in a later breaking release together with Reforged's `fix-nested-tooltips-get-tooltip` branch.

## Dummy player and cached objects
- `::MSU.getDummyPlayer()` lazily creates a `player` in roster `NestedTooltipsRoster` (hasPerk/hasSprite/getTile/onAppearanceChanged overridden), only after the first world init and while a world state exists. In the main menu it returns null.
- `world_state` init, loadCampaign, saveCampaign and onFinish destroy the dummy (the roster must not end up in saves). `ParsedObjects` is cleared on init, load and onFinish, not on save.
- Skill and item tooltips without a real owner use objects cached once per session (`SkillObjectsByFilename`, `ItemObjectsByFilename`). Never leave state on them (`m.Container`, a fake item).
- Skill tooltips of a real item: clone it if equipped, equip it on the dummy, read the tooltip, restore the dummy's items. All through `skill.__MSU_getNestedTooltipSafe`, which falls back to the base tooltip on errors.
- `item_container` hooks: `unequip` delegates bag items to `removeFromBag`, which calls MSU's `skills.onUnequip` and the NPC `update`. The ammo `onEquip` hook keeps the ammo count on the dummy (vanilla randomizes it for non-players).

## JS behavior
- Containers are `div.tooltip-module.ui-control-tooltip-module.msu-nested-tooltip`; select them with `.msu-nested-tooltip` (vanilla's container has `.ui-control-tooltip-module` too).
- Nested links (`.msu-nested-tooltip-source`) are bound lazily on mouseenter and not rebound or unbound while their tooltip is open (it has `msu-nested` data).
- A tooltip locks after `lockDelay`; only locked tooltips can be entered. Left click closes the top tooltip, right click all. Leaving a source starts the HIDE timer (GRACE while locked). While locked, a leave doesn't restart a pending HIDE timer: vanilla's tile hover leaves the tile div on every tile change, which kept a locked tile tooltip open as long as the mouse moved. Timers reset to null when they fire (`isTimerPending`). `updateStack` then pops every tooltip whose source and tooltip are both unhovered (by mouse position).
- Tile tooltips use `TileTooltipDiv`, an invisible round div (100/zoom px) on `body` under the cursor, as their source. Vanilla's tile hover calls `mouseEnterTile`/`mouseHoverTile` → `showTileTooltip` whenever the mouse moves over the map, also between a source and its tooltip:
  - `showTileTooltip` returns while `TooltipStack.isLocked()`, so the GRACE timer decides; its `updateStack()` would close the locked tooltip at once. (Until 6190101 this only worked by accident: the old class check in `hasTooltipSourceBeneathCursor` matched any 18-character `className`, e.g. `l-skills-container`.)
  - A locked tile tooltip keeps the div expanded over nearby sources (e.g. Reforged's overlay labels). `onTileDivMouseMove` finds a covered `.msu-tooltip-source` by bounding rects and hands the mouse over (clear the stack, shrink and unbind the div, trigger `mouseenter`). Never hide the hovered div to look beneath it: the hover change lets the tile path close locked tooltips without grace.
- Pass-through data copies the root tooltip's params (entityId, ...) into nested queries, except `contentType`, `elementId`, `isTileTooltip`.
- Icons with an image link are swapped for a placeholder png with the link after `#` in `src`, replaced after vanilla builds the tooltip (read with `getAttribute("src")`). The png exists under `gfx/mods/mod_nested_tooltips/` and `gfx/ui/items/mods/mod_nested_tooltips/` (entries with `useItemPath` use `Path.ITEMS`).

## Tests and in-game checks
`tests/tooltip_mouse.nut` (tactical, moves the real mouse; don't touch it meanwhile): a locked skill tooltip survives moving up onto it across the map, a locked tile tooltip closes while the mouse keeps moving, leaving onto the map respects `graceDelay`, a tile tooltip shows afterwards. Manual checks after UI changes:
- Lock a tooltip, open a nested link, move back onto that link: no flicker or lock restart. A nested link in a tile tooltip: closing it keeps the tile tooltip.
- Left/right click closing, dimming of non-hovered tooltips, world event screen titles, the perk unlock popup.
- Skill tooltips from bagged items (NPC and player), Reforged concept links with `$ $`, Reforged tile item icons (`Obj+` image links), a Reforged overlay label next to a locked tile tooltip.

## Open items
- Escaping: `getTooltipLinkHTML`/`getTooltipImageHTML` don't escape `"`/`&` in attributes; `parseTooltip` doesn't escape `"`, `\` or newlines before `compilestring`; `Tooltip+<...>` can't contain `[`/`]`.
- `Debug.enable()` is on in the release preload.
- Perk nested tooltips throw in the main menu (no dummy player).
- While the mouse keeps moving over the map, a stale tile tooltip query can create a tooltip after the div was re-bound; the next movement removes it and the shrink cancels the pending SHOW, so no tile tooltip shows until the mouse moves again.
- Possibly: tooltips not closing when their source element is destroyed. The 2023 `$.cleanData` listener for that was dropped in 0ca3719 (2025) and the dead hook removed on `fix-review-findings`; removed elements get no `mouseleave`.
