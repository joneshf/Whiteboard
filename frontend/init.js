require(['menu', 'utility/color', 'brushes/brushes', 'canvas'],
	function(menu, color, brushes, canvas)
	{
		canvas_init = canvas_script();
		canvas_init('canvas', window.innerWidth - 17, window.innerHeight - 45, 'rgba(0,0,0,1.0)', 13);
	}
);
