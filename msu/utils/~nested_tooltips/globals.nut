::MSU.DummyPlayer <- null;
::MSU.getDummyPlayer <- function()
{
	return this.DummyPlayer;
}

::MSU.__createDummyPlayer <- function()
{
	local roster = ::World.createRoster("MSU_Roster");
	::MSU.DummyPlayer = roster.create("scripts/entity/tactical/player");
	::MSU.DummyPlayer.setStartValuesEx([
		"msu_dummy_player_background"
	]);
	::MSU.DummyPlayer.m.Name = "MSU Dummy Player";
}

::MSU.__destroyDummyPlayer <- function()
{
	::MSU.DummyPlayer = null;
	::World.deleteRoster("MSU_Roster");
}
