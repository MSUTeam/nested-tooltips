NestedTooltips.Hooks.WorldEventScreen_updateHeader = WorldEventScreen.prototype.updateHeader;
WorldEventScreen.prototype.updateHeader = function (_data)
{
	// VanillaFix: https://steamcommunity.com/app/365360/discussions/1/800093196998975135/
	// Pass the Title through XBBCODE so that nested tooltips in it are parsed properly.
	if (WorldEventIdentifier.Event.Title in _data && _data['title'] !== null)
	{
		_data.title = XBBCODE.process({
			text: _data.title,
		}).html;
	}

	NestedTooltips.Hooks.WorldEventScreen_updateHeader.call(this, _data);
}

NestedTooltips.Hooks.WorldEventScreen_renderListItem = WorldEventScreen.prototype.renderListItem;
WorldEventScreen.prototype.renderListItem = function (_container, _item)
{
	MSU.NestedTooltip.replaceIconImagesWithPlaceholders([_item]);

	NestedTooltips.Hooks.WorldEventScreen_renderListItem.call(this, _container, _item);

	MSU.NestedTooltip.replaceIconImagePlaceholders(_container);
};
