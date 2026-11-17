::NestedTooltips.MH.hook("scripts/states/tactical_state", function(q) {
	// Entity tooltips still open when a combat ended can't hide their arrow anymore (Tactical is inactive),
	// so don't carry them into the next combat
	q.onInit = @(__original) function()
	{
		::MSU.NestedTooltips.EntityArrowStack.clear();
		__original();
	}
});
