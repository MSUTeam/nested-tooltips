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
	local roster = ::World.createRoster("MSU_Roster");
	::MSU.DummyPlayer = roster.create("scripts/entity/tactical/player");
	::MSU.DummyPlayer.setStartValuesEx([
		"msu_dummy_player_background"
	], false); // false to avoid adding traits
	::MSU.DummyPlayer.m.Name = "MSU Dummy Player";

	::MSU.DummyPlayer.getSkills().removeByID("special.double_grip");
}

::MSU.__destroyDummyPlayer <- function()
{
	::MSU.DummyPlayer = null;
	::World.deleteRoster("MSU_Roster");
}
