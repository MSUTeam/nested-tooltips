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
		if (::MSU.isIn("saveBaseValues", skill, true))
		{
			skill.saveBaseValues();
			::MSU.NestedTooltips.SkillObjectsByFilename[split(file, "/").top()] <- skill;
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
