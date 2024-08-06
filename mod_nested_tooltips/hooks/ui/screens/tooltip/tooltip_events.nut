::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.onQueryMSUTooltipData = @() function( _data )
	{
		local ret = ::MSU.System.Tooltips.getTooltip(_data.modId, _data.elementId);
		_data.ExtraData <- ret.Data;
		return ret.Tooltip.getUIData(_data);
	}
});
