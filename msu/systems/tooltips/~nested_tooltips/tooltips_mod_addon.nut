local __regexp = regexp("\\[([^/|]+)\\|([^\\]]+)\\]"); // \[(.+?)\|([\w\.]+)\] \[([^|]+)\|([\w\.]+)\]

// the __regexp should be a static member of the TooltipsModAddon class when merging into MSU
::MSU.Class.TooltipsModAddon.parseString <- function( _string, _prefix = "" )
{
	local myModID = this.getMod().getID();
	local match;
	local ret = "";
	local lastPos = 0;
	while (match = __regexp.capture(_string, lastPos))
	{
		ret += _string.slice(lastPos, match[0].begin);
		local text = _string.slice(match[1].begin, match[1].end);
		local tooltipID = _string.slice(match[2].begin, match[2].end);
		local modID = !::MSU.System.Tooltips.hasKey(myModID, tooltipID) && ::MSU.System.Tooltips.hasKey(::MSU.ID, tooltipID) ? ::MSU.ID : myModID;
		ret += format("[tooltip=%s.%s]%s[/tooltip]", modID, _prefix + tooltipID, text);
		lastPos = match[0].end;
	}

	return ret + _string.slice(lastPos);
}

::MSU.Class.TooltipsModAddon.setTooltipImageKeywords <- function( _table )
{
	return ::MSU.System.Tooltips.setTooltipImageKeywords(this.Mod.getID(), _table);
}

