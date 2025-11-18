local __regexp = regexp("\\[([^\\[\\]]+)\\|([^\\[\\]]+)\\]"); // \[(.+?)\|([\w\.]+)\] \[([^|]+)\|([\w\.]+)\]

// Squirrel regex cannot match empty strings, so we require a blank 1 length string
// instead of empty string as the default alias for "$Name$"
local __dynamicFieldRegexp = regexp("\\$([^\\$]+)\\$");

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
		if (modID == ::MSU.ID)
		{
			local key = split(_prefix + tooltipID, "+")[0];
			local extraData = ::MSU.System.Tooltips.getTooltip(modID, _prefix + tooltipID).Data;

			local fieldLastPos = 0;
			local fieldMatch;
			while (fieldMatch = __dynamicFieldRegexp.capture(text, fieldLastPos))
			{
				local field = this.generateNestedTextFromObj(text.slice(fieldMatch[1].begin, fieldMatch[1].end), key, extraData);
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

		ret += format("[%s=%s.%s]%s[/%s]", tag, modID, _prefix + tooltipID, text, tag);
		lastPos = match[0].end;
	}

	return ret + _string.slice(lastPos);
}

::MSU.Class.TooltipsModAddon.setTooltipImageKeywords <- function( _table )
{
	return ::MSU.System.Tooltips.setTooltipImageKeywords(this.Mod.getID(), _table);
}

::MSU.Class.TooltipsModAddon.generateNestedTextFromObj <- function( _field, _key, _extraData )
{
	// MSU.__canCreateDummyPlayer is flipped by us during the FirstWorldInit bucket
	// so we can use it here to check whether that bucket has been reached.
	if (_key != "Perk" && !::MSU.__canCreateDummyPlayer)
	{
		::logError("BB Objects must not be instantiated before hooks have completed, therefore object specific fields cannot be used in parseString until a FirstWorldInit bucket queued after " + ::NestedTooltips.ID)
		throw "trying to parseString with Object fields too early"
	}

	local isLower = false;

	if (_field == " ")
	{
		_field = "Name";
	}
	else
	{
		local idx = _field.find(".tolower()");
		if (idx != null)
		{
			_field = _field.slice(0, idx);
			isLower = true;
		}
	}

	local filename = ::MSU.System.Tooltips.parseExtraDataForNestedTooltip(_extraData).filename;
	local obj;
	switch (_key)
	{
		case "Perk":
			obj = ::Const.Perks.findById(::MSU.NestedTooltips.PerkIDByFilename[filename]);
			break;

		case "Skill":
			obj = ::MSU.System.Tooltips.getObjFromFilename(filename, ::MSU.NestedTooltips.SkillObjectsByFilename).m;
			break;

		case "Item":
			obj = ::MSU.System.Tooltips.getObjFromFilename(filename, ::MSU.NestedTooltips.ItemObjectsByFilename).m;
			break;
	}

	return isLower ? obj[_field].tolower() : obj[_field];
}
