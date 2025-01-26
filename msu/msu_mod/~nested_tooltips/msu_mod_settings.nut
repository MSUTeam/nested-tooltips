local nestedTooltipsPage = ::MSU.Mod.ModSettings.addPage("Nested Tooltips");

local updateTextLambda = @(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle();
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Bold", false, "Bold Text", "If enabled, nested tooltip hyperlinks text is shown in bold.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Italic", false, "Italic Text", "If enabled, nested tooltip hyperlinks text is italicized.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addBooleanSetting("NestedTooltips_Underline", true, "Underline Text", "If enabled, nested tooltip hyperlinks text is underlined.").addAfterChangeCallback(updateTextLambda);
nestedTooltipsPage.addColorPickerSetting("NestedTooltips_Color", "0,35,65,1.0", "Text Color", "The color for nested tooltip hyperlinks text.").addAfterChangeCallback(updateTextLambda);

nestedTooltipsPage.addRangeSetting("showDelay", 200, 0, 1000, 5, "Show Time", "Time until the tooltip appears after hovering an element, in milliseconds.");
nestedTooltipsPage.addRangeSetting("hideDelay", 100, 0, 1000, 5, "Hide Time", "Time until the tooltip disappears after leaving an element, in milliseconds.");
nestedTooltipsPage.addRangeSetting("lockDelay", 1000, 0, 10000, 5, "Hide Time", "Time until the tooltip disappears after leaving an element, in milliseconds.");
