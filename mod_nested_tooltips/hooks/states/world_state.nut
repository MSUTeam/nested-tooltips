::MSU.QueueBucket.VeryLate.push(function() {
	::MSU.MH.hook("scripts/states/world_state", function(q) {
		q.init = @(__original) function()
		{
			::MSU.__destroyDummyPlayer();
			::MSU.__canCreateDummyPlayer = true;
			::MSU.System.Tooltips.ParsedObjects.clear();
			__original();
		}

		q.loadCampaign = @(__original) { function loadCampaign( _campaignFileName )
		{
			::MSU.__destroyDummyPlayer();
			::MSU.System.Tooltips.ParsedObjects.clear();
			__original(_campaignFileName);
		}}.loadCampaign;

		q.saveCampaign = @(__original) { function saveCampaign( _campaignFileName, _campaignLabel = null )
		{
			::MSU.__destroyDummyPlayer();
			::MSU.System.Tooltips.ParsedObjects.clear();
			__original(_campaignFileName, _campaignLabel);
		}}.saveCampaign;
	});
});
