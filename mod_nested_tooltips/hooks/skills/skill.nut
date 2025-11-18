::NestedTooltips.MH.hook("scripts/skills/skill", function(q) {
	q.getNestedTooltip <- function()
	{
		return this.getDefaultNestedTooltip();
	}

	q.getDefaultNestedTooltip <- function()
	{
		local ret = this.getTooltip();
		// Remove armor penetration and armor damage numbers for tooltips of nested skills not present on an actor
		// or without a reference to an item.
		// This ensures that nested tooltips of attack/weapon skills inside other tooltips which are meant just
		// as a reference to the skill in general do not display any specific damage numbers as the damage numbers
		// in actual use would be dependent on the item or character that skill would be present on.
		if (::MSU.isNull(this.getItem()) && ::MSU.isEqual(this.getContainer(), ::MSU.getDummyPlayer().getSkills()))
		{
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
		}
		return ret;
	}
});
