::MSU.Mod.Tooltips.setTooltips({
	Skill = ::MSU.Class.CustomTooltip(function(_data) {
		local arr = split(_data.ExtraData, ",");
		return ::TooltipEvents.general_querySkillNestedTooltipData("entityId" in _data ? _data.entityId : null, arr.len() > 1 ? arr[1] : null, arr[0])
	}),
	Item = ::MSU.Class.CustomTooltip(function(_data) {
		local arr = split(_data.ExtraData, ",");
		return ::TooltipEvents.general_queryItemNestedTooltipData("entityId" in _data ? _data.entityId : null, arr.len() > 1 ? arr[1] : null, arr.len() > 2 ? arr[2] : null, arr[0])
	})
});
