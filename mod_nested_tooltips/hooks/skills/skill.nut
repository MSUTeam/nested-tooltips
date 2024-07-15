::NestedTooltips.MH.hook("scripts/skills/skill", function(q) {
	q.getNestedTooltip <- function()
	{
		return this.getTooltip();
	}
});
