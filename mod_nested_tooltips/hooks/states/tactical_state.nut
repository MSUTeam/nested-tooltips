::NestedTooltips.MH.hook("scripts/states/tactical_state", function(q) {
	// Entity IDs of the open Entity tooltips with an arrow, in the order they opened (mirrors the JS tooltip stack,
	// as the show/hide notifications arrive in order). Only the last one, the innermost tooltip, has the arrow.
	q.m.NestedTooltips_EntityArrowStack <- [];

	// OnShow/OnHide of the Entity tooltip: show the vanilla arrow over the entity of the innermost open Entity tooltip,
	// with the same rule as vanilla's turn sequence bar hover (turnsequencebar_onEntityMouseEnter).
	// Pass showArrow:false in the extra data to open the tooltip without an arrow.
	q.nestedTooltips_setEntityArrow <- function( _data, _show )
	{
		local extraData = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		if ("showArrow" in extraData && extraData.showArrow == "false")
			return;

		local id = extraData.filename.tointeger();
		local stack = this.m.NestedTooltips_EntityArrowStack;
		if (_show)
		{
			local previous = stack.len() != 0 ? stack.top() : null;
			stack.push(id);
			if (previous != id)
			{
				this.nestedTooltips_showEntityArrow(previous, false);
				this.nestedTooltips_showEntityArrow(id, true);
			}
			return;
		}

		// The last entry of this entity: tooltips close from the inside out
		for (local i = stack.len() - 1; i >= 0; i--)
		{
			if (stack[i] != id)
				continue;
			local wasInnermost = i == stack.len() - 1;
			stack.remove(i);
			if (wasInnermost)
			{
				local next = stack.len() != 0 ? stack.top() : null;
				if (next != id)
				{
					this.nestedTooltips_showEntityArrow(id, false);
					this.nestedTooltips_showEntityArrow(next, true);
				}
			}
			return;
		}
	}

	q.nestedTooltips_showEntityArrow <- function( _id, _show )
	{
		if (_id == null)
			return;
		local entity = ::Tactical.getEntityByID(_id);
		if (entity != null && ::isKindOf(entity, "actor") && entity.isAlive())
			entity.showArrow(_show);
	}
});
