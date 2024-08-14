::MSU.MH.hook("scripts/states/world_state", function(q) {
	q.init = @(__original) function()
	{
		::MSU.__destroyDummyPlayer();
		__original();
	}

	q.onBeforeSerialize = @(__original) function( _out )
	{
		::MSU.__destroyDummyPlayer();
		__original(_out);
	}
});
