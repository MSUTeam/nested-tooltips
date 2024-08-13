::MSU.NestedTooltips <- {
	SkillObjectsByFilename = {},
	ItemObjectsByFilename = {},
	PerkIDByFilename = {}
};

::MSU.QueueBucket.FirstWorldInit.push(function() {
	::MSU.__createDummyPlayer();

	foreach (file in ::IO.enumerateFiles("scripts/skills"))
	{
		if (file == "scripts/skills/skill")
			continue;

		local skill = ::new(file);
		if (::isKindOf(skill, "skill"))
		{
			skill.saveBaseValues();
			::MSU.NestedTooltips.SkillObjectsByFilename[skill.ClassName] <- skill;
		}
	}

	foreach (file in ::IO.enumerateFiles("scripts/items"))
	{
		if (file == "scripts/items/item")
			continue;

		local item = ::new(file);
		if (::isKindOf(item, "item"))
		{
			::MSU.NestedTooltips.ItemObjectsByFilename[item.ClassName] <- item;
		}
	}
});
