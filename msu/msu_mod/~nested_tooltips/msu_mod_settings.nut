local nestedTooltipsPage = ::MSU.Mod.ModSettings.addPage("Nested Tooltips");

local updateTextLambda = @(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle();
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Bold", false, "Bold Text", "If enabled, nested tooltip hyperlinks text is shown in bold.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Italic", false, "Italic Text", "If enabled, nested tooltip hyperlinks text is italicized.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Underline", true, "Underline Text", "If enabled, nested tooltip hyperlinks text is underlined.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addColorPickerSetting("NestedTooltips_Color", "0,35,65,1.0", "Text Color", "The color for nested tooltip hyperlinks text.").addAfterChangeCallback(updateTextLambda);

nestedTooltipsPage.addRangeSetting("showDelay", 150, 0, 1000, 5, "Show Time", "The time in milliseconds until the tooltip appears after hovering an element.");
nestedTooltipsPage.addRangeSetting("hideDelay", 50, 0, 1000, 5, "Hide Time", "The time in milliseconds until the tooltip disappears after leaving an element.");
nestedTooltipsPage.addRangeSetting("lockDelay", 500, 0, 10000, 5, "Lock Time", "The time in milliseconds until the tooltip locks and allows you to enter it with your mouse to access nested tooltips.");
