::NestedTooltips.MH.hook("scripts/items/item", function(q) {
	q.getNestedTooltip <- function()
	{
		return this.getTooltip();
	}
});
