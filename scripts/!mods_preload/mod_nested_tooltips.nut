::NestedTooltips <- {
	ID = "mod_nested_tooltips",
	Name = "Nested Tooltips",
	Version = "0.1.0"
	GitHubURL = ""
}

::NestedTooltips.MH <- ::Hooks.register(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);
::NestedTooltips.MH.require("mod_msu");

::NestedTooltips.MH.queue(">mod_msu", function() {
	::NestedTooltips.Mod <- ::MSU.Class.Mod(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);

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
