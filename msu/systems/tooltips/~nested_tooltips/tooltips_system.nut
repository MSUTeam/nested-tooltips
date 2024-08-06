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

::MSU.Class.TooltipsSystem.hasKey <- function( _modID, _key )
{
	local fullKey = split(split(_key, "+")[0], ".");
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

// overwrite existing function
::MSU.Class.TooltipsSystem.getTooltip <- function( _modID, _identifier )
{
	local arr = split(_identifier, "+");
	local fullKey = split(arr[0], ".");
	local extraData;
	switch (arr.len())
	{
		case 1:
			break;

		case 2:
			extraData = arr[1];
			break;

		default:
			arr.slice(1).reduce(@(a, b) a + "+" + b);
			break;
	}

	local currentTable = this.Mods[_modID];
	for (local i = 0; i < fullKey.len(); ++i)
	{
		local currentKey = fullKey[i];
		currentTable = currentTable[currentKey];
	}
	return {
		Tooltip = currentTable,
		Data = extraData
	};
}
