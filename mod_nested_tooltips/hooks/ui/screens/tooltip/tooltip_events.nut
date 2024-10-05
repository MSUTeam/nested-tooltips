::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_querySkillNestedTooltipData <- function( _data )
	{
		local function getNestedTooltip_safe( _skill )
		{
			try
			{
				return _skill.getNestedTooltip();
			}
			catch (error)
			{
				::NestedTooltips.Mod.Debug.printWarning(format("Could not fetch nested tooltip for skill %s, so returning base skill tooltip. Error: %s", _skill.getID(), error));
				return _skill.isActive() ? _skill.skill.getDefaultUtilityTooltip() : _skill.skill.getTooltip();
			}
		}

		local entityId = "entityId" in _data ? _data.entityId : null;
		// local skillId = "skillId" in _data ? _data.skillId : null;
		local itemId = "itemId" in _data ? _data.itemId : null;
		local itemOwner = "itemOwner" in _data ? _data.itemOwner : null;

		local skillId = ::MSU.NestedTooltips.SkillObjectsByFilename[_data.Filename].getID();
		local entity = entityId != null ? ::Tactical.getEntityByID(entityId) : null;
		local skill;
		if (entity != null)
		{
			skill = entity.getSkills().getSkillByID(skillId);
		}

		if (skill != null)
			return getNestedTooltip_safe(skill);

		local ret;

		local item;
		if (itemId != null)
		{
			item = this.getItemByItemOwner(entityId, itemId, itemOwner);
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
				if (s.getID() == skillId)
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
			skill = ::MSU.NestedTooltips.SkillObjectsByFilename[_data.Filename];
			skill.m.Container = ::MSU.getDummyPlayer().getSkills();
			ret = getNestedTooltip_safe(skill);
			skill.m.Container = null;
		}

		return ret;
	}

	q.general_queryItemNestedTooltipData <- function( _data )
	{
		local item;

		local itemId = "itemId" in _data ? _data.itemId : null;
		if (itemId != null)
		{
			local entityId = "entityId" in _data ? _data.entityId : null;
			local itemOwner = "itemOwner" in _data ? _data.itemOwner : null;
			item = this.getItemByItemOwner(entityId, itemId, itemOwner);
		}
		else
		{
			item = ::MSU.NestedTooltips.ItemObjectsByFilename[_data.Filename];
		}

		return item.getNestedTooltip();
	}

	q.getItemByItemOwner <- function( _entityId, _itemId, _itemOwner )
	{
		local item;
		local entity = _entityId != null ? ::Tactical.getEntityByID(_entityId) : null;

		switch (_itemOwner)
		{
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

		if (item == null && _itemId != null)
		{
			foreach (itemObj in ::MSU.NestedTooltips.ItemObjectsByFilename)
			{
				if (itemObj.getInstanceID() == _itemId)
				{
					item = itemObj;
					break;
				}
			}
		}

		return item;
	}

	q.onQueryMSUTooltipData = @() function( _data )
	{
		local ret = ::MSU.System.Tooltips.getTooltip(_data.modId, _data.elementId);
		_data.ExtraData <- ret.Data;
		return ret.Tooltip.getUIData(_data);
	}
});
