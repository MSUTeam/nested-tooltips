local nestedTooltipsPage = ::MSU.Mod.ModSettings.addPage("Nested Tooltips");
local boldSetting = nestedTooltipsPage.addBooleanSetting("NestedTooltips_Bold", false, "Bold Text", "If enabled, nested tooltip hyperlinks text is shown in bold.");
boldSetting.addAfterChangeCallback(@(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle());
local italicSetting = nestedTooltipsPage.addBooleanSetting("NestedTooltips_Italic", false, "Italic Text", "If enabled, nested tooltip hyperlinks text is italicized.");
italicSetting.addAfterChangeCallback(@(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle());
local underlineSetting = nestedTooltipsPage.addBooleanSetting("NestedTooltips_Underline", true, "Underline Text", "If enabled, nested tooltip hyperlinks text is underlined.");
underlineSetting.addAfterChangeCallback(@(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle());
local colorSetting = nestedTooltipsPage.addColorPickerSetting("NestedTooltips_Color", "0,35,65,1.0", "Text Color", "The color for nested tooltip hyperlinks text.");
colorSetting.addAfterChangeCallback(@(_oldValue) ::NestedTooltips.UI.JSConnection.updateNestedTooltipTextStyle());
