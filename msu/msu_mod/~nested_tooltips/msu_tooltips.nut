::MSU.Mod.Tooltips.setTooltips({
	CharacterStats = ::MSU.Class.CustomTooltip(@(_data) ::TooltipEvents.general_queryUIElementTooltipData(null, "character-stats." + _data.ExtraData, null)),
	Perk = ::MSU.Class.CustomTooltip(function(_data) {
		local filename = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData).filename;
		if (filename in ::MSU.NestedTooltips.PerkIDByFilename)
		{
			return ::TooltipEvents.general_queryUIPerkTooltipData(null, ::MSU.NestedTooltips.PerkIDByFilename[filename]);
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
		return ::TooltipEvents.general_querySkillNestedTooltipData(_data);
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
		return ::TooltipEvents.general_queryItemNestedTooltipData(_data);
	}),
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
