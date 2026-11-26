this.nested_tooltips_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "NestedTooltipsJSConnection",
	}

	function connect()
	{
		this.js_connection.connect();
	}

	function updateNestedTooltipTextStyle()
	{
		if (!this.isConnected()) return;

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

	function onTooltipShown( _data )
	{
		this.callTooltipCallback(_data, "OnShowCallback");
	}

	function onTooltipHidden( _data )
	{
		this.callTooltipCallback(_data, "OnHideCallback");
	}

	// _data are the query parameters of the tooltip (modId, elementId, ...), see onQueryMSUTooltipData
	function callTooltipCallback( _data, _key )
	{
		try
		{
			local ret = ::MSU.System.Tooltips.getTooltip(_data.modId, _data.elementId);
			local callback = ret.Tooltip[_key];
			if (callback == null)
				return;

			_data.ExtraData <- ret.Data;
			callback(_data);
		}
		catch (_error)
		{
			::logError(format("Nested Tooltips Framework: %s of tooltip %s failed: %s", _key, _data.elementId + "", _error + ""));
		}
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
