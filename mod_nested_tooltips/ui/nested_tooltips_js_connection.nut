this.nested_tooltips_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "NestedTooltipsJSConnection",
	}

	function passTooltipIdentifiers( _table )
	{
		this.m.JSHandle.asyncCall("setTooltipImageKeywords", _table);
	}
});
