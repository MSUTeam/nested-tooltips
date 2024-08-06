this.nested_tooltips_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "NestedTooltipsJSConnection",
	}

	function connect()
	{
		this.js_connection.connect();
		this.updateNestedTooltipTextStyle();
	}

	function updateNestedTooltipTextStyle()
	{
		local styleString = format("color: rgba(%s);", ::getModSetting("mod_msu", "NestedTooltips_Color").getValue());
		if (::getModSetting("mod_msu", "NestedTooltips_Bold").getValue()) styleString += "font-weight: bold;";
		if (::getModSetting("mod_msu", "NestedTooltips_Italic").getValue()) styleString += "font-style: italic;";
		if (::getModSetting("mod_msu", "NestedTooltips_Underline").getValue()) styleString += "text-decoration: underline;";
		this.m.JSHandle.asyncCall("updateNestedTooltipTextStyle", styleString);
	}

	function passTooltipIdentifiers( _table )
	{
		this.m.JSHandle.asyncCall("setTooltipImageKeywords", _table);
	}

	function queryZoomLevel()
	{
		local ret = {
			State = ::MSU.Utils.getActiveState().ClassName,
			Zoom = 1.0
		}
		if (ret.State == "tactical_state")
			ret.Zoom = ::Tactical.getCamera().Zoom;
		else if (ret.State == "world_state")
			ret.Zoom = ::World.getCamera().Zoom;
		return ret;
	}
});
