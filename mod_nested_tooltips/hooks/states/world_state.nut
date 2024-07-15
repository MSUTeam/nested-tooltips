::MSU.MH.hook("scripts/states/world_state", function(q) {
	q.onBeforeSerialize = @(__original) function( _out )
	{
		::World.deleteRoster("MSU_Roster");
		::MSU.DummyPlayer = null;
		__original(_out);
	}
});
