::MSU.Mod.Tooltips.setTooltips({
	CharacterStats = ::MSU.Class.CustomTooltip(@(_data) ::TooltipEvents.general_queryUIElementTooltipData(null, "character-stats." + _data.ExtraData, null)),
	Perk = ::MSU.Class.CustomTooltip(function(_data) {
		local filename = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData).filename;
		if (filename in ::MSU.NestedTooltips.PerkIDByFilename)
		{
			local ret = ::TooltipEvents.general_queryUIPerkTooltipData(::MSU.getDummyPlayer().getID(), ::MSU.NestedTooltips.PerkIDByFilename[filename]);
			if (ret != null)
				ret.insert(0, { contentType = "ui-perk" });
			return ret;
		}
		else
		{
			::logError("Nested Tooltips Framework: perk filename not recognized. Make sure the perk def exists in ::Const.Perks.LookupMap: " + filename);
			throw ::MSU.Exception.KeyNotFound(filename);
		}
	}),
	Skill = ::MSU.Class.CustomTooltip(function(_data) {
		local original_entityId = "entityId" in _data ? _data.entityId : null;
		_data = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		if (!("entityId" in _data))
		{
			_data.entityId <- null;
		}
		else if (_data.entityId == "default")
		{
			_data.entityId = original_entityId;
		}
		local ret = ::TooltipEvents.general_querySkillNestedTooltipData(_data);
		if (ret != null)
			ret.insert(0, { contentType = "skill" });
		return ret;
	}),
	Item = ::MSU.Class.CustomTooltip(function(_data) {
		// itemId, entityId etc. must be passed in ExtraData if it is desired to be used
		// i.e. we don't take it from the tooltip stack.
		// Info such as entityId is ignored from the tooltip stack for the purposes of item
		// nested tooltips because there may be different entityId associated with
		// different nested item tooltips.
		local original_entityId = "entityId" in _data ? _data.entityId : null;
		_data = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		if (!("entityId" in _data))
		{
			_data.entityId <- null;
		}
		else if (_data.entityId == "default")
		{
			_data.entityId = original_entityId;
		}
		local ret = ::TooltipEvents.general_queryItemNestedTooltipData(_data);
		if (ret != null)
			ret.insert(0, { contentType = "ui-item" });
		return ret;
	}),
	Entity = ::MSU.Class.CustomTooltip(function( _data ) {
		_data = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		_data.entityId <- _data.filename.tointeger();
		local ret = ::TooltipEvents.general_queryEntityNestedTooltipData(_data);
		if (ret != null)
			ret.insert(0, { contentType = "entity" });
		return ret;
	}),
	Obj = ::MSU.Class.CustomTooltip(function( _data ) {
		_data = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		// It's not actually filename that's passed here, but that's what the key is called
		// in the return from the parse function above.
		local obj = ::MSU.System.Tooltips.ParsedObjects[_data.filename];

		local ret;
		if ("func" in _data)
		{
			ret = obj[_data.func]();
		}
		else
		{
			ret = obj.getTooltip();
		}

		if (ret != null && "contentType" in _data)
		{
			ret.insert(0, { contentType = _data.contentType });
		}

		return ret;
	})
	Tooltip = ::MSU.Class.CustomTooltip(function( _data ) {
		// replace the start/end with square brackets
		// replace the %%%% with quotation marks
		local str = "[" + ::String.replace(_data.ExtraData.slice(1, -1), "%%%%", "\"") + "]";
		return compilestring("return " + str)();
	})
});

local tooltipImageKeywords = {
	"ui/icons/action_points.png" 		: "CharacterStats+ActionPoints"
	"ui/icons/health.png" 				: "CharacterStats+Hitpoints"
	"ui/icons/morale.png" 				: "CharacterStats+Morale"
	"ui/icons/fatigue.png" 				: "CharacterStats+Fatigue"
	"ui/icons/armor_head.png" 			: "CharacterStats+ArmorHead"
	"ui/icons/armor_body.png" 			: "CharacterStats+ArmorBody"
	"ui/icons/melee_skill.png"  		: "CharacterStats+MeleeSkill"
	"ui/icons/ranged_skill.png" 		: "CharacterStats+RangeSkill"
	"ui/icons/melee_defense.png" 		: "CharacterStats+MeleeDefense"
	"ui/icons/ranged_defense.png" 		: "CharacterStats+RangeDefense"
	"ui/icons/vision.png" 				: "CharacterStats+SightDistance"
	"ui/icons/regular_damage.png" 		: "CharacterStats+RegularDamage"
	"ui/icons/armor_damage.png" 		: "CharacterStats+CrushingDamage"
	"ui/icons/chance_to_hit_head.png" 	: "CharacterStats+ChanceToHitHead"
	"ui/icons/initiative.png" 			: "CharacterStats+Initiative"
	"ui/icons/bravery.png" 				: "CharacterStats+Bravery"
}

::MSU.QueueBucket.AfterHooks.push(function()
{
	foreach (perk in ::Const.Perks.LookupMap)
	{
		local filename = split(perk.Script, "/").top();
		tooltipImageKeywords[perk.Icon] <- "Perk+" + filename;
		::MSU.NestedTooltips.PerkIDByFilename[filename] <- perk.ID;
	}
	::MSU.Mod.Tooltips.setTooltipImageKeywords(tooltipImageKeywords);
});
