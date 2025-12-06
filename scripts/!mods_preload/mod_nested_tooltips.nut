::NestedTooltips <- {
	ID = "mod_nested_tooltips",
	Name = "Nested Tooltips Framework",
	Version = "0.3.0",
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
			while (filename in _table)
			{
				filename = arr.pop() + "/" + filename;
			}
			_table[filename] <- path;
		}
	}

	populateObjectsByFilename("scripts/skills", ::MSU.NestedTooltips.SkillObjectsByFilename);
	populateObjectsByFilename("scripts/items", ::MSU.NestedTooltips.ItemObjectsByFilename);

	::Hooks.registerJS("ui/mods/msu/nested_tooltips.js");
	::Hooks.registerCSS("ui/mods/msu/css/nested_tooltips.css");
});
