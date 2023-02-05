::MSU.DummyPlayer <- null;
::MSU.getDummyPlayer <- function()
{
	if (this.DummyPlayer == null)
	{
		this.DummyPlayer = ::World.getTemporaryRoster().create("scripts/entity/tactical/player");
		this.DummyPlayer.m.Name = "MSU DummyPlayer";
		::World.getTemporaryRoster().clear();
	}
	return this.DummyPlayer;
}
