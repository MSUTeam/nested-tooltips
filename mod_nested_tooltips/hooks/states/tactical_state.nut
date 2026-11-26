::NestedTooltips.MH.hook("scripts/states/tactical_state", function(q) {
	// Entity IDs of the open Entity tooltips with an arrow, in the order they opened (mirrors the JS tooltip stack,
	// as the show/hide notifications arrive in order). Only the last one, the innermost tooltip, points out its entity:
	// the vanilla arrow over it and the hover selection in the turn sequence bar, like vanilla's hover of an entity.
	q.m.NestedTooltips_EntityArrowStack <- [];

	// Called by the Entity tooltip's OnShowCallback/OnHideCallback (msu_tooltips.nut)
	q.nestedTooltips_pushArrowEntity <- { function nestedTooltips_pushArrowEntity( _id )
	{
		local previous = this.nestedTooltips_getArrowStackTop();
		this.m.NestedTooltips_EntityArrowStack.push(_id);
		this.nestedTooltips_updateArrowEntity(previous);
	}}.nestedTooltips_pushArrowEntity;

	q.nestedTooltips_popArrowEntity <- { function nestedTooltips_popArrowEntity( _id )
	{
		// The last entry of this entity: tooltips close from the inside out
		local stack = this.m.NestedTooltips_EntityArrowStack;
		local previous = this.nestedTooltips_getArrowStackTop();
		for (local i = stack.len() - 1; i >= 0; i--)
		{
			if (stack[i] == _id)
			{
				stack.remove(i);
				break;
			}
		}
		this.nestedTooltips_updateArrowEntity(previous);
	}}.nestedTooltips_popArrowEntity;

	q.nestedTooltips_getArrowStackTop <- { function nestedTooltips_getArrowStackTop()
	{
		local stack = this.m.NestedTooltips_EntityArrowStack;
		return stack.len() != 0 ? stack.top() : null;
	}}.nestedTooltips_getArrowStackTop;

	// Moves the arrow and the turn sequence bar selection from _previousID to the new innermost entity
	q.nestedTooltips_updateArrowEntity <- { function nestedTooltips_updateArrowEntity( _previousID )
	{
		local id = this.nestedTooltips_getArrowStackTop();
		if (id == _previousID)
			return;

		local previous = this.nestedTooltips_getArrowEntity(_previousID);
		if (previous != null)
			previous.showArrow(false);

		local entity = this.nestedTooltips_getArrowEntity(id);
		if (entity != null)
			entity.showArrow(true);

		// null restores vanilla's hover selection (see the turn_sequence_bar hook)
		if (::Tactical.TurnSequenceBar != null)
			::Tactical.TurnSequenceBar.nestedTooltips_setTooltipEntity(entity);
	}}.nestedTooltips_updateArrowEntity;

	// Vanilla's rule for the turn sequence bar arrow (turnsequencebar_onEntityMouseEnter): an alive actor
	q.nestedTooltips_getArrowEntity <- { function nestedTooltips_getArrowEntity( _id )
	{
		if (_id == null)
			return null;

		local entity = ::Tactical.getEntityByID(_id);
		return entity != null && ::MSU.isKindOf(entity, "actor") && entity.isAlive() ? entity : null;
	}}.nestedTooltips_getArrowEntity;
});
