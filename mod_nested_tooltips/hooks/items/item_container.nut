::NestedTooltips.MH.hook("scripts/items/item_container", function(q) {
	// Call MSU skill_container.onUnequip function
	// Temporary fix for MSU and vanilla while MSU waits to update
	// This is necessary for proper equipping/unequipping of bag items for the Dummy Player.
	q.unequip = @(__original) function( _item )
	{
		if (_item != null && _item != -1 && _item.getCurrentSlotType() == ::Const.ItemSlot.Bag && _item.getSlotType() == ::Const.ItemSlot.Bag && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive())
		{
			foreach (item in this.m.Items[_item.getSlotType()])
			{
				if (item == _item)
				{
					this.m.Actor.getSkills().onUnequip(_item);
					break;
				}
			}
		}

		// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/684112192552961717/
		// `item_container.unequip` not properly removing bagged items while `item_container.equip` puts them in the bag.
		if (_item != null && _item != -1 && _item.getSlotType() == ::Const.ItemSlot.Bag)
		{
			local ret = this.removeFromBag(_item);
			// Vanilla calls skill_container update only for player controlled characters at the end of removeFromBag.
			// So we call it for NPCs manually.
			if (ret && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive() && !this.m.Actor.isPlayerControlled())
			{
				this.m.Actor.getSkills().update();
			}
			return ret;
		}

		return __original(_item);
	}

	// Call MSU skill_container.onUnequip function
	// Temporary fix for MSU while MSU waits to update
	q.removeFromBag = @(__original) function( _item )
	{
		if (_item.getCurrentSlotType() == this.Const.ItemSlot.Bag && _item.getSlotType() == ::Const.ItemSlot.Bag && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive())
		{
			foreach (item in this.m.Items[_item.getSlotType()])
			{
				if (item == _item)
				{
					this.m.Actor.getSkills().onUnequip(_item);
					break;
				}
			}
		}

		local ret = __original(_item);
		// Vanilla calls skill_container update only for player controlled characters at the end of __original.
		// So we call it for NPCs manually.
		if (ret && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive() && !this.m.Actor.isPlayerControlled())
		{
			this.m.Actor.getSkills().update();
		}

		return ret;
	}

	// Call MSU skill_container.onUnequip function
	// Temporary fix for MSU while MSU waits to update
	q.removeFromBagSlot = @(__original) function( _slot )
	{
		local item = this.m.Items[::Const.ItemSlot.Bag][_slot];
		if (item != null && item.getSlotType() == ::Const.ItemSlot.Bag && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive())
		{
			this.m.Actor.getSkills().onUnequip(item);
		}

		local ret = __original(_item);
		// Vanilla calls skill_container update only for player controlled characters at the end of __original.
		// So we call it for NPCs manually.
		if (ret && !::MSU.isNull(this.m.Actor) && this.m.Actor.isAlive() && !this.m.Actor.isPlayerControlled())
		{
			this.m.Actor.getSkills().update();
		}

		return ret;
	}
});
