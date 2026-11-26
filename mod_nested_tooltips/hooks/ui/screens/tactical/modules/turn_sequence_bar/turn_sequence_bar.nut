::NestedTooltips.MH.hook("scripts/ui/screens/tactical/modules/turn_sequence_bar/turn_sequence_bar", function(q) {
	// While an Entity tooltip is open, its entity holds the bar's hover selection (vanilla's arrow over the portrait).
	// Vanilla's tile hover calls selectEntity/deselectEntity on every tile change; meanwhile they only record
	// vanilla's hovered entity, which gets the selection back when the last Entity tooltip closes.
	q.m.NestedTooltips_IsTooltipSelection <- false;
	q.m.NestedTooltips_VanillaHoverEntity <- null;

	q.selectEntity = @(__original) { function selectEntity( _entity )
	{
		if (!this.m.NestedTooltips_IsTooltipSelection)
			return __original(_entity);

		if (_entity != null)
			this.m.NestedTooltips_VanillaHoverEntity = _entity;
	}}.selectEntity;

	q.deselectEntity = @(__original) { function deselectEntity()
	{
		if (!this.m.NestedTooltips_IsTooltipSelection)
			return __original();

		this.m.NestedTooltips_VanillaHoverEntity = null;
	}}.deselectEntity;

	// _entity null: no Entity tooltip open any more, restore vanilla's hover selection
	q.nestedTooltips_setTooltipEntity <- { function nestedTooltips_setTooltipEntity( _entity )
	{
		if (_entity != null)
		{
			if (!this.m.NestedTooltips_IsTooltipSelection)
				this.m.NestedTooltips_VanillaHoverEntity = this.m.ActiveEntityMouseHover;
			this.m.NestedTooltips_IsTooltipSelection = false;
			this.selectEntity(_entity);
			this.m.NestedTooltips_IsTooltipSelection = true;
			return;
		}

		if (!this.m.NestedTooltips_IsTooltipSelection)
			return;

		this.m.NestedTooltips_IsTooltipSelection = false;
		this.deselectEntity();
		local hover = this.m.NestedTooltips_VanillaHoverEntity;
		this.m.NestedTooltips_VanillaHoverEntity = null;
		if (hover != null && hover.isAlive())
		{
			this.selectEntity(hover);
		}
	}}.nestedTooltips_setTooltipEntity;
});
