::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_querySkillNestedTooltipData <- function( _data )
	{
		local function getNestedTooltip_safe( _skill )
		{
			try
			{
				local ret = _skill.getNestedTooltip();
				_skill.getContainer().onQueryTooltip(_skill, ret); // Manually run MSU event
				return ret;
			}
			catch (error)
			{
				::NestedTooltips.Mod.Debug.printWarning(format("Could not fetch nested tooltip for skill %s, so returning base skill tooltip. Error: %s", _skill.getID(), error));
				return _skill.isActive() ? _skill.skill.getDefaultUtilityTooltip() : _skill.skill.getTooltip();
			}
		}

		local entityId = "entityId" in _data ? _data.entityId : null;
		local itemId = "itemId" in _data ? _data.itemId : null;
		local scriptPath = ::IO.scriptFilenameByHash(::MSU.System.Tooltips.getObjFromFilename(_data.filename, ::MSU.NestedTooltips.SkillObjectsByFilename).ClassNameHash);
		local className = split(_data.filename, "/").top();

		local entity = entityId != null ? ::Tactical.getEntityByID(entityId) : null;
		local skill;
		if (entity != null)
		{
			foreach (s in entity.getSkills().m.Skills)
			{
				if (s.ClassName == className && !s.isGarbage() && !s.isHidden() && ::IO.scriptFilenameByHash(s.ClassNameHash) == scriptPath)
				{
					skill = s;
					break;
				}
			}
		}

		if (skill != null)
			return getNestedTooltip_safe(skill);

		local ret;

		local item;
		if (itemId != null)
		{
			item = this.getItemByItemOwner(entityId, itemId, "itemOwner" in _data ? _data.itemOwner : null);
		}

		if (!::MSU.isNull(item))
		{
			local dummyContainer = ::MSU.getDummyPlayer().getItems();
			local existingItem = dummyContainer.getItemAtSlot(item.getSlotType());

			local isDummyEquipping = ::MSU.isNull(item.getContainer());
			if (isDummyEquipping)
			{
				dummyContainer.unequip(existingItem);
				dummyContainer.equip(item);
			}

			foreach (s in item.getSkills())
			{
				if (::IO.scriptFilenameByHash(s.ClassNameHash) == scriptPath)
				{
					ret = getNestedTooltip_safe(s)
					break;
				}
			}

			if (isDummyEquipping)
			{
				dummyContainer.unequip(item);
				if (existingItem != null)
				{
					dummyContainer.equip(existingItem);
				}
			}
		}

		if (ret == null)
		{
			skill = ::new(scriptPath);
			skill.m.Container = ::MSU.getDummyPlayer().getSkills();
			skill.m.Item = item;
			ret = getNestedTooltip_safe(skill);
			skill.m.Container = null;
			skill.m.Item = null;
		}

		return ret;
	}

	q.general_queryItemNestedTooltipData <- function( _data )
	{
		local item;

		local itemId = "itemId" in _data ? _data.itemId : null;
		if (itemId != null)
		{
			item = this.getItemByItemOwner("entityId" in _data ? _data.entityId : null, itemId, "itemOwner" in _data ? _data.itemOwner : null);
		}
		else
		{
			item = ::MSU.System.Tooltips.getObjFromFilename(_data.filename, ::MSU.NestedTooltips.ItemObjectsByFilename);
		}

		return item.getNestedTooltip();
	}

	q.onQueryMSUTooltipData = @() function( _data )
	{
		local ret = ::MSU.System.Tooltips.getTooltip(_data.modId, _data.elementId);
		_data.ExtraData <- ret.Data;
		return ret.Tooltip.getUIData(_data);
	}

	q.getItemByItemOwner <- function( _entityId, _itemId, _itemOwner )
	{
		local item;
		local entity = _entityId != null ? ::Tactical.getEntityByID(_entityId) : null;

		switch (_itemOwner)
		{
			case null:
				if (entity != null)
				{
					item = this.getItemByItemOwner(_entityId, _itemId, "entity");
					if (item == null && entity.isPlacedOnMap())
					{
						item = this.getItemByItemOwner(_entityId, _itemId, "ground");
					}
				}
				if (item == null)
				{
					item = this.getItemByItemOwner(_entityId, _itemId, "stash");
				}
				if (item == null)
				{
					if (::World.Crafting.getBlueprint(_itemId) != null)
					{
						item = this.getItemByItemOwner(_entityId, _itemId, "craft");
						if (item == null)
						{
							item = this.getItemByItemOwner(_entityId, _itemId, "blueprint");
						}
					}
				}
				if (item == null)
				{
					if (::World.State.getTownScreen() != null && ::World.State.getTownScreen().getShopDialogModule() != null && ::World.State.getTownScreen().getShopDialogModule().getShop() != null)
					{
						item = this.getItemByItemOwner(_entityId, _itemId, "world-town-screen-shop-dialog-module.shop");
					}
				}
				if (item == null)
				{
					if ("CombatResultLoot" in ::Tactical && ::Tactical.CombatResultLoot != null)
					{
						item = this.getItemByItemOwner(_entityId, _itemId, "tactical-combat-result-screen.found-loot");
					}
				}
				if (item == null)
				{
					foreach (it in ::MSU.NestedTooltips.ItemObjectsByFilename)
					{
						if (typeof it != "string" && it.getInstanceID() == _itemId)
						{
							item = it;
							break;
						}
					}
				}
				break;

			case "entity":
				if (entity != null)	item = entity.getItems().getItemByInstanceID(_itemId);
				break;

			case "ground":
			case "character-screen-inventory-list-module.ground":
				if (entity != null)	item = ::TooltipEvents.tactical_helper_findGroundItem(entity, _itemId);
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
					if (result != null)
						item = result.item;
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

		return item;
	}
});
