::NestedTooltips.UI <- {};

::Hooks.registerJS("ui/mods/msu/nested_tooltips_js_connection.js");
::MSU.QueueBucket.AfterHooks.push(function() {
	::NestedTooltips.UI.JSConnection <- ::new("mod_nested_tooltips/ui/nested_tooltips_js_connection");
	::MSU.UI.registerConnection(::NestedTooltips.UI.JSConnection);
	::MSU.UI.addOnConnectCallback(function(){
		::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle();
	})
});
