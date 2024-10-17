::NestedTooltips.MH.hook("scripts/items/ammo/ammo", function(q) {
	q.onEquip = @(__original) function()
	{
		// Vanilla always randomizes the ammunition count when a quiver is equipped to something, not player controlled
		// While displaying tooltips we equip the currently viewed item to the Dummy player, triggering such a randomization allowing the player to generate free ammo
		// This hook preserves the previous ammunition count in that case
		if (::MSU.isEqual(this.getContainer().getActor(), ::MSU.getDummyPlayer()))
		{
			local oldAmmo = this.m.Ammo;
			__original();
			this.m.Ammo = oldAmmo;
		}
		else
		{
			__original();
		}
	}
});
