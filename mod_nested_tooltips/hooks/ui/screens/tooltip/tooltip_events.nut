::NestedTooltips.MH.hook("scripts/ui/screens/tooltip/tooltip_events", function(q) {
	q.general_querySkillNestedTooltipData <- function( _entityId, _skillId, _filename )
	{
		if (_skillId == null) _skillId = ::MSU.NestedTooltips.SkillObjectsByFilename[_filename].getID();
		local entity = _entityId != null ? ::Tactical.getEntityByID(_entityId) : null;
		local skill;
		if (entity != null)
		{
			skill = entity.getSkills().getSkillByID(_skillId);
		}

		if (skill == null)
		{
			skill = ::MSU.NestedTooltips.SkillObjectsByFilename[_filename];
			skill.m.Container = ::MSU.getDummyPlayer().getSkills();
			local ret = skill.getNestedTooltip();
			skill.m.Container = null;
			return ret;
		}

		return skill.getNestedTooltip();
	}
});
