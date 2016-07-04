
-- Judgemental Hatter, CCJam judgement helper software by @viluon

local directory = fs.getDir( shell.getRunningProgram() )

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
- Project has no use]];
			[[
- Project only has use in
  an unrealistic scenario]];
			[[
- Project might be helpful
  in one or two very rare
  cases]];
			[[
* Project might come handy
  in a few unusual cases]];
			[[
* Project is helpful
  from time to time]];
			[[
+ Project helps mitigate
  or speed up the process
  of dealing with a
  common issue]];
			[[
+ Project helps mitigate
  or speed up the process
  of dealing with a
  complex issue
+ Efficient interface
  saves time and effort
  of the user]];
			[[
+ ]];
			[[
]];
			[[
]];
			[[
]];
		};
		labels = {
			"Completely Useless";
			"Useless";
			"Almost Useless";
			"Rarely Helpful";
			"Occasionally Helpful";
			"Helpful";
			"Very Helpful";
			"Handy";
			"For Every Day Usage";
			"Exceptionally Useful";
			"Incredibly Useful";
		}
	};
	{
		value = false;
		range = { 0, 6 };
		name = "Design";
		descriptions = {
			[[
- Bad choice of colours
  and other elements of
  visual style
- Interface is unfriendly,
  no help section or
  documentation is present
- User errors caused by
  misunderstanding
  functionality are common,
  and error recovery
  is unhelpful or not
  present at all]];
			[[
- Bad choice of colours
  and other elements of
  visual style
- Interface diverges in
  different parts of the
  program]];
			[[
* Interface posseses
  some sort of a style
  that is used in most
  parts of the program
- Functionality of
  various elements is
  unclear without prior
  study of technical
  documentation]];
			[[
+ Interface style does not
  change in different parts
  of the program
- Some functionality might
  be unclear, which is not
  addressed in the help
  section or documentation]];
			[[
+ Functionality of
  various elements is
  clear and does not
  surprise the user
+ Interface is easy to
  use out of the box,
  no need to study
  documentation
  (for libraries, tutorials
  do not count as
  documentation)]];
			[[
+ Design was apparently
  planned beforehand, with
  great caution
+ Interface follows
  logical guidelines
  and sticks to them
  throughout different
  parts of the program]];
			[[
+ Everything works as
  expected, possibly unclear
  functionality is explained
  in the form of a help section
  or a tutorial
+ Visual style of the interface
  is common for all sections
+ Error recovery for common
  mistakes works well
]];
		};
		labels = {
			"Terrible";
			"Unpleasant";
			"Unintuitive";
			"Okay";
			"Intuitive";
			"Deliberate";
			"Perfect"
		}
	};
	{
		value = false;
		range = { 0, 4 };
		name = "Speed";
		descriptions = {
			[[
- Program is unbearably
  slow, which makes it
  unusable
- Crashes with 'too long
  without yielding' errors
  or contains useless
  sleep calls]];
			[[
- Program runs slowly
- Occasionally crashes
  due to yielding problems]];
			[[
- Program is responsive,
  but lag is noticeable
* Does not crash due
  to yielding problems]];
			[[
+ Program is fast,
  good FPS in GUIs
* Occasionally lags]];
			[[
+ Program contains
  no visible lag
+ Runs at highest speeds
  possible for the
  platform (update every
  50ms in CC)
+ Has no noticeable
  speed issues]];
		};
		labels = {
			"Very Slow";
			"Rather Slow";
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
			[[
- Program contains major
  bugs
- Does not start
  without changes to the
  source code]];
			[[
- Program has serious
  issues that make
  any operation with it
  a complicated process]];
			[[
- Program has annoying
  bugs that would have
  been ruled out by
  limited testing
- Frequent crashes
  cause loss of data
  or work in progress]];
			[[
- Program has easily
  noticeable bugs]];
			[[
]];
			[[
]];
			[[
]];
			[[
]];
			[[
]];
			[[
]];
			[[
]];
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

--- Draw the welcome screen, with a hat
-- @return nil
function draw_hat()
	term.setBackgroundColour( colours.white )
	term.clear()

	-- This hat is 22x10
	local hat = paintutils.loadImage( directory .. "/hat.nfp" )

	paintutils.drawImage( hat, w / 2 - 11, h / 2 - 5 )

	local welcome_message = "Judgemental Hatter"
	term.setTextColour( colours.black )
	term.setCursorPos( w / 2 - #welcome_message / 2, h / 2 + 7 )
	term.write( welcome_message )

	sleep( 1 )
	os.startTimer( 1 )
end

draw_hat()

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
