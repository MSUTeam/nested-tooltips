// Show/hide callbacks for every MSU tooltip.
// Squirrel copies base class members into a subclass when the subclass is declared, so this must run
// after MSU declares ::MSU.Class.Tooltip and before it declares BasicTooltip and CustomTooltip.
// MSU's msu/systems/tooltips/load.nut includes ::IO.enumerateFiles("msu/systems/tooltips") in name order,
// and this filename sorts right after "abstract_tooltip" and before the "tooltips/" folder.
// msu/msu_mod/~nested_tooltips/msu_tooltips.nut logs an error if that order ever changes.

// Called with the tooltip's query data (incl. ExtraData) when its tooltip is created or removed in the UI
::MSU.Class.Tooltip.OnShowCallback <- null;
::MSU.Class.Tooltip.OnHideCallback <- null;

::MSU.Class.Tooltip.setOnShowCallback <- { function setOnShowCallback( _function )
{
	::MSU.requireFunction(_function);
	this.OnShowCallback = _function;
	return this;
}}.setOnShowCallback;

::MSU.Class.Tooltip.setOnHideCallback <- { function setOnHideCallback( _function )
{
	::MSU.requireFunction(_function);
	this.OnHideCallback = _function;
	return this;
}}.setOnHideCallback;

::MSU.Class.Tooltip.hasShowHideCallbacks <- { function hasShowHideCallbacks()
{
	return this.OnShowCallback != null || this.OnHideCallback != null;
}}.hasShowHideCallbacks;
