::MSU.Mod.Tooltips.setTooltips({
	CharacterStats = ::MSU.Class.CustomTooltip(@(_data) ::TooltipEvents.general_queryUIElementTooltipData(null, "character-stats." + _data.ExtraData, null)),
	Perk = ::MSU.Class.CustomTooltip(function(_data) {
		local filename = _data.ExtraData;
		if (filename in ::MSU.NestedTooltips.PerkIDByFilename) return ::TooltipEvents.general_queryUIPerkTooltipData(null, ::MSU.NestedTooltips.PerkIDByFilename[_data.ExtraData]);
		return ::TooltipEvents.general_querySkillNestedTooltipData(null, null, filename);
	}),
	Skill = ::MSU.Class.CustomTooltip(function(_data) {
		local extraData = split(_data.ExtraData, ",");
		_data.Filename <- extraData.remove(0);
		if (extraData.len() != 0)
		{
			foreach (entry in extraData)
			{
				local pair = split(entry, ":");
				_data[pair[0]] <- pair[1] == "null" ? null : pair[1];
			}
		}
		return ::TooltipEvents.general_querySkillNestedTooltipData(_data);
	}),
	// Sometimes you need to show the nested tooltip by considering the entity to be null. This is useful for
	// e.g. showing nested tooltips of StatusEffects inside perk tooltips on the perk tree window when the selected
	// character has the StatusEffect. Using the standard Skill+filename will show the tooltip of the effect based on that character
	// whereas we want to show a generic tooltip independent of the entity.
	NullEntitySkill = ::MSU.Class.CustomTooltip(function(_data) {
		_data.entityId <- null;
		_data.itemOwner <- null;
		return ::MSU.System.Tooltips.getTooltip(_data.modId, "Skill").Tooltip.getUIData(_data);
	}),
	Item = ::MSU.Class.CustomTooltip(function(_data) {
		local extraData = split(_data.ExtraData, ",");
		_data.Filename <- extraData.remove(0);
		// We want itemId and _itemOwner to be passed via ExtraData only
		// because a nested item hyperlink shouldn't be considered as the tooltip
		// of an item that is present on an entity unless specified
		_data.itemOwner <- null;
		_data.itemId <- null;
		if (extraData.len() != 0)
		{
			foreach (entry in extraData)
			{
				local pair = split(entry, ":");
				_data[pair[0]] <- pair[1] == "null" ? null : pair[1];
			}
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
