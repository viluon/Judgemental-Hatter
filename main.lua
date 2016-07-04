

local old_term = term.current()
local w, h = old_term.getSize()
local main_window = window.create( old_term, 1, 1, w, h )

term.redirect( main_window )

local running = true
local scroll = 0

local	draw

local item_not_judged_text = "Category not judged"

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
	{
		value = false;
		range = { 0, 3 };
		name = "Poopitivity";
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
	term.clear()

	local total_y = 2
	for i, cat_item in ipairs( categories ) do
		-- ^ Meow
		cat_item.y_pos = total_y

		term.setCursorPos( 2, scroll + total_y )
		term.setTextColour( cat_item.colour or colours.black )
		term.write( cat_item.name )

		term.setTextColour( colours.grey )
		term.setCursorPos( 5, scroll + total_y + 1 )
		term.write( "^" )
		term.setCursorPos( 5, scroll + total_y + 3 )
		term.write( "v" )

		term.setTextColour( colours.black )
		term.setCursorPos( 5, scroll + total_y + 2 )
		term.write( cat_item.value or "-" )

		term.setTextColour( colours.grey )

		local c = 1
		for line in ( ( cat_item.value and cat_item.descriptions[ cat_item.value + 1 ] or item_not_judged_text ) .. "\n" ):gmatch( ".+\n" ) do
			term.setCursorPos( w / 5, scroll + total_y + c )
			term.write( line )
			c = c + 1
		end

		total_y = total_y + 4
	end

	term.setCursorPos( 2, 1 )
	term.setBackgroundColour( colours.grey )
	term.clearLine()

	term.setTextColour( colours.white )
	term.write( "Judgemental Hatter - by @viluon" )

	main_window.setVisible( true )
end

while running do
	local ev = { coroutine.yield() }

	if ev[ 1 ] == "mouse_scroll" then
		scroll = scroll - ev[ 2 ]

	elseif ev[ 1 ] == "terminate" then
		running = false

	elseif ev[ 1 ] == "mouse_click" and ev[ 4 ] > 1 then
		-- Find the item we hit
		for i = #categories, 1, -1 do
			cat_item = categories[ i ]

			if cat_item.y_pos and cat_item.y_pos - ev[ 4 ] + scroll <= 0 then
				local relative_position = cat_item.y_pos - ev[ 4 ] + scroll

				if relative_position == -1 then
					cat_item.value = math.min( ( cat_item.value or -1 ) + 1, cat_item.range[ 2 ] )

				elseif relative_position == -3 then
					cat_item.value = ( cat_item.value or 0 ) - 1

					if cat_item.value < cat_item.range[ 1 ] then
						cat_item.value = false
					end
				end

				--cat_item.colour = 2 ^ math.random( 0, 15 )

				break
			end
		end

	elseif ev[ 1 ] == "char" then
		if ev[ 2 ] == "q" then
			running = false
		end
	end

	draw()
end
