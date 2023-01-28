local __regexp = regexp("\\[([^|]+)\\|([\\w\\.]+)\\]"); // \[(.+?)\|([\w\.]+)\] \[([^|]+)\|([\w\.]+)\]

// the __regexp should be a static member of the TooltipsModAddon class when merging into MSU
::MSU.Class.TooltipsModAddon.parseString <- function( _string, _prefix = "" )
{
	local modID = this.Mod.getID();
	return ::MSU.String.regexReplace(_string, __regexp, @(_all, _text, _id) format("[tooltip=%s.%s]%s[/tooltip]", modID, _prefix + _id, _text));
}

