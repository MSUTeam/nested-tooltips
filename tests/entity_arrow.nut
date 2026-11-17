// The vanilla arrow over an entity while an Entity+ tooltip of it is open (Tooltip OnShow/OnHide callbacks).

local function isArrowVisible( _entity )
{
	return _entity.getSprite("arrow").Visible;
}

local function getAliveEnemy()
{
	foreach (e in ::BBTest.getEnemies())
	{
		if (e.isAlive())
			return e;
	}
	::BBTest.fail("no alive enemy");
}

::BBTest.add("tooltip show/hide callbacks exist on all tooltip classes", function() {
	::BBTest.assert("setOnShow" in ::MSU.Class.Tooltip, "abstract Tooltip has no setOnShow");
	::BBTest.assert("setOnShow" in ::MSU.Class.BasicTooltip, "BasicTooltip has no setOnShow (load order)");
	::BBTest.assert("setOnShow" in ::MSU.Class.CustomTooltip, "CustomTooltip has no setOnShow (load order)");
	::BBTest.assert(!::MSU.Class.BasicTooltip("a", "b").hasShowHideCallbacks(), "a new tooltip has callbacks");
	::BBTest.assert(::MSU.System.Tooltips.getTooltip(::MSU.ID, "Entity+1").Tooltip.hasShowHideCallbacks(), "Entity tooltip has no callbacks");
});

local function show( _entity, _extra = "" )
{
	::NestedTooltips.UI.JSConnection.onTooltipShown({ modId = ::MSU.ID, elementId = "Entity+" + _entity.getID() + _extra });
}

local function hide( _entity, _extra = "" )
{
	::NestedTooltips.UI.JSConnection.onTooltipHidden({ modId = ::MSU.ID, elementId = "Entity+" + _entity.getID() + _extra });
}

// Waits until the arrows of _ctx.A and _ctx.B are as expected (hiding fades out)
local function expectArrows( _ctx, _a, _b, _step )
{
	_ctx.ExpectA <- _a;
	_ctx.ExpectB <- _b;
	yield ::BBTest.waitUntil(@(c) c.A.getSprite("arrow").Visible == c.ExpectA && c.B.getSprite("arrow").Visible == c.ExpectB,
		1000, format("%s: arrows A=%s B=%s", _step, _a + "", _b + ""), _ctx);
}

// Only the innermost open entity tooltip has the arrow
::BBTest.add("only the innermost entity tooltip shows the arrow", function() {
	local enemies = ::BBTest.getEnemies().filter(@(_i, _e) _e.isAlive());
	::BBTest.assert(enemies.len() >= 2, "need two alive enemies");
	local ctx = { A = enemies[0], B = enemies[1] };
	yield expectArrows(ctx, false, false, "before");

	show(ctx.A, ",cssClass:x");
	yield expectArrows(ctx, true, false, "A");
	show(ctx.B);
	yield expectArrows(ctx, false, true, "A > B");
	show(ctx.A);
	yield expectArrows(ctx, true, false, "A > B > A");
	hide(ctx.A);
	yield expectArrows(ctx, false, true, "back to A > B");
	hide(ctx.B);
	yield expectArrows(ctx, true, false, "back to A");
	hide(ctx.A, ",cssClass:x");
	yield expectArrows(ctx, false, false, "all closed");
	::BBTest.assertEq(0, ::MSU.NestedTooltips.EntityArrowStack.len());

	// showArrow:false: no arrow and the outer entity keeps its arrow
	show(ctx.A);
	show(ctx.B, ",showArrow:false");
	yield expectArrows(ctx, true, false, "A > B without arrow");
	hide(ctx.B, ",showArrow:false");
	hide(ctx.A);
	yield expectArrows(ctx, false, false, "opt-out closed");

	// Unknown entity: no error, nothing left behind
	::NestedTooltips.UI.JSConnection.onTooltipShown({ modId = ::MSU.ID, elementId = "Entity+999999" });
	::NestedTooltips.UI.JSConnection.onTooltipHidden({ modId = ::MSU.ID, elementId = "Entity+999999" });
	::BBTest.assertEq(0, ::MSU.NestedTooltips.EntityArrowStack.len());
}, { Phase = ::BBTest.Phase.Tactical });

// Hover a real Entity+ tooltip source with the mouse: the arrow shows with the tooltip and hides when it closes
::BBTest.add("hovering an Entity+ tooltip source shows the entity's arrow", function() {
	::getModSetting("mod_msu", "graceDelay").set(300);
	local entity = getAliveEnemy();
	yield ::BBTest.evalJS("(function(){ $('#bbtest-entity-link').remove();"
		+ " var e = $('<div id=\"bbtest-entity-link\" style=\"position:absolute; left:50%; top:40%; width:120px; height:30px; background:red; z-index:100000;\"/>').appendTo($(document.body));"
		+ " e.bindTooltip({ contentType: 'msu-generic', modId: MSU.ID, elementId: 'Entity+" + entity.getID() + "' }); return true; })()");
	yield ::BBTest.evalJS(::BBTest.jsElementRect("#bbtest-entity-link"));
	local rect = ::BBTest.LastJSResult;
	::BBTest.assert(rect != null, "test link not visible");

	yield ::BBTest.moveMouse(rect.x, rect.y);
	yield ::BBTest.waitForJS("MSU.NestedTooltip.TooltipStack.size() === 1 && MSU.NestedTooltip.TooltipStack.peek().notifyShowHide === true", 3000);
	yield ::BBTest.waitUntil(@(c) c.entity.getSprite("arrow").Visible, 1000, "arrow shown with the tooltip", { entity = entity });

	// Away onto the map, far from the link and its tooltip
	yield ::BBTest.moveMouse(rect.x, rect.y + 300);
	yield ::BBTest.waitForJS("MSU.NestedTooltip.TooltipStack.isEmpty() || !MSU.NestedTooltip.TooltipStack.peek().notifyShowHide", 3000);
	yield ::BBTest.waitUntil(@(c) !c.entity.getSprite("arrow").Visible, 1000, "arrow hidden with the tooltip", { entity = entity });

	yield ::BBTest.evalJS("$('#bbtest-entity-link').remove(), true");
}, { Phase = ::BBTest.Phase.Tactical });
