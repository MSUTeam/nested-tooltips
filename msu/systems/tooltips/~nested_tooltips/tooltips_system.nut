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
