// Can be a member inside TooltipsSystem once merged into MSU
local ImageKeywordMap = {};

::MSU.Class.TooltipsSystem.setTooltipImageKeywords <- function(_modID, _tooltipTable)
{
	local identifier, path;
	foreach (imagePath, id in _tooltipTable)
	{
		imagePath = "coui://gfx/" + imagePath;
		if (imagePath in ImageKeywordMap)
		{
			::logError(format("ImagePath %s already set by mod %s with tooltipID %s! Skipping this image keyword.", imagePath, _modID, id));
			continue;
		}
		identifier = {mod = _modID, id = id};
		ImageKeywordMap[imagePath] <- identifier;
	}
}

::MSU.Class.TooltipsSystem.passTooltipIdentifiers <- function()
{
	::NestedTooltips.UI.JSConnection.passTooltipIdentifiers(ImageKeywordMap);
}

::MSU.Class.TooltipsSystem.TooltipKeyData <- class
{
	// splits a key into two parts: an identifier and the "extradata", if any
	// the identifier is used to find the tooltip in
	// example: ::MSU.Class.TooltipKeyData("Perk+perk_collossus") -> { Identifier = "Perk", ExtraData = "perk_collossus"}
	Identifier = null;
	ExtraData = null;
	constructor( _key )
	{
		local arr = split(_key, "+");
		this.Identifier = arr[0];
		this.ExtraData = arr.slice(1);
	}
}
::MSU.Class.TooltipsSystem.hasKey <- function( _modID, _key )
{
	local fullKey = this.TooltipKeyData(_key).Identifier;
	local currentTable = this.Mods[_modID];
	for (local i = 0; i < fullKey.len(); ++i)
	{
		local currentKey = fullKey[i];
		if (!(currentKey in currentTable))
		{
			return false;
		}
		currentTable = currentTable[currentKey];
	}

	return true;
}
