// Mouse-driven tests of nested tooltip timing (bb_test.py moves the OS cursor).
// bb_test.py restores the MSU settings after the run, so a failed test leaves no changed setting behind.

// Hovers the first visible element matching _selector until its own tooltip is locked.
// Generators can't return values: the element's rect goes into _ctx.Source, the tooltip's into _ctx.Tooltip.
local function lockTooltipOf( _selector, _ctx )
{
	yield ::BBTest.evalJS(::BBTest.jsElementRect(_selector));
	_ctx.Source <- ::BBTest.LastJSResult;
	::BBTest.assert(_ctx.Source != null, "no visible element " + _selector);

	yield ::BBTest.moveMouse(_ctx.Source.x, _ctx.Source.y);
	local sel = ::BBTest.jsString(_selector);
	yield ::BBTest.waitForJS("(function(){ var t = MSU.NestedTooltip.TooltipStack.peek(); return t !== null && t.isLocked && t.sourceContainer.is(" + sel + "); })()", 3000);

	yield ::BBTest.evalJS(::BBTest.jsElementRect(".msu-nested-tooltip"));
	_ctx.Tooltip <- ::BBTest.LastJSResult;
	::BBTest.assert(_ctx.Tooltip != null, "locked tooltip not visible");
	::BBTest.log(format("source %i,%i  tooltip %i,%i - %i,%i", _ctx.Source.x, _ctx.Source.y, _ctx.Tooltip.left, _ctx.Tooltip.top, _ctx.Tooltip.right, _ctx.Tooltip.bottom));
}

local SkillSelector = ".skills-container .l-skill.msu-tooltip-source";

// The reported case: hover a skill of the active character, then move up onto its tooltip. The mouse crosses
// the map between them, where vanilla's tile hover must not close the locked tooltip before the grace delay.
::BBTest.add("locked skill tooltip survives moving up onto it", function() {
	::getModSetting("mod_msu", "graceDelay").set(800);
	local ctx = {};
	yield lockTooltipOf(SkillSelector, ctx);

	yield ::BBTest.moveMouse(ctx.Source.x, ctx.Tooltip.bottom - 15, 400);
	yield ::BBTest.waitMs(1200);
	yield ::BBTest.evalJS("MSU.NestedTooltip.TooltipStack.size()");
	::BBTest.assertEq(1, ::BBTest.LastJSResult, "the locked skill tooltip closed while the mouse moved up to it");
}, { Phase = ::BBTest.Phase.Tactical });

::BBTest.add("locked tooltip respects the grace delay when leaving onto the map", function() {
	::getModSetting("mod_msu", "graceDelay").set(800);
	local ctx = {};
	yield lockTooltipOf(SkillSelector, ctx);

	// Jump onto the map above the tooltip: the tooltip must stay for the grace delay
	yield ::BBTest.evalJS("({ x: window.innerWidth / 2, y: window.innerHeight / 3 })");
	local mapPoint = ::BBTest.LastJSResult;
	yield ::BBTest.moveMouse(mapPoint.x, mapPoint.y);
	yield ::BBTest.waitForJS("MSU.NestedTooltip.TooltipStack.isEmpty()", 3000);
	local closedAfter = ::BBTest.LastJSWaitMs.tointeger();
	::BBTest.log(format("tooltip closed %i ms after leaving its source (grace 800 ms)", closedAfter));
	::BBTest.assert(closedAfter >= 600, format("locked tooltip closed after %i ms, before the grace delay of 800 ms", closedAfter));

	// Tile tooltips are held back while the locked tooltip lives; the next movement over the map shows one.
	// A single jump to another tile: while the mouse keeps moving, a stale tooltip query can leave no tile
	// tooltip until the next movement (separate issue).
	yield ::BBTest.moveMouse(mapPoint.x + 40, mapPoint.y + 25);
	yield ::BBTest.waitForJS("MSU.NestedTooltip.TooltipStack.peek() !== null && MSU.NestedTooltip.TooltipStack.peek().tooltipParams.isTileTooltip === true", 2000);
}, { Phase = ::BBTest.Phase.Tactical });
