::NestedTooltips.MH.hook("scripts/items/item", function(q) {
	q.m.__MSU_IsNestedFakeItem <- false;

	q.getNestedTooltip <- { function getNestedTooltip()
	{
		return this.getTooltip();
	}}.getNestedTooltip;
});
