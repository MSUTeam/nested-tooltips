::MSU.DummyPlayer <- null;
::MSU.__canCreateDummyPlayer <- false;
::MSU.getDummyPlayer <- function()
{
	if (this.DummyPlayer == null && this.__canCreateDummyPlayer)
	{
		this.__createDummyPlayer();
	}

	return this.DummyPlayer;
}

::MSU.__createDummyPlayer <- function()
{
	local roster = ::World.createRoster(::NestedTooltips.DummyPlayerRosterID);
	::MSU.DummyPlayer = roster.create("scripts/entity/tactical/player");
	::MSU.DummyPlayer.m.Talents.resize(::Const.Attributes.COUNT, 0);
	::MSU.DummyPlayer.fillAttributeLevelUpValues(::Const.XP.MaxLevelWithPerkpoints - 1);
	::MSU.DummyPlayer.setStartValuesEx([
		"msu_dummy_player_background"
	], false); // false to avoid adding traits
	::MSU.DummyPlayer.m.Name = "MSU Dummy Player";

	::MSU.DummyPlayer.getSkills().removeByID("special.double_grip");

	::MSU.DummyPlayer.getTile = function()
	{
		return ::MSU.Class.DummyPlayerTile();
	}

	// Vanilla does not expect a null entity in the general_queryUIPerkTooltipData function.
	// So, we pass the dummy player's ID but overwrite the dummy player's hasPerk function
	// to return true so that the tooltip_events function does not add perk tier requirements to it.
	::MSU.DummyPlayer.hasPerk = function( _perkID )
	{
		return true;
	}

	// Overwrite the hasSprite function to always return false so that no sprite manipulation happens
	// on the dummy player. It has been observed that equipping/unequipping items on the dummy player
	// can cause crashes randomly sometimes in various actor functions which access/manipulate sprite brushes.
	// No idea why.
	::MSU.DummyPlayer.hasSprite = function( _name )
	{
		return false;
	}

	// Overwrite with empty function for performance as we don't care about dummy player's appearance
	::MSU.DummyPlayer.onAppearanceChanged = function( _appearance, _setDirty = true )
	{
	}
}

::MSU.__destroyDummyPlayer <- function()
{
	::MSU.DummyPlayer = null;
	::World.deleteRoster(::NestedTooltips.DummyPlayerRosterID);
}
