// Adjustable timer in Mod Setting for auto-locking the tooltip.
local generalPage = ::NestedTooltips.Mod.ModSettings.addPage("general", "General");
local showDelaySetting = generalPage.addRangeSetting("showDelay", 200, 0, 1000, 5, "Show Time", "Time until the tooltip appears after hovering an element, in milliseconds.");
local hideDelaySetting = generalPage.addRangeSetting("hideDelay", 100, 0, 1000, 5, "Hide Time", "Time until the tooltip disappears after leaving an element, in milliseconds.");
local lockDelaySetting = generalPage.addRangeSetting("lockDelay", 1000, 0, 10000, 5, "Hide Time", "Time until the tooltip disappears after leaving an element, in milliseconds.");
