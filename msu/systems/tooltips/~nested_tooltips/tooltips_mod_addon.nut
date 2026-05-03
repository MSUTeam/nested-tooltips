local __regexp = regexp("\\[([^\\[\\]]+)\\|([^\\[\\]]+)\\]"); // \[(.+?)\|([\w\.]+)\] \[([^|]+)\|([\w\.]+)\]

// Squirrel regex cannot match empty strings, so we require a blank 1 length string
// instead of empty string as the default alias for "$Name$"
local __dynamicFieldRegexp = regexp("\\$([^\\$]+)\\$");

local function byteToUnsigned( _b )
{
	return _b < 0 ? _b + 256: _b;
}

::MSU.Class.TooltipsModAddon.encodeString <- function ( _str )
{
	local ret = "";
	for (local i = 0; i < _str.len(); i++)
	{
		ret += format("%03d", byteToUnsigned(_str[i]));
	}
	return ret;
}

::MSU.Class.TooltipsModAddon.decodeString <- function( _str )
{
	local ret = "";
	for (local i = 0; i < _str.len(); i += 3)
	{
		ret += format("%c", _str.slice(i, i + 3).tointeger());
	}
	return ret;
}

::MSU.Class.TooltipsModAddon.parseObject <- function ( _obj )
{
	local key = _obj + "";
	::MSU.System.Tooltips.ParsedObjects[key] <- _obj.weakref();
	return key;
}

::MSU.Class.TooltipsModAddon.parseTooltip <- function( _tooltip )
{
	local ret = "<";
	foreach (entry in _tooltip)
	{
		ret += "{";
		foreach (k, v in entry)
		{
			ret += k + "=";
			switch (typeof v)
			{
				case "string":
					ret += "%%%%" + v + "%%%%";
					break;
				case "array":
					ret += ::MSU.Class.TooltipsModAddon.parseTooltip(v);
					break;
				default:
					ret += v;
					break;
			}
			ret += ",";
		}
		ret += "},";
	}
	ret = ret.slice(0, -1) + ">";
	return ret;
}

// the __regexp should be a static member of the TooltipsModAddon class when merging into MSU
::MSU.Class.TooltipsModAddon.parseString <- function( _string, _prefix = "" )
{
	local myModID = this.getMod().getID();
	local match;
	local ret = "";
	local lastPos = 0;
	local tag = "tooltip";
	while (match = __regexp.capture(_string, lastPos))
	{
		ret += _string.slice(lastPos, match[0].begin);

		local text = _string.slice(match[1].begin, match[1].end);
		local tooltipID = _string.slice(match[2].begin, match[2].end);
		local modID = !::MSU.System.Tooltips.hasKey(myModID, tooltipID) && ::MSU.System.Tooltips.hasKey(::MSU.ID, tooltipID) ? ::MSU.ID : myModID;
		if (text.find("$") != null)
		{
			local key = split(_prefix + tooltipID, "+")[0];
			local extraData = ::MSU.System.Tooltips.getTooltip(modID, _prefix + tooltipID).Data;

			local fieldLastPos = 0;
			local fieldMatch;
			while (fieldMatch = __dynamicFieldRegexp.capture(text, fieldLastPos))
			{
				local field = this.__generateNestedTextFromObj(text.slice(fieldMatch[1].begin, fieldMatch[1].end), key, extraData);
				text = text.slice(0, fieldMatch[0].begin) + field + text.slice(fieldMatch[0].end);
				fieldLastPos = fieldMatch[0].end;
			}
		}

		if (text.find("Img/") != null)
		{
			text = text.slice(4);
			tag = "imgtooltip";
		}
		else
		{
			tag = "tooltip";
		}

		// We encode the tooltip tags and the mod id and tooltip id byte-wise as digits
		// so that any string manipulation like .toupper() does not break them.
		// We then decode these on the JS side.
		tag = this.encodeString(tag);
		ret += format("[%s=%s]%s[/%s]", tag, this.encodeString(format("%s.%s", modID, _prefix + tooltipID)), text, tag);
		lastPos = match[0].end;
	}

	return ret + _string.slice(lastPos);
}

local __removeRegexp = regexp("\\[\\d+=\\d+\\](.+)\\[/\\d+\\]");
::MSU.Class.TooltipsModAddon.removeAllFromString <- function( _string )
{
	_string = this.parseString(_string);
	local match;
	local ret = "";
	local lastPos = 0;
	while (match = __removeRegexp.capture(_string, lastPos))
	{
		ret += _string.slice(lastPos, match[0].begin) + _string.slice(match[1].begin, match[1].end);
		lastPos = match[0].end;
	}
	return ret + _string.slice(lastPos);
}

::MSU.Class.TooltipsModAddon.setTooltipImageKeywords <- function( _table )
{
	return ::MSU.System.Tooltips.setTooltipImageKeywords(this.Mod.getID(), _table);
}

// This allows mods to add custom dynamic handling for their own tooltip IDs.
// This must be a function that returns a string and
// matches the parameter signature of TooltipsModAddon.generateNestedTextFromObj
::MSU.Class.TooltipsModAddon.generateNestedTextFromObjCallback <- null;

::MSU.Class.TooltipsModAddon.__generateNestedTextFromObj <- function( _field, _key, _extraData )
{
	// MSU.__canCreateDummyPlayer is flipped by us during the first world init
	// so we can use it here to check whether that has been reached.
	if (_key != "Perk" && !::MSU.__canCreateDummyPlayer)
	{
		::logError("BB Objects must not be instantiated before hooks have completed, therefore object specific fields cannot be used in parseString until a FirstWorldInit bucket queued after " + ::NestedTooltips.ID)
		throw "trying to parseString with Object fields too early"
	}

	local funcs;

	if (_field == " ")
	{
		_field = "Name";
	}
	else
	{
		funcs = split(_field, ".");
		funcs.reverse();
		_field = funcs.pop();
	}

	local ret;
	if (this.generateNestedTextFromObjCallback != null)
	{
		if (::MSU.System.Tooltips.hasKey(this.getMod().getID(), _key))
		{
			ret = this.generateNestedTextFromObjCallback(_field, _key, _extraData);
		}
	}

	if (ret == null)
	{
		local filename = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_extraData).filename;
		switch (_key)
		{
			case "Perk":
				ret = ::Const.Perks.findById(::MSU.NestedTooltips.PerkIDByFilename[filename])[_field];
				break;

			case "Skill":
				ret = ::MSU.NestedTooltips.getObjFromFilename(filename, ::MSU.NestedTooltips.SkillObjectsByFilename).m[_field];
				break;

			case "Item":
				ret = ::MSU.NestedTooltips.getObjFromFilename(filename, ::MSU.NestedTooltips.ItemObjectsByFilename).m[_field];
				break;
		}
	}

	if (funcs != null)
	{
		while (funcs.len() != 0)
		{
			ret = compilestring(format("return @(_s) _s.%s", funcs.pop()))()(ret);
		}
	}

	return ret;
}
