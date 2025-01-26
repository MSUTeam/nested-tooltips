::NestedTooltips <- {
	ID = "mod_nested_tooltips",
	Name = "Nested Tooltips Framework",
	Version = "0.1.9",
	GitHubURL = "https://github.com/MSUTeam/nested-tooltips"
}

::NestedTooltips.MH <- ::Hooks.register(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);
::NestedTooltips.MH.require("mod_msu");

::NestedTooltips.MH.queue(">mod_msu", function() {
	::NestedTooltips.Mod <- ::MSU.Class.Mod(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);

	::NestedTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::NestedTooltips.GitHubURL);
	::NestedTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
	::include("mod_nested_tooltips/modsettings");

	::NestedTooltips.Mod.Debug.enable();

	::MSU.UI.addOnConnectCallback(::MSU.System.Tooltips.passTooltipIdentifiers.bindenv(::MSU.System.Tooltips));

	::include("mod_nested_tooltips/ui/!load");

	foreach (file in ::IO.enumerateFiles("mod_nested_tooltips/hooks"))
	{
		::include(file);
	}

	foreach (file in ::IO.enumerateFiles("ui/mods/nested_tooltips/js_hooks"))
	{
		::Hooks.registerJS(file + ".js");
	}

	::Hooks.registerJS("ui/mods/msu/nested_tooltips.js");
	::Hooks.registerCSS("ui/mods/msu/css/nested_tooltips.css");
});

::NestedTooltips.MH.queue(">mod_msu", function() {
	::MSU.__canCreateDummyPlayer = true;

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
}, ::Hooks.QueueBucket.FirstWorldInit);
