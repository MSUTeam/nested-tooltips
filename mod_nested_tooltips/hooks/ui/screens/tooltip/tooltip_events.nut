::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_querySkillNestedTooltipData <- function( _data )
	{
		local entityId = "entityId" in _data ? _data.entityId : null;
		local itemId = "itemId" in _data ? _data.itemId : null;
		local itemOwner = "itemOwner" in _data ? _data.itemOwner : null;
		local cachedSkillObj = ::MSU.NestedTooltips.getObjFromFilename(_data.filename, ::MSU.NestedTooltips.SkillObjectsByFilename);
		local skillId = cachedSkillObj.getID();

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
				if (existingItem != null)
				{
					if (existingItem.getCurrentSlotType() == ::Const.ItemSlot.Bag)
						dummyContainer.removeFromBag(existingItem);
					else
						dummyContainer.unequip(existingItem);
				}

				dummyContainer.equip(item);
			}

			foreach (s in item.getSkills())
			{
				if (s.getID() == skillId)
				{
					ret = s.__MSU_getNestedTooltipSafe();
					break;
				}
			}

			if (isDummyEquipping)
			{
				if (item.getCurrentSlotType() == ::Const.ItemSlot.Bag)
					dummyContainer.removeFromBag(item);
				else
					dummyContainer.unequip(item);
				if (existingItem != null)
				{
					dummyContainer.equip(existingItem);
				}
			}
		}

		if (ret == null)
		{
			local entity = entityId != null ? ::Tactical.getEntityByID(entityId) : null;
			if (entity != null)
			{
				local skill = entity.getSkills().getSkillByID(skillId);
				if (skill != null)
				{
					return skill.__MSU_getNestedTooltipSafe();
				}
			}

			cachedSkillObj.m.Container = ::MSU.getDummyPlayer().getSkills();
			ret = cachedSkillObj.__MSU_getNestedTooltipSafe();
			cachedSkillObj.m.Container = null;
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
			item = ::MSU.NestedTooltips.getObjFromFilename(_data.filename, ::MSU.NestedTooltips.ItemObjectsByFilename);
		}

		return item.getNestedTooltip();
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
					item = ::MSU.NestedTooltips.getItemByInstanceID(_itemId);
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

	q.onQueryMSUTooltipData = @() function( _data )
	{
		local ret = ::MSU.System.Tooltips.getTooltip(_data.modId, _data.elementId);
		_data.ExtraData <- ret.Data;
		return ret.Tooltip.getUIData(_data);
	}
});
