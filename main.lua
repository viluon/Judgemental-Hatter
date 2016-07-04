

local old_term = term.current()
local w, h = old_term.getSize()
local main_window = window.create( old_term, 1, 1, w, h )

term.redirect( main_window )

local running = true
local scroll = 0

local	draw 

local categories = {
	{
		value = false;
		range = { 0, 3 };
		name = "Creativity";
		descriptions = {
			"poop";
			"less poop";
			"almost no poop";
			"only golden poop";
		};
	};
}

--- Redraw the screen
-- @return nil
function draw()
	main_window.setVisible( false )

	term.setBackgroundColour( colours.white )
	term.setTextColour( colours.black )
	term.clear()

	local total_y = 2
	for i, cat_item in ipairs( categories ) do
		-- ^ Meow
		term.setCursorPos( 2, scroll + total_y )
		term.write( cat_item.name )

		total_y = total_y + 4
	end

	main_window.setVisible( true )
end

while running do
	local ev = { coroutine.yield() }

	if ev[ 1 ] == "mouse_scroll" then
		scroll = scroll - ev[ 2 ]

	elseif ev[ 1 ] == "terminate" then
		running = false
		
	elseif ev[ 1 ] == "mouse_click" then
		
	end

	draw()
end
