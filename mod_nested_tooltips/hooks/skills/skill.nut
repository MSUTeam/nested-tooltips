::NestedTooltips.MH.hook("scripts/skills/skill", function(q) {
	// Can be specified and this item will then be set as the m.Item of this skill
	// while fetching the nested tooltip, if no item is already set. This is necessary
	// for certain skills which need to access certain things from their item during their tooltip
	// e.g. shoot_bolt in vanilla.
	q.m.MSU_NestedTooltipItemScript <- null;

	q.getNestedTooltip <- function()
	{
		return this.getTooltip();
	}

	q.__MSU_getNestedTooltipSafe <- function()
	{
		local fakeItem;
		if (::MSU.isNull(this.getItem()) && this.m.MSU_NestedTooltipItemScript != null)
		{
			fakeItem = ::new(this.m.MSU_NestedTooltipItemScript);
			fakeItem.m.__MSU_IsNestedFakeItem = true;
			this.setItem(fakeItem);
		}

		try
		{
			local ret = this.getNestedTooltip();
			this.getContainer().onQueryTooltip(this, ret); // Manually run MSU event

			// Remove armor penetration and armor damage numbers for tooltips of nested skills not present on an actor
			// or without a reference to a real item.
			// This ensures that nested tooltips of attack/weapon skills inside other tooltips which are meant just
			// as a reference to the skill in general do not display any specific damage numbers as the damage numbers
			// in actual use would be dependent on the item or character that skill would be present on.
			local isNull = ::MSU.isNull(this.getItem());
			if (isNull && ::MSU.isEqual(this.getContainer(), ::MSU.getDummyPlayer().getSkills()) || !isNull && this.m.Item.m.__MSU_IsNestedFakeItem)
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

			if (fakeItem != null)
			{
				this.setItem(null);
			}

			return ret;
		}
		catch (error)
		{
			::NestedTooltips.Mod.Debug.printWarning(format("Could not fetch nested tooltip for skill %s, so returning base skill tooltip. Error: %s", this.getID(), error));
			return this.isActive() ? this.skill.getDefaultUtilityTooltip() : this.skill.getTooltip();
		}
	}
});
