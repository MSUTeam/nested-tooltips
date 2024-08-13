::MSU.MH.hook("scripts/states/world_state", function(q) {
	q.loadCampaign = @(__original) function( _campaignFileName )
	{
		::MSU.__destroyDummyPlayer();
		__original(_campaignFileName);
		::MSU.__createDummyPlayer();
	}

	q.onBeforeSerialize = @(__original) function( _out )
	{
		::MSU.__destroyDummyPlayer();
		__original(_out);
	}
});
