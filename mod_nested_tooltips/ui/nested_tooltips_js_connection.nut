this.nested_tooltips_js_connection <- ::inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "NestedTooltipsJSConnection",
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
