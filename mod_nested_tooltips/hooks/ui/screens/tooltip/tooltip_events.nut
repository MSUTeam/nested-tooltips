::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_querySkillNestedTooltipData <- function( _entityId, _skillId, _filename )
	{
		if (_skillId == null) _skillId = ::MSU.NestedTooltips.SkillObjectsByFilename[_filename].getID();
		local entity = _entityId != null ? ::Tactical.getEntityByID(_entityId) : null;
		local skill;
		if (entity != null)
		{
			skill = entity.getSkills().getSkillByID(_skillId);
		}

		if (skill == null)
		{
			skill = ::MSU.NestedTooltips.SkillObjectsByFilename[_filename];
			skill.m.Container = ::MSU.getDummyPlayer().getSkills();
			local ret = skill.getNestedTooltip();
			skill.m.Container = null;
			return ret;
		}

		return skill.getNestedTooltip();
	}

	q.general_queryItemNestedTooltipData <- function( _entityId, _itemId, _itemOwner, _filename )
	{
		local item;

		if (_itemId != null)
		{
			local entity = _entityId != null ? ::Tactical.getEntityByID(_entityId) : null;
			switch (_itemOwner)
			{
				case "entity":
					if (entity != null) item = entity.getItems().getItemByInstanceID(_itemId);
					break;

				case "ground":
				case "character-screen-inventory-list-module.ground":
					if (entity != null) item = ::TooltipEvents.tactical_helper_findGroundItem(entity, _itemId);
					break;

				case "stash":
				case "character-screen-inventory-list-module.stash":
					local result = ::Stash.getItemByInstanceID(_itemId);
					if (result != null) item = result.item;
					break;

				case "craft":
					return ::World.Crafting.getBlueprint(_itemId).getTooltip();

				case "blueprint":
					return ::World.Crafting.getBlueprint(_entityId).getTooltipForComponent(_itemId);

				case "world-town-screen-shop-dialog-module.stash":
					local result = ::Stash.getItemByInstanceID(_itemId);
					if (result != null) item = result.item;
					break;

				case "world-town-screen-shop-dialog-module.shop":
					local stash = ::World.State.getTownScreen().getShopDialogModule().getShop().getStash();
					if (stash != null)
					{
						local result = stash.getItemByInstanceID(_itemId);
						if (result != null) item = result.item;
					}
					break;

				case "tactical-combat-result-screen.stash":
					local result = ::Stash.getItemByInstanceID(_itemId);
					if (result != null) item = result.item;
					break;

				case "tactical-combat-result-screen.found-loot":
					local result = ::Tactical.CombatResultLoot.getItemByInstanceID(_itemId);
					if (result != null) item = result.item;
					break;
			}
		}
		else
		{
			item = ::MSU.NestedTooltips.ItemObjectsByFilename[_filename];
		}

		return item.getNestedTooltip();
	}
});
