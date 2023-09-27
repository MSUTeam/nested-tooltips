::NestedTooltips.MH.hook("scripts/skills/skill", function(q) {
	q.getNestedTooltip <- function()
	{
		return this.getDefaultNestedTooltip();
	}

	q.getDefaultNestedTooltip <- function()
	{
		local ret = this.getTooltip();
		foreach (i, entry in ret)
		{
			if (!("text" in entry)) continue;

			if (entry.id == 4 && entry.icon == "ui/icons/regular_damage.png")
			{
				entry.text = ::MSU.Text.colorRed((this.getDirectDamage() * 100) + "%") + " of damage ignores armor";
			}
			else if (entry.id == 5 && entry.icon == "ui/icons/armor_damage.png")
			{
				ret.remove(i);
				break;
			}
		}
		return ret;
	}
});
