

local old_term = term.current()
local w, h = old_term.getSize()
local main_window = window.create( old_term, 1, 1, w, h )

term.redirect( main_window )

local running = true
local scroll = 0

local	draw

local item_not_judged_text = "Category not judged"
local arrow_position = 5

local is_game = false

local categories = {
	{
		value = false;
		range = { 0, 3 };
		name = "Creativity";
		descriptions = {
			[[
- This type of projects is
  very well known
- Project takes too much
  inspiration from
  others of its kind]];
			[[
- This type of projects is
  very well known
+ Author included a few
  original ideas]];
			[[
* This type of projects is
  either uncommon or
  doesn't take much inspiration
  from others
+ Author included a number of
  original ideas or resolved
  a major issue present
  in other projects of this
  kind
]];
			[[
+ This project is unlike
  any other
+ A number of great ideas
  and innovations are
  present
]];
		};
		labels = {
			"Unoriginal";
			"Common";
			"Original";
			"Outstanding";
		}
	};
	{
		value = false;
		range = { 0, 10 };
		name = "Usefulness";
		descriptions = {
			[[
- Project has no real use
- 
]];
			"less poop";
			"almost no poop";
			"only golden poop";
		};
		labels = {
			"Useless";
			"Useless";
			"Useless";
			"Occasionally Helpful";
			"Occasionally Helpful";
			"Helpful";
			"Very Helpful";
			"Handy";
			"For Every Day Usage";
			"Exceptionally Useful";
		}
	};
	{
		value = false;
		range = { 0, 6 };
		name = "Design";
		descriptions = {
			"poop";
			"less poop";
			"almost no poop";
			"only golden poop";
		};
		labels = {
			"Unoriginal";
			"Common";
			"Original";
			"Outstanding";
		}
	};
	{
		value = false;
		range = { 0, 4 };
		name = "Speed";
		descriptions = {
			[[
- 
]];
			"less poop";
			"almost no poop";
			"only golden poop";
		};
		labels = {
			"Very Slow";
			"Responsive";
			"Quick";
			"Swift";
		}
	};
	{
		value = false;
		range = { 0, 10 };
		name = "Functionality";
		descriptions = {
			"poop";
			"less poop";
			"almost no poop";
			"only golden poop";
		};
		labels = {
			"Unusable";
			"Broken";
			"Broken";
			"Broken";
		}
	};
}

if is_game then
	categories[ 2 ] = {
		value = false;
		range = { 0, 10 };
		name = "Fun";

		descriptions = {};
		labels = {
			"Boring";
		};
	}
end

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
		term.write( cat_item.name .. ": " .. ( cat_item.value and cat_item.labels[ cat_item.value + 1 ] or "Unknown" ) )

		term.setTextColour( colours.grey )
		term.setCursorPos( arrow_position, scroll + total_y + 1 )
		term.write( "\30" )
		term.setCursorPos( arrow_position, scroll + total_y + 3 )
		term.write( "\31" )

		term.setTextColour( colours.black )
		term.setCursorPos( arrow_position, scroll + total_y + 2 )
		term.write( cat_item.value or "-" )

		term.setTextColour( colours.grey )

		local description = ( cat_item.value and cat_item.descriptions[ cat_item.value + 1 ] or item_not_judged_text ) .. "\n"
		local c = 1

		for line in description:gmatch( "[^\n]+\n" ) do
			term.setCursorPos( w / 5, scroll + total_y + c )

			if line:sub( 1, 1 ) == "+" then
				term.setTextColour( colours.green )

			elseif line:sub( 1, 1 ) == "-" then
				term.setTextColour( colours.red )

			elseif line:sub( 1, 1 ) == "*" then
				term.setTextColour( colours.grey )

			end

			term.write( line )
			c = c + 1
		end

		local _, newline_count = description:gsub( "\n", "" )

		total_y = total_y + math.max( 4, newline_count + 2 )
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

			if cat_item.y_pos and cat_item.y_pos - ev[ 4 ] + scroll <= 0 and ev[ 3 ] == arrow_position then
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
