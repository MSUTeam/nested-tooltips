::MSU.NestedTooltips <- {
	SkillObjectsByFilename = {},
	ItemObjectsByFilename = {},
	ItemObjectsByInstanceID = {},
	PerkIDByFilename = {},

	function getObjFromFilename( _filename, _table )
	{
		local obj;
		if (_filename in _table)
		{
			obj = _table[_filename];
		}
		else
		{
			local idx = _filename.find("/");
			if (idx != null)
			{
				// convert "skills/actives/rotation" to "actives/rotation" and eventually "rotation"
				obj = ::MSU.NestedTooltips.getObjFromFilename(_filename.slice(idx + 1), _table);
			}
		}

		if (obj == null)
		{
			throw ::MSU.Exception.KeyNotFound(_filename);
		}

		if (typeof obj == "string")
		{
			obj = ::new(obj);
			_table[_filename] = obj;
			if (::isKindOf(obj, "skill"))
			{
				obj.saveBaseValues();
			}
			else if (::isKindOf(obj, "item"))
			{
				this.ItemObjectsByInstanceID[obj.getInstanceID()] <- obj;
			}
		}

		return obj;
	}

	function getItemByInstanceID( _id )
	{
		return _id in this.ItemObjectsByInstanceID ? this.ItemObjectsByInstanceID[_id] : null;
	}

	// Entity IDs of the open Entity tooltips with an arrow, in the order they opened (mirrors the JS tooltip stack,
	// as the show/hide notifications arrive in order). Only the last one, the innermost tooltip, has the arrow.
	EntityArrowStack = [],

	// OnShow/OnHide of the Entity tooltip: show the vanilla arrow over the entity of the innermost open Entity tooltip,
	// with the same rule as vanilla's turn sequence bar hover (tactical_state.turnsequencebar_onEntityMouseEnter).
	// Pass showArrow:false in the extra data to open the tooltip without an arrow.
	function setEntityArrow( _data, _show )
	{
		if (!::Tactical.isActive())
			return;

		local extraData = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_data.ExtraData);
		if ("showArrow" in extraData && extraData.showArrow == "false")
			return;

		local id = extraData.filename.tointeger();
		local stack = this.EntityArrowStack;
		if (_show)
		{
			local previous = stack.len() != 0 ? stack.top() : null;
			stack.push(id);
			if (previous != id)
			{
				this.__showEntityArrow(previous, false);
				this.__showEntityArrow(id, true);
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
					this.__showEntityArrow(id, false);
					this.__showEntityArrow(next, true);
				}
			}
			return;
		}
	}

	function __showEntityArrow( _id, _show )
	{
		if (_id == null)
			return;
		local entity = ::Tactical.getEntityByID(_id);
		if (entity != null && ::isKindOf(entity, "actor") && entity.isAlive())
			entity.showArrow(_show);
	}
};
