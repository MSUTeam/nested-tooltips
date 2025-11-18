::MSU.NestedTooltips <- {
	SkillObjectsByFilename = {},
	ItemObjectsByFilename = {},
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
		}
		return obj;
	}
};
