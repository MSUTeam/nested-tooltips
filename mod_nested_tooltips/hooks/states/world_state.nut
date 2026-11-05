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

		// Don't clear ParsedObjects here: saving doesn't destroy any objects (and the weakrefs don't affect saving),
		// and clearing would break Obj links that are still shown, e.g. after an autosave.
		q.saveCampaign = @(__original) { function saveCampaign( _campaignFileName, _campaignLabel = null )
		{
			::MSU.__destroyDummyPlayer();
			__original(_campaignFileName, _campaignLabel);
		}}.saveCampaign;

		// Destroy the dummy player while the world still exists, so that no stale dummy player
		// is used after returning to the main menu.
		q.onFinish = @(__original) function()
		{
			::MSU.__destroyDummyPlayer();
			::MSU.System.Tooltips.ParsedObjects.clear();
			__original();
		}
	});
});
