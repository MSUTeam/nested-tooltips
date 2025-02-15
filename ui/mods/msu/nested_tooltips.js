MSU.NestedTooltip = {
	__regexp : /(?:\[|&#91;)tooltip=([\w\.]+?)\.(.+?)(?:\]|&#93;)(.*?)(?:\[|&#91;)\/tooltip(?:\]|&#93;)/gm,
	__imgRegexp : /(?:\[|&#91;)imgtooltip=([\w\.]+?)\.(.+?)(?:\]|&#93;)(.*?)(?:\[|&#91;)\/imgtooltip(?:\]|&#93;)/gm,
	__tooltipStack : [],
	__passThroughData : {},
	Events : {
		__lastMouseX : 0,
		__lastMouseY : 0,
		__Timers : {
			"SHOW" : null,
			"HIDE" : null,
			"LOCK" : null,
		},
		__TimerDelayGetters : {
			"SHOW" :  function(){ return MSU.getSettingValue(MSU.ID, "showDelay")}, // default 200,
			"HIDE" :  function(){ return MSU.getSettingValue(MSU.ID, "hideDelay")}, // default 100,
			"LOCK" :  function(){ return MSU.getSettingValue(MSU.ID, "lockDelay")}, // default 1000,
		},
		setTimer : function(_type, _func)
		{
			if (!(_type in this.__Timers))
			{
				throw "Type " + _type + " not a valid MSU.NestedTooltip.Timer!"
			}
			if (this.__Timers[_type] != null) {
				clearTimeout(this.__Timers[_type]);
			}
			this.__Timers[_type] = setTimeout(_func, this.__TimerDelayGetters[_type]());
		},
		cancelTimer : function(_type)
		{
			if (!(_type in this.__Timers))
			{
				throw "Type " + _type + " not a valid MSU.NestedTooltip.Timer!"
			}
			clearTimeout(this.__Timers[_type]);
			this.__Timers[_type] = null;
		},

        // Combined handler for source initialization
        // classes: .msu-tooltip-source, .msu-nested-tooltip-source
        // msu-tooltip-source -> bottom element, a traditional tooltip source like a skill icon or something
        // msu-nested-tooltip-source -> a link within a tooltip
        onSourceEnter : function(event) {
        	MSU.NestedTooltip.Events.cancelTimer("SHOW");
            var $element = $(event.currentTarget);

            // Handle nested tooltip source
            if ($element.hasClass('msu-nested-tooltip-source')) {
                var data = {
                    contentType : 'msu-nested-tooltip-source',
                    elementId : this.dataset.msuNestedId,
                    modId : this.dataset.msuNestedMod
                };
                MSU.NestedTooltip.bindToElement($element, data);
            }

            // Common source handling
            if ($element.data("msu-nested") === undefined) {
                MSU.NestedTooltip.Events.setTimer("SHOW", function() {
                    MSU.NestedTooltip.onShowTooltipTimerExpired($element);
                });
            }
        },
        onSourceLeave : function(event) {
            MSU.NestedTooltip.Events.cancelTimer("SHOW");
            MSU.NestedTooltip.Events.setTimer("HIDE", MSU.NestedTooltip.updateStack.bind(MSU.NestedTooltip));
        },

        onTooltipEnter : function(event)
        {
        	var $element = $(this);
        	var data = $element.data("msu-nested");
        	if (!data || !data.isLocked) {
        	    $element.hide();
        	    MSU.NestedTooltip.Events.setTimer("HIDE", MSU.NestedTooltip.updateStack.bind(MSU.NestedTooltip));
        	    return;
        	}
        	data.isHovered = true;
    		$(".ui-control-tooltip-module").addClass("msu-nested-tooltip-not-hovered");
    		$element.removeClass("msu-nested-tooltip-not-hovered");
        },

        onTooltipLeave : function(event)
        {
        	var $element = $(this);
        	var data = $element.data("msu-nested");
        	if (data) data.isHovered = false;
        	MSU.NestedTooltip.Events.setTimer("HIDE", MSU.NestedTooltip.updateStack.bind(MSU.NestedTooltip));
        },

        // Combined lock handler for both mouse and keyboard
        onLockRequest : function(event) {
            var isKeyboard = event.type === 'keydown';
            // check for item moving due to click
            var shouldLock = isKeyboard ?
                MSU.Keybinds.isKeybindPressed(MSU.ID, "LockTooltipKeyboard", event) :
                MSU.Keybinds.isMousebindPressed(MSU.ID, "LockTooltip");

            if (!shouldLock){
            	return;
            };

            var progressImage;
            if (isKeyboard) {
                var stackData = MSU.NestedTooltip.getTopOfStack();
                if (!stackData) return;
                progressImage = stackData.tooltip.container.find(".tooltip-progress-bar");
            } else {
                progressImage = $(this).data("msu-nested").tooltipContainer.find(".tooltip-progress-bar");
            }

            if (!progressImage) return;
            event.stopPropagation();
            progressImage.velocity("finish");
        },

        onTooltipClick : function(event) {
            if (event.which !== 1) return;

            event.stopPropagation();
            MSU.NestedTooltip.removeTopOfStack();

            if (!MSU.NestedTooltip.isStackEmpty()) {
                MSU.NestedTooltip.getTopOfStack().tooltip.container
                    .trigger('mouseenter.msu-tooltip-container');
            }
        },

        // to confirm that we are still hovering an element, as .locked stuff isn't reliable. We should probably move this event handler to MSU.
        onMouseMove: function(event) {
            this.__lastMouseX = event.clientX;
            this.__lastMouseY = event.clientY;
        },
        isActuallyHovered: function(element) {
            var mouseX = MSU.NestedTooltip.Events.__lastMouseX;
            var mouseY = MSU.NestedTooltip.Events.__lastMouseY;
            var elementUnderCursor = document.elementFromPoint(mouseX, mouseY);
            if (!elementUnderCursor) return false;
            return element.is(elementUnderCursor) || element.has(elementUnderCursor).length > 0;
        },

        initHandlers: function() {
            $(document)
            	// this should be moved to MSU
           		.on('mousemove.msu-tooltip', this.onMouseMove.bind(this))
                // Source initialization and tooltip showing
                .on("mouseenter.msu-tooltip", ".msu-tooltip-source, .msu-nested-tooltip-source", this.onSourceEnter)
                .on("mouseleave.msu-tooltip", ".msu-tooltip-source, .msu-nested-tooltip-source", this.onSourceLeave)

                // entering tooltip containers
                .on("mouseenter.msu-tooltip", ".ui-control-tooltip-module", this.onTooltipEnter)
                .on("mouseleave.msu-tooltip", ".msu-nested-tooltip-sources-within", this.onTooltipLeave)

                // Lock handling
                .on("mousedown.msu-tooltip", ".msu-tooltip-source", this.onLockRequest)
                .on("keydown.msu-tooltip", this.onLockRequest)

                // Click handling
                .on("mousedown.msu-tooltip", ".ui-control-tooltip-module", this.onTooltipClick);
        }
	},

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
			this.container.trigger('mouseenter.msu-tooltip');
		}
	},
	updateStack : function ()
	{
		// descends the stack and removes tooltips until it finds one that should remain:
		// - Either its source is hovered and it's still on the screen
		// - Or the resulting tooltip is hovered and still on the screen
		for (var i = this.__tooltipStack.length - 1; i >= 0; i--)
		{
			var pairData = this.__tooltipStack[i];
			var sourceValid = pairData.source.isHovered &&
			                pairData.source.container.is(":visible") &&
			                this.Events.isActuallyHovered(pairData.source.container);

			var tooltipValid = pairData.tooltip.isHovered &&
			                 pairData.tooltip.container.is(":visible") &&
			                 (pairData.tooltip.isLocked || this.Events.isActuallyHovered(pairData.tooltip.container));

			if (sourceValid || tooltipValid) {
			    return;
			}
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
	getTopOfStack : function ()
	{
		return this.isStackEmpty() ? null : this.__tooltipStack[this.__tooltipStack.length - 1];
	},
	removeTopOfStack : function()
	{
		this.removeTooltip(this.__tooltipStack[this.__tooltipStack.length-1]);
	},
	removeTooltip : function (_pairData)
	{
		this.cleanSourceContainer(_pairData.source.container);
		this.cleanTooltipContainer(_pairData.tooltip.container);
		this.__tooltipStack.pop();
		if (this.isStackEmpty())
		{
			// clear refs out of data
			this.__passThroughData = {};
		}
	},
	cleanSourceContainer : function(_sourceContainer)
	{
		var data = _sourceContainer.data("msu-nested");
		if (data === undefined)
			return;
		if (data.tooltipParams.isTileTooltip)
			this.TileTooltipDiv.shrink();
		_sourceContainer.removeData("msu-nested");
	},
	cleanTooltipContainer : function(_tooltipContainer)
	{
		_tooltipContainer.remove();
	},
	bindToElement : function (_element, _tooltipParams)
	{
		this.unbindFromElement(_element);
		_element.data('msu-tooltip-parameters', _tooltipParams);
		_element.addClass('msu-tooltip-source');
		_element.on("mouseenter", this.Events.onSourceEnter);
	},
	unbindFromElement : function (_element)
	{
		_element.removeData("msu-nested");
		_element.removeData('msu-tooltip-parameters');
		_element.removeClass('msu-tooltip-source');
		this.updateStack();
	},
	onShowTooltipTimerExpired : function(_sourceContainer)
	{
		var self = this;
		this.Events.cancelTimer("SHOW")
		var tooltipParams = _sourceContainer.data('msu-tooltip-parameters');
		if (tooltipParams === undefined) // it's either a bug or a tile tooltip (worldmap) with no content
		{
			return;
		}
		// ghetto clone to get new ref
		cloned_tooltipParams = JSON.parse(JSON.stringify(tooltipParams));

		if (!this.isStackEmpty())
		{
			// check if this is within the same chain of nested tooltips, or if we need to clear the stack and start a new chain
			if (this.getTopOfStack().tooltip.container.find(_sourceContainer).length === 0)
			{
				this.clearStack();
			}
			// If we already have tooltips in the stack, we want to fetch the one from the first tooltip that will have received the entityId from the vanilla function
			else
			{
				$.each(this.__passThroughData, function(_key, _value)
				{
					// don't overwrite parameters we already have
					if (_key in cloned_tooltipParams)
						return;
					cloned_tooltipParams[_key] = _value;
				})
			}
		}
		Screens.TooltipScreen.mTooltipModule.notifyBackendQueryTooltipData(cloned_tooltipParams, function (_backendData)
		{
			if (_backendData === undefined || _backendData === null || _backendData.length == 0)
		    {
		    	if (cloned_tooltipParams.isTileTooltip)
		    		self.TileTooltipDiv.shrink();
		        return;
		    }
		    if (cloned_tooltipParams.isTileTooltip)
		    	self.TileTooltipDiv.expand();

		    // vanilla behavior, when sth moved into tile while the data was being fetched
		    if (cloned_tooltipParams.contentType === 'tile' || cloned_tooltipParams.contentType === 'tile-entity')
		    	Screens.TooltipScreen.mTooltipModule.updateContentType(_backendData)
		    if (_backendData[0].contentType !== undefined && _backendData[0].contentType !== null)
		    {
		    	cloned_tooltipParams.contentType = _backendData[0].contentType
		    }


			self.createTooltip(_backendData, _sourceContainer, cloned_tooltipParams);
		});
	},
	createTooltip : function (_backendData, _sourceContainer, _tooltipParams)
	{
		var self = this;
		var tooltipContainer = this.getTooltipFromData(_backendData, _tooltipParams.contentType);
		var sourceData = {
			container : _sourceContainer,
			isHovered : true,
			tooltipContainer : tooltipContainer,
			tooltipParams : _tooltipParams
		};
		_sourceContainer.data("msu-nested", sourceData);
		var tooltipData = {
			container : tooltipContainer,
			isHovered : false,
			isLocked : false,
			sourceContainer : _sourceContainer
		};

		tooltipContainer.data("msu-nested", tooltipData);
		var stackData = {
			source : sourceData,
			tooltip : tooltipData
		}
		this.__tooltipStack.push(stackData);

		if (tooltipContainer.find(".msu-nested-tooltip-source").length > 0)
		{
			tooltipContainer.addClass("msu-nested-tooltip-sources-within");
			this.startTooltipLocking(tooltipContainer, _sourceContainer);
		}

		// Add data that we'll want to pass to any nested tooltips, such as entityId
		if (this.isStackEmpty())
		{
			$.each(_tooltipParams, function(_key, _value)
			{
				if (_key === "contentType" || _key === "elementId")
					return;
				self.__passThroughData[_key] = _value;
			})
		}


		$('body').append(tooltipContainer)
		this.positionTooltip(tooltipContainer, _backendData, _sourceContainer);

	},
	getTooltipFromData : function (_backendData, _contentType)
	{
		var tempContainer = Screens.TooltipScreen.mTooltipModule.mContainer;
		var ret = $('<div class="tooltip-module ui-control-tooltip-module msu-nested-tooltip"/>');
		Screens.TooltipScreen.mTooltipModule.mContainer = ret;
		Screens.TooltipScreen.mTooltipModule.buildFromData(_backendData, false, _contentType);
		this.parseImgPaths(ret);
		Screens.TooltipScreen.mTooltipModule.mContainer = tempContainer;
		return ret;
	},
	startTooltipLocking : function(_tooltipContainer, _sourceContainer)
	{
		var self = this;
		var progressImage = $("<div class='tooltip-progress-bar'/>")
			.appendTo(_tooltipContainer)

		progressImage.velocity({ opacity: 0 },
		{
	        duration: self.Events.__TimerDelayGetters["LOCK"](),
			begin: function()
			{
				progressImage.css("opacity", 1)
	        },
			complete: function()
			{
				progressImage.css("opacity", 1);
				progressImage.css("background-image", 'url("coui://gfx/ui/icons/icon_locked.png")');
				var data = _tooltipContainer.data("msu-nested");
				if (data === undefined)
				{
					return;
				}
				data.isLocked = true;
	        }
	   });
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
		return '<div class="msu-nested-tooltip-source" style="' + this.TextStyle + '" data-msu-nested-mod="' + _mod + '" data-msu-nested-id="' + _id + '">' + _text + '</div>';
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
MSU.NestedTooltip.Events.initHandlers();
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


TooltipModule.prototype.showTileTooltip = function()
{
	if (this.mCurrentData === undefined || this.mCurrentData === null)
	{
		return;
	}
	MSU.NestedTooltip.updateStack();
	if (MSU.NestedTooltip.isStackEmpty() && MSU.NestedTooltip.Events.__Timers["SHOW"] == null)
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

