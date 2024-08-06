// triggers remove events for elements when they get removed in any way https://stackoverflow.com/a/18410186
MSU.$_cleanData = $.cleanData;
$.cleanData = function( elems ) {
	for ( var i = 0, elem; (elem = elems[i]) != null; i++ ) {
		try {
			$( elem ).triggerHandler( "remove" );
		// http://bugs.jquery.com/ticket/8235
		} catch( e ) {}
	}
	MSU.$_cleanData( elems );
};
