::NestedTooltips <- {
	ID = "mod_nested_tooltips",
	Name = "Nested Tooltips",
	Version = "0.1.0",
	GitHubURL = "https://github.com/MSUTeam/nested-tooltips"
}

::NestedTooltips.MH <- ::Hooks.register(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);
::NestedTooltips.MH.require("mod_msu");

::NestedTooltips.MH.queue(">mod_msu", function() {
	::NestedTooltips.Mod <- ::MSU.Class.Mod(::NestedTooltips.ID, ::NestedTooltips.Version, ::NestedTooltips.Name);
	::NestedTooltips.Mod.Registry.addModSource(::MSU.System.Registry.ModSourceDomain.GitHub, ::NestedTooltips.GitHubURL);
	::NestedTooltips.Mod.Registry.setUpdateSource(::MSU.System.Registry.ModSourceDomain.GitHub);
});
