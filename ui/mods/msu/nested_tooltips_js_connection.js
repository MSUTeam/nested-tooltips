var NestedTooltipsJSConnection = function(_parent)
{
    MSUBackendConnection.call(this);
}

NestedTooltipsJSConnection.prototype = Object.create(MSUBackendConnection.prototype);
Object.defineProperty(NestedTooltipsJSConnection.prototype, 'constructor', {
    value: NestedTooltipsJSConnection,
    enumerable: false,
    writable: true
});

registerScreen("NestedTooltipsJSConnection", new NestedTooltipsJSConnection());

NestedTooltipsJSConnection.prototype.setTooltipImageKeywords = function (_table)
{
	$.each(_table, function(_key, _value){
		MSU.NestedTooltip.KeyImgMap[_key] = _value;
	})
}

NestedTooltipsJSConnection.prototype.queryZoomLevel = function (_callback)
{
	SQ.call(this.mSQHandle, "queryZoomLevel", null, _callback);
}
