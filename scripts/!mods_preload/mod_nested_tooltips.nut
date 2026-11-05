::NestedTooltips <- {
	ID = "mod_nested_tooltips",
	Name = "Nested Tooltips Framework",
	Version = "0.5.4",
	DummyPlayerRosterID = ::toHash("NestedTooltipsRoster"),
	GitHubURL = "https://github.com/MSUTeam/nested-tooltips"
}

::NestedTooltips.MH <- ::Hooks.register(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);
::NestedTooltips.MH.require("mod_msu");

::NestedTooltips.MH.queue(">mod_msu", function() {
	::NestedTooltips.Mod <- ::MSU.Class.Mod(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);

	::NestedTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::NestedTooltips.GitHubURL);
	::NestedTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);

	::NestedTooltips.Mod.Debug.enable();

	::MSU.UI.addOnConnectCallback(::MSU.System.Tooltips.passTooltipIdentifiers.bindenv(::MSU.System.Tooltips));

	::include("mod_nested_tooltips/ui/!load");

	foreach (file in ::IO.enumerateFiles("mod_nested_tooltips/hooks"))
	{
		::include(file);
	}

	::Hooks.registerJS("ui/mods/nested_tooltips/js_hooks/setup.js");

	foreach (file in ::IO.enumerateFiles("ui/mods/nested_tooltips/js_hooks"))
	{
		::Hooks.registerJS(file + ".js");
	}

	local function populateObjectsByFilename( _path, _table )
	{
		foreach (path in ::IO.enumerateFiles(_path))
		{
			local arr = split(path, "/");
			local filename = arr.pop();
			local shortName = filename;
			while (filename in _table && arr.len() != 0)
			{
				filename = arr.pop() + "/" + filename;
			}
			if (filename in _table)
			{
				::logError(format("Nested Tooltips: could not register a filename for %s, because all its partial paths are taken.", path));
				continue;
			}
			if (filename != shortName)
			{
				::logWarning(format("Nested Tooltips: \"%s\" already refers to %s, so %s must be referred to as \"%s\".", shortName, _table[shortName], path, filename));
			}
			_table[filename] <- path;
		}
	}

	populateObjectsByFilename("scripts/skills", ::MSU.NestedTooltips.SkillObjectsByFilename);
	populateObjectsByFilename("scripts/items", ::MSU.NestedTooltips.ItemObjectsByFilename);

	::Hooks.registerJS("ui/mods/msu/nested_tooltips.js");
	::Hooks.registerCSS("ui/mods/msu/css/nested_tooltips.css");
});
