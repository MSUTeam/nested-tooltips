::MSU.DummyPlayer <- null;
::MSU.getDummyPlayer <- function()
{
	if (this.DummyPlayer == null)
	{
		local roster = ::World.createRoster("MSU_Roster");
		this.DummyPlayer = roster.create("scripts/entity/tactical/player");
		this.DummyPlayer.m.Name = "MSU Dummy Player";
	}
	return this.DummyPlayer;
}
