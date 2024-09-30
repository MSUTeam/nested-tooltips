MSU.NestedTooltip = {
	__regexp : /(?:\[|&#91;)tooltip=([\w\.]+?)\.(.+?)(?:\]|&#93;)(.*?)(?:\[|&#91;)\/tooltip(?:\]|&#93;)/gm,
	__imgRegexp : /(?:\[|&#91;)imgtooltip=([\w\.]+?)\.(.+?)(?:\]|&#93;)(.*?)(?:\[|&#91;)\/imgtooltip(?:\]|&#93;)/gm,
	__tooltipStack : [],
	__tooltipHideDelay : 100,
	__tooltipShowDelay : 200,
	__showTooltipTimeout : null,
	KeyImgMap : {},
	TextStyle: "",
	TileTooltipDiv : {
		container : $("<div class='msu-tile-div'/>").appendTo($(document.body)),
		cursorPos : {top:0, left:0},
		expand : function()
		{
			var self = this;
			Screens.NestedTooltipsJSConnection.queryZoomLevel(function(_params){
				var baseSize = _params.State == "tactical_state" ? 100 : 150;
				var squareSize = Math.floor(baseSize / _params.Zoom);
				self.container.height(squareSize);
				self.container.width(squareSize);
				self.container.show();
				self.container.offset({top: self.cursorPos.top - Math.floor(squareSize/2), left:  self.cursorPos.left - Math.floor(squareSize/2) });
			})
		},
		shrink : function()
		{
			this.container.height(0);
			this.container.width(0);
			this.container.hide();
			this.container.offset({top: 0, left: 0});
		},
		canShrink : function()
		{
			var sourceData = this.container.data("msu-nested");
			if (sourceData !== undefined && sourceData !== null)
			{
				var tooltipData = sourceData.tooltipContainer.data("msu-nested");
				if (tooltipData !== undefined && tooltipData.isLocked)
				{
					return false;
				}
			}
			return true;
		},
		bind : function(_params)
		{
			_params.isTileTooltip = true;
			MSU.NestedTooltip.bindToElement(this.container, _params);
		},
		unbind : function()
		{
			MSU.NestedTooltip.unbindFromElement(this.container);
		},
		trigger : function()
		{
			this.container.trigger('mouseenter.msu-tooltip-source');
		}
	},
	bindToElement : function (_element, _tooltipParams)
	{
		this.unbindFromElement(_element);
		_element.on('mouseenter.msu-tooltip-source', this.getBindFunction(_tooltipParams));
	},
	unbindFromElement : function (_element)
	{
		var data = _element.data('msu-nested');
		if (data !== undefined)
		{
			data.isHovered = false;
		}
		_element.off('.msu-tooltip-source');
		this.updateStack();
	},
	getBindFunction : function (_tooltipParams)
	{
		return function (_event)
		{
			var self = MSU.NestedTooltip;
			var tooltipSource = $(this);
			if (tooltipSource.data('msu-nested') !== undefined) return;
			clearTimeout(self.__showTooltipTimeout);
			self.__showTooltipTimeout = setTimeout(function(){
				self.onShowTooltipTimerExpired(tooltipSource, _tooltipParams);
			}, _tooltipParams.isTileTooltip === true ? 0 : self.__tooltipShowDelay);

			tooltipSource.on('mouseleave.msu-tooltip-loading', function (_event)
			{
				clearTimeout(self.__showTooltipTimeout);
				tooltipSource.off('mouseleave.msu-tooltip-loading');
			})

		}
	},
	onShowTooltipTimerExpired : function(_sourceContainer, _tooltipParams)
	{
		var self = this;
		clearTimeout(self.__showTooltipTimeout);
		_sourceContainer.off('.msu-tooltip-loading');
		// ghetto clone to get new ref
		_tooltipParams = JSON.parse(JSON.stringify(_tooltipParams));

		if (this.__tooltipStack.length > 0)
		{
			// check if this is within the same chain of nested tooltips, or if we need to clear the stack and start a new chain
			if (this.__tooltipStack[this.__tooltipStack.length -1].tooltip.container.find(_sourceContainer).length === 0)
			{
				self.clearStack();
			}
			// If we already have tooltips in the stack, we want to fetch the one from the first tooltip that will have received the entityId from the vanilla function
			else
			{
				$.each(this.__tooltipStack[0].dataToPass, function(_key, _value)
				{
					if (_key in _tooltipParams)
						return;
					_tooltipParams[_key] = _value;
				})
			}
		}
		Screens.TooltipScreen.mTooltipModule.notifyBackendQueryTooltipData(_tooltipParams, function (_backendData)
		{
			if (_backendData === undefined || _backendData === null)
		    {
		    	if (_tooltipParams.isTileTooltip)
		    		self.TileTooltipDiv.shrink();
		        return;
		    }
		    if (_tooltipParams.isTileTooltip)
		    	self.TileTooltipDiv.expand();


		    // vanilla behavior, when sth moved into tile while the data was being fetched
		    if (_tooltipParams.contentType === 'tile' || _tooltipParams.contentType === 'tile-entity')
		    	Screens.TooltipScreen.mTooltipModule.updateContentType(_backendData)

			self.createTooltip(_backendData, _sourceContainer, _tooltipParams);
		});
	},
	updateStack : function ()
	{
		for (var i = this.__tooltipStack.length - 1; i >= 0; i--)
		{
			var pairData = this.__tooltipStack[i];
			if ((pairData.source.isHovered && pairData.source.container.is(":visible")) || (pairData.tooltip.isHovered && pairData.tooltip.container.is(":visible")))
				return;
			this.removeTooltip(pairData, i);
		}
	},
	clearStack : function ()
	{
		for (var i = this.__tooltipStack.length - 1; i >= 0; i--)
		{
			this.removeTooltip(this.__tooltipStack[i]);
		}
	},
	isStackEmpty : function ()
	{
		return this.__tooltipStack.length === 0;
	},
	removeTopTooltip : function()
	{
		this.removeTooltip(this.__tooltipStack[this.__tooltipStack.length-1]);
	},
	removeTooltip : function (_pairData)
	{
		this.cleanSourceContainer(_pairData.source.container);
		this.cleanTooltipContainer(_pairData.tooltip.container);
		this.__tooltipStack.pop();
	},
	cleanSourceContainer : function(_sourceContainer)
	{
		_sourceContainer.off('.msu-tooltip-showing');
		var data = _sourceContainer.data("msu-nested");
		if (data === undefined)
			return;
		this.clearTimeouts(data);
		if (data.tooltipParams.isTileTooltip)
			this.TileTooltipDiv.shrink();
		_sourceContainer.removeData('msu-nested');
	},
	cleanTooltipContainer : function(_tooltipContainer)
	{
		var data = _tooltipContainer.data("msu-nested");
		this.clearTimeouts(data);
		_tooltipContainer.remove();
	},
	createTooltip : function (_backendData, _sourceContainer, _tooltipParams)
	{
		var self = this;
		var tooltipContainer = this.getTooltipFromData(_backendData, _tooltipParams.contentType);
		var sourceData = {
			container : _sourceContainer,
			updateStackTimeout : null,
			isHovered : true,
			tooltipContainer : tooltipContainer,
			tooltipParams : _tooltipParams
		};
		_sourceContainer.data('msu-nested', sourceData);
		var tooltipData = {
			container : tooltipContainer,
			updateStackTimeout : null,
			isHovered : false,
			isLocked : false,
			sourceContainer : _sourceContainer
		};

		tooltipContainer.data('msu-nested', tooltipData);
		var stackData = {
			source : sourceData,
			tooltip : tooltipData
		}

		// Add data that we'll want to pass to any nested tooltips, such as entityId
		if (this.__tooltipStack.length == 0)
		{
			var dataToPass = {};
			$.each(_tooltipParams, function(_key, _value)
			{
				if (_key === "contentType" || _key === "elementId")
					return;
				dataToPass[_key] = _value;
			})
			stackData.dataToPass = dataToPass;
		}
		this.__tooltipStack.push(stackData);

		this.addTooltipLockHandler(tooltipContainer, _sourceContainer);

		this.addSourceContainerMouseHandler(_sourceContainer);

		this.addTooltipContainerMouseHandler(tooltipContainer);

		$('body').append(tooltipContainer)
		this.positionTooltip(tooltipContainer, _backendData, _sourceContainer);
	},
	addTooltipLockHandler : function(_tooltipContainer, _sourceContainer)
	{
		var nestedItems = _tooltipContainer.find(".msu-nested-tooltip");
		if (nestedItems.length == 0)
			return;
		var self = this;

		_tooltipContainer.addClass("msu-nested-tooltips-within");
		var progressImage = $("<div class='tooltip-progress-bar'/>")
			.appendTo(_tooltipContainer)

		progressImage.velocity({ opacity: 0 },
		{
	        duration: 1000,
			begin: function()
			{
				progressImage.css("opacity", 1)
	        },
			complete: function()
			{
				progressImage.css("opacity", 1);
				progressImage.css("background-image", 'url("coui://gfx/ui/icons/icon_locked.png")');
				var data = _tooltipContainer.data('msu-nested');
				if (data === undefined)
				{
					return;
				}
				data.isLocked = true;
	        }
	   });

		_sourceContainer.mousedown(function(_event){
			if (MSU.Keybinds.isMousebindPressed(MSU.ID, "LockTooltip"))
			{
				_event.stopPropagation();
				progressImage.velocity("finish");
			}
		})
	},
	addSourceContainerMouseHandler : function(_sourceContainer)
	{
		var self = this;
		_sourceContainer.on('mouseenter.msu-tooltip-showing', function(_event)
		{
			var sourceData = $(this).data('msu-nested');
			self.clearTimeouts(sourceData);
			sourceData.isHovered = true;
			sourceData.updateStackTimeout = setTimeout(self.updateStack.bind(self), self.__tooltipHideDelay);
		});
		_sourceContainer.on('mouseleave.msu-tooltip-showing remove.msu-tooltip-showing', function (_event)
		{
			var sourceData = $(this).data('msu-nested');
			self.clearTimeouts(sourceData);
			sourceData.isHovered = false;
			sourceData.updateStackTimeout = setTimeout(self.updateStack.bind(self), self.__tooltipHideDelay);
		});
	},
	addTooltipContainerMouseHandler : function(_tooltipContainer)
	{
		var self = this;
		_tooltipContainer.on('mouseenter.msu-tooltip-container', function (_event)
		{
			var tooltipData = $(this).data("msu-nested");
			self.clearTimeouts(tooltipData);
			tooltipData.isHovered = true;
			if (!tooltipData.isLocked)
			{
				_tooltipContainer.hide();
				setTimeout(function(){
					self.cleanSourceContainer(tooltipData.sourceContainer);
					return;
				}, self.__tooltipHideDelay)
			}
			else
			{
				$(".ui-control-tooltip-module").addClass("msu-nested-tooltip-not-hovered");
				_tooltipContainer.removeClass("msu-nested-tooltip-not-hovered");
			}
		});
		_tooltipContainer.on('mouseleave.msu-tooltip-container', function (_event)
		{
			var tooltipData = $(this).data("msu-nested");
			self.clearTimeouts(tooltipData);
			tooltipData.isHovered = false;
			tooltipData.updateStackTimeout = setTimeout(self.updateStack.bind(self), self.__tooltipHideDelay);
		});
		_tooltipContainer.on('mousedown.msu-tooltip-container', function (_event)
		{
			if (_event.which == 1)
			{
				_event.stopPropagation();
				self.removeTopTooltip();
				if (self.__tooltipStack.length > 0)
				{
					self.__tooltipStack[self.__tooltipStack.length-1].tooltip.container.trigger('mouseenter.msu-tooltip-container');
				}
			}
		});
	},
	getTooltipFromData : function (_backendData, _contentType)
	{
		var tempContainer = Screens.TooltipScreen.mTooltipModule.mContainer;
		var ret = $('<div class="tooltip-module ui-control-tooltip-module"/>');
		Screens.TooltipScreen.mTooltipModule.mContainer = ret;
		Screens.TooltipScreen.mTooltipModule.buildFromData(_backendData, false, _contentType);
		this.parseImgPaths(ret);
		Screens.TooltipScreen.mTooltipModule.mContainer = tempContainer;
		return ret;
	},
	positionTooltip : function (_tooltip, _backendData, _targetDIV)
	{
		var tempContainer = Screens.TooltipScreen.mTooltipModule.mContainer;
		Screens.TooltipScreen.mTooltipModule.mContainer = _tooltip;
		if (_targetDIV.is(this.TileTooltipDiv.container))
		{
			Screens.TooltipScreen.mTooltipModule.setupTileTooltip();
		}
		else
		{
			Screens.TooltipScreen.mTooltipModule.setupUITooltip(_targetDIV, _backendData);
		}
		Screens.TooltipScreen.mTooltipModule.mContainer = tempContainer;
	},
	getTooltipLinkHTML : function (_mod, _id, _text)
	{
		_text = _text || "";
		return '<div class="msu-nested-tooltip" style="' + this.TextStyle + '" data-msu-nested-mod="' + _mod + '" data-msu-nested-id="' + _id + '">' + _text + '</div>';
	},
	getTooltipImageHTML : function (_mod, _id, _src)
	{
		var img = '<img msu-nested="true" src="coui://' + _src + '"</img>';
		return this.getTooltipLinkHTML(_mod, _id, img);
	},
	parseImageText : function (_text)
	{
		var self = this;
		return _text.replace(this.__imgRegexp, function( _match, _mod, _id, _text)
		{
			var ret = self.getTooltipImageHTML(_mod, _id, _text);
			return ret;
		})
	},
	parseText : function (_text)
	{
		var self = this;
		return _text.replace(this.__regexp, function (_match, _mod, _id, _text)
		{
			return self.getTooltipLinkHTML(_mod, _id, _text);
		})
	},
	parseImgPaths : function (_jqueryObj)
	{
		var self = this;
		_jqueryObj.find('img').each(function ()
		{
			if (this.src in self.KeyImgMap && (this.hasAttribute("msu-nested") != true))
			{
				var entry = self.KeyImgMap[this.src];
				var img = $(this);
				var div = $(self.getTooltipLinkHTML(entry.mod, entry.id));
				img.after(div);
				div.append(img.detach());
			}
		})
	},
	clearTimeouts : function(_data)
	{
		if (_data.updateStackTimeout !== undefined && _data.updateStackTimeout !== null)
		{
			clearTimeout(_data.updateStackTimeout);
			_data.updateStackTimeout = null;
		}
	},
	reloadTooltip : function(_element, _newParams)
	{
		if (this.isStackEmpty())
			return;
		var sourceData = this.__tooltipStack[0].source;
		var sourceContainer = sourceData.container;
		var sourceParams = sourceData.tooltipParams;
		if (_element !== undefined && !_element.is(sourceContainer))
			return;
		this.clearStack();
		this.unbindFromElement(sourceContainer);
		this.bindToElement(sourceContainer, _newParams || sourceParams);
		sourceContainer.trigger('mouseenter.msu-tooltip-source');
	},
}
MSU.XBBCODE_process = XBBCODE.process;
// I hate this but the XBBCODE plugin doesn't allow dynamically adding tags
// there's a fork that does here https://github.com/patorjk/Extendible-BBCode-Parser
// but we'd have to tweak it a bunch to add the vanilla tags
// it also changes some other stuff and is somewhat out of date at this point
// then again, the one used in vanilla is probably even more outdated
XBBCODE.process = function (config)
{
	var ret = MSU.XBBCODE_process.call(this, config);
	ret.html = MSU.NestedTooltip.parseImageText(ret.html);
	ret.html = MSU.NestedTooltip.parseText(ret.html)
	return ret;
}

$.fn.bindTooltip = function (_data)
{
	MSU.NestedTooltip.bindToElement(this, _data);
};

$.fn.unbindTooltip = function ()
{
	MSU.NestedTooltip.unbindFromElement(this);
};

$(document).on('mouseenter.msu-tooltip-source', '.msu-nested-tooltip', function()
{
	var data = {
		contentType : 'msu-nested-tooltip',
		elementId : this.dataset.msuNestedId,
		modId : this.dataset.msuNestedMod
	}
	MSU.NestedTooltip.getBindFunction(data).call(this);
})

TooltipModule.prototype.showTileTooltip = function()
{
	if (this.mCurrentData === undefined || this.mCurrentData === null)
	{
		return;
	}
	MSU.NestedTooltip.updateStack();
	if (MSU.NestedTooltip.isStackEmpty())
	{
		MSU.NestedTooltip.TileTooltipDiv.bind(this.mCurrentData);
		MSU.NestedTooltip.TileTooltipDiv.cursorPos = {top: this.mLastMouseY, left: this.mLastMouseX};
		MSU.NestedTooltip.TileTooltipDiv.trigger();
	}
};

MSU.TooltipModule_hideTileTooltip = TooltipModule.prototype.hideTileTooltip;
TooltipModule.prototype.hideTileTooltip = function()
{
	if (MSU.NestedTooltip.TileTooltipDiv.canShrink())
	{
		MSU.NestedTooltip.TileTooltipDiv.shrink()
		MSU.NestedTooltip.TileTooltipDiv.unbind();
	}
	MSU.TooltipModule_hideTileTooltip.call(this);
};

$.fn.updateTooltip = function (_newParams)
{
    if (Screens.Tooltip === null || !Screens.Tooltip.isConnected())
    {
        return;
    }

    var tooltip = Screens.Tooltip.getModule('TooltipModule');
    if (tooltip !== null)
    {
        MSU.NestedTooltip.reloadTooltip(this, _newParams);
	}
};

TooltipModule.prototype.reloadTooltip = function()
{
	MSU.NestedTooltip.reloadTooltip();
};

TooltipModule.prototype.hideTooltip = function()
{
    MSU.NestedTooltip.clearStack();
};

MSU.TooltipModule_setupTileTooltip = TooltipModule.prototype.setupTileTooltip;
TooltipModule.prototype.setupTileTooltip = function()
{
	MSU.TooltipModule_setupTileTooltip.call(this);

	// We do the mostly the same calculations as vanilla at first for getting the top position of our tooltip
	var containerHeight = this.mContainer.outerHeight(true);
	var posTop = this.mLastMouseY + (this.mCursorYOffset === 0 ? (this.mCursorHeight / 2) : (this.mCursorHeight - ((this.mCursorHeight / 2) - this.mCursorYOffset)) );

	if ((posTop + containerHeight) > this.mParent.height())
	{
		posTop = this.mLastMouseY - (this.mCursorYOffset === 0 ? ((this.mCursorHeight / 2) + containerHeight) : (this.mCursorYOffset + containerHeight));
	}

	// If the window would go beyond the top of the screen, we move it so it starts exactly at the top
	if (posTop < 0) posTop = 0;		// This line is new

	// apply the calculated topPos
	this.mContainer.css({ top: posTop });
}

MSU.TooltipModule_setupUITooltip = TooltipModule.prototype.setupUITooltip;
TooltipModule.prototype.setupUITooltip = function(_targetDIV, _data)
{
	MSU.TooltipModule_setupUITooltip.call(this, _targetDIV, _data);

	// We do the mostly the same calculations as vanilla at first for getting the top position of our tooltip
	if(_targetDIV === undefined) return;
	var offsetY = ('yOffset' in _data) ? _data.yOffset : this.mDefaultYOffset;
	if (offsetY !== null)
	{
		if (typeof(offsetY) === 'string')
		{
			offsetY = parseInt(offsetY, 10);
		}
		else if (typeof(offsetY) !== 'number')
		{
			offsetY = 0;
		}
	}

	var targetOffset	= _targetDIV.offset();
	var elementHeight	= _targetDIV.outerHeight(true);
	var containerHeight = this.mContainer.outerHeight(true);
	// By default we want the tooltips shown on top of the UI-Element
	var offsets = {
		top  : targetOffset.top - containerHeight - offsetY,
		left : targetOffset.left
	}

	// If that would overflow the top of the screen, we instead display them below our cursor
	if (offsets.top < 0)
	{
		offsets.top = targetOffset.top + elementHeight + offsetY;
	}

	// If that would overflow the bottom of the screen, we instead display it starting directly at the top of the screen
	var wnd = this.mParent; // $(window);
	if ((offsets.top + containerHeight + offsetY) > wnd.height())
	{
		offsets.top = 10;
	}
	// We also move it to the left or right (depending on the half of the screen we're in) to make sure it's not overlapping the cursor
	if (targetOffset.left > (wnd.width() / 2))
		offsets.left = targetOffset.left + _targetDIV.outerWidth(true) - this.mContainer.outerWidth(true);
	else
		offsets.left = targetOffset.left;

	this.mContainer.css(offsets);
}

