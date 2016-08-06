
-- Judgemental Hatter, CCJam judgement helper software by @viluon
-- 🎩

local directory = fs.getDir( shell.getRunningProgram() )

local old_term = term.current()
local w, h = old_term.getSize()
local main_window = window.create( old_term, 1, 1, w, h )

term.redirect( main_window )

local running = true

local states = {
	welcome_screen = "welcome_screen";
	category_screen = "category_screen";
	overview_screen = "overview_screen";
}
local state = states.welcome_screen

local scroll = 1
local total_y = 2
local top_bar_position = 1

local	draw_category_screen, draw_hat, draw_welcome_screen, pick_scoring_system, print_top_bar

local item_not_judged_text = "Category not judged"
local finish_button_text = " Finish "
local arrow_position = 5

local is_game = false

local categories
local scoring_system

local scoring_systems = {
	{
		name = "Tutorial";
		ID = "tutorial";
		description = "Learn how to use this program";
	};
	{
		name = "Ardera Average";
		ID = "ardera_average";
		description = "CCJam 2016 scoring system";
	};
	{
		name = "Poop Prize";
		ID = "Lemmmy";
		description = "What?";
	};
}

--- Redraw the screen
-- @return nil
function draw_category_screen()
	main_window.setVisible( false )

	term.setBackgroundColour( colours.white )
	term.clear()

	local hats = 0
	total_y = 2

	-- Loop through all categories
	for i, cat_item in ipairs( categories ) do
		-- ^ Meow
		cat_item.y_pos = total_y

		term.setCursorPos( 2, scroll + total_y )
		term.setTextColour( cat_item.colour or colours.black )
		term.write( cat_item.name .. ": " )

		local has_max_value = cat_item.value and cat_item.value == cat_item.range[ 2 ]

		if has_max_value then
			draw_hat()

			-- Keep track of how many top hats have been awarded
			-- This is very important
			hats = hats + 1

			term.write( " " )
		end

		term.write( cat_item.value and cat_item.labels[ cat_item.value + 1 ] or "Unknown" )

		-- Draw the up and down arrows
		term.setTextColour( has_max_value and colours.lightGrey or colours.grey )
		term.setCursorPos( arrow_position, scroll + total_y + 1 )
		term.write( "\30" )
		term.setTextColour( not cat_item.value and colours.lightGrey or colours.grey )
		term.setCursorPos( arrow_position, scroll + total_y + 3 )
		term.write( "\31" )

		-- Draw the current value
		term.setTextColour( colours.black )
		term.setCursorPos( arrow_position, scroll + total_y + 2 )
		term.write( cat_item.value or "-" )

		term.setTextColour( colours.grey )

		local description = ( cat_item.value and cat_item.descriptions[ cat_item.value + 1 ] or item_not_judged_text ) .. "\n"
		local row = 1

		-- Print the description, taking bullet points into account
		for line in description:gmatch( "[^\n]+\n" ) do
			term.setCursorPos( w / 5, scroll + total_y + row )

			line = line:gsub( "\t+", "", 1 )

			if line:sub( 1, 1 ) == "+" then
				term.setTextColour( colours.green )

			elseif line:sub( 1, 1 ) == "-" then
				term.setTextColour( colours.red )

			elseif line:sub( 1, 1 ) == "*" then
				term.setTextColour( colours.grey )

			end

			term.write( line )
			row = row + 1
		end

		local _, newline_count = description:gsub( "\n", "" )

		total_y = total_y + math.max( 4, newline_count + 2 )
	end	-- Looped through all categories 

	print_top_bar()

	-- Print number of awarded top hats into the top bar
	if hats > 0 then
		local hat_text = hats .. " top hat" .. ( hats > 1 and "s" or "" )

		term.setTextColour( colours.yellow )
		term.setCursorPos( w - #hat_text, top_bar_position )
		term.write( hat_text )
	end

	-- Draw the Finish button
	term.setCursorPos( w - #finish_button_text, h - 1 )
	term.setTextColour( colours.white )
	term.setBackgroundColour( colours.blue )
	term.write( finish_button_text )

	main_window.setVisible( true )
end

--- Draw the welcome screen, with a hat
-- @return nil
function draw_welcome_screen()
	term.setBackgroundColour( colours.white )
	term.clear()

	-- This hat is 22x10
	local hat = paintutils.loadImage( directory .. "/hat.nfp" )

	-- Hard-coded, but meh
	paintutils.drawImage( hat, w / 2 - 11, h / 2 - 5 )

	local welcome_message = "Judgemental Hatter"
	term.setTextColour( colours.black )
	term.setCursorPos( w / 2 - #welcome_message / 2, h / 2 + 7 )
	term.write( welcome_message )

	sleep( 1 )
	os.startTimer( 1 )
end

--- Prints a hat
-- @return Empty string
function draw_hat()
	local old_tc, old_bc = term.getTextColour(), term.getBackgroundColour()

	term.setTextColour( colours.white )
	term.setBackgroundColour( colours.grey )
	-- The awesomeness is real
	term.write( "\133\138" )

	term.setTextColour( old_tc )
	term.setBackgroundColour( old_bc )

	return ""
end

--- Show a screen with scoring system options and wait for the user to choose
-- @return nil
function pick_scoring_system()
	local button_text = " Go! "
	local quit_text = " Quit "

	os.queueEvent( "mouse_click", 1, 1, 1 )

	while true do
		main_window.setVisible( false )
		local ev = { os.pullEvent() }

		if ev[ 1 ] == "mouse_click" then
			local y = ev[ 4 ]

			if y == h - 1 then
				if ev[ 3 ] >= w - #button_text and scoring_system then
					-- Hit the Go! button
					break

				elseif ev[ 3 ] >= 2 and ev[ 3 ] <= #quit_text + 1 then
					-- Hit the Quit button
					term.redirect( old_term )
					term.setBackgroundColour( colours.black )
					term.clear()
					term.setCursorPos( 1, 1 )
					error()
				end
			end

			local index = math.floor( -h / 4 + #scoring_systems + y / 2 + 0.5 ) - 1

			scoring_system = scoring_systems[ index ]
		end

		-- Redraw
		term.setBackgroundColour( colours.white )
		term.clear()

		print_top_bar()
		
		term.setCursorPos( 3, 3 )
		term.setTextColour( colours.black )
		term.setBackgroundColour( colours.white )
		term.write( "Pick a scoring system to judge with:" )

		-- Print the possibilities
		for i, sys in ipairs( scoring_systems ) do
			local y = h / 2 - #scoring_systems + i * 2

			if scoring_system and scoring_system.ID == sys.ID then
				term.setCursorPos( 2, y )
				draw_hat()
			end

			term.setCursorPos( 5, y )
			term.setTextColour( colours.black )
			term.write( sys.name )

			term.setTextColour( colours.grey )
			term.write( " " .. sys.description )
		end

		-- Draw the Go! button
		term.setCursorPos( w - #button_text, h - 1 )
		term.setBackgroundColour( scoring_system and colours.green or colours.lightGrey )
		term.setTextColour( colours.white )
		term.write( button_text )

		-- Draw the Quit button
		term.setCursorPos( 2, h - 1 )
		term.setBackgroundColour( colours.red )
		term.setTextColour( colours.white )
		term.write( quit_text )

		main_window.setVisible( true )
	end
end

--- Show the fancy grey bar at the top of the screen
-- @return nil
function print_top_bar()
	for i = 1, top_bar_position do
		term.setCursorPos( 2, i )
		term.setBackgroundColour( colours.grey )
		term.clearLine()
	end

	term.setTextColour( colours.white )
	term.write( "Judgemental Hatter - by @viluon" )
end

draw_welcome_screen()
pick_scoring_system()

if scoring_system.ID == "ardera_average" then
	categories = {
		{
			value = false;
			range = { 0, 3 };
			name = "Creativity";
			descriptions = {
				-- Unoriginal
				[[
	- This type of projects is
	  very well known
	- Project takes too much
	  inspiration from
	  others of its kind]];
				-- Common
				[[
	- This type of projects is
	  very well known
	+ Author included a few
	  original ideas]];
				-- Original
				[[
	* This type of projects is
	  either uncommon or
	  doesn't take much inspiration
	  from others
	+ Author included a number of
	  original ideas or resolved
	  a major issue present
	  in other projects of this
	  kind]];
				-- Outstanding
				[[
	+ This project is unlike
	  any other
	+ A number of great ideas
	  and innovations are
	  present]];
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
				-- Completely Useless
				[[
				- Project has no use]];
				-- Useless
				[[
				- Project only has use in
				  an unrealistic scenario]];
				-- Almost Useless
				[[
				- Project might be helpful
				  in one or two very rare
				  cases]];
				-- Rarely Helpful
				[[
				* Project might come handy
				  in a few unusual cases]];
				-- Occasionally Helpful
				[[
				* Project is helpful
				  from time to time]];
				-- Helpful
				[[
				+ Project helps mitigate
				  or speed up the process
				  of dealing with a
				  common issue]];
				-- Very Helpful
				[[
				+ Project helps mitigate
				  or speed up the process
				  of dealing with a
				  complex issue]];
				-- Handy
				[[
				+ Project helps mitigate
				  or speed up the process
				  of dealing with multiple
				  complex issues
				+ Efficient interface
				  saves time and effort
				  of the user]];
				-- For Every Day Usage
				[[
				+ Project helps mitigate
				  or speed up the process
				  of dealing with numerous
				  related issues of
				  varying complexity
				+ Defaults are set so that
				  the most common set ups
				  require little to no
				  input from the user]];
				-- Exceptionally Useful
				[[
				+ Project implements
				  major workflow speedups
				+ Easy to use, well
				  designed interface
				  makes any operation
				  with the program simple
				  and efficient]];
				-- Incredibly Useful
				[[
				+ Project implements
				  major workflow speedups
				+ Easy to use, well
				  designed interface
				  makes any operation
				  with the program simple
				  and efficient
				+ Automation takes control
				  over the majority
				  of repetitive tasks]];
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
				-- Terrible
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
				-- Unpleasant
				[[
				- Bad choice of colours
				  and other elements of
				  visual style
				- Interface diverges in
				  different parts of the
				  program]];
				-- Unintuitive
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
				-- Okay
				[[
				+ Interface style does not
				  change in different parts
				  of the program
				- Some functionality might
				  be unclear, which is not
				  addressed in the help
				  section or documentation]];
				-- Intuitive
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
				-- Deliberate
				[[
				+ Design was apparently
				  planned beforehand, with
				  great caution
				+ Interface follows
				  logical guidelines
				  and sticks to them
				  throughout different
				  parts of the program]];
				-- Perfect
				[[
				+ Everything works as
				  expected, possibly unclear
				  functionality is explained
				  in the form of a help section
				  or a tutorial
				+ Visual style of the interface
				  is common for all of its
				  sections
				+ Error recovery for common
				  mistakes works well]];
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
				-- Very Slow
				[[
				- Program is unbearably
				  slow, which makes it
				  unusable
				- Crashes with 'too long
				  without yielding' errors
				  or contains useless
				  sleep calls]];
				-- Rather Slow
				[[
				- Program runs slowly
				- Occasionally crashes
				  due to yielding problems]];
				-- Responsive
				[[
				- Program is responsive,
				  but lag is noticeable
				* Does not crash due
				  to yielding problems]];
				-- Quick
				[[
				+ Program is fast,
				  good FPS in GUIs
				* Occasionally lags]];
				-- Swift
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
				-- Unusable
				[[
				- Program contains major
				  bugs
				- Does not start
				  without changes to the
				  source code]];
				-- Seriously Broken
				[[
				- Program has serious
				  issues that make
				  any operation with it
				  a complicated process
				- Crashes on valid input]];
				-- Broken
				[[
				- Program has annoying
				  bugs that would have
				  been ruled out by
				  limited testing
				- Frequent crashes
				  cause loss of data
				  or work in progress,
				  even with valid input]];
				-- Flawed
				[[
				- Program has easily
				  noticeable bugs
				- Graphical glitches
				  are frequent
				* Program occasionally
				  crashes, but only
				  when served invalid
				  input]];
				-- Buggy
				[[
				- Program contains
				  recurring bugs,
				  but all parts are
				  usable
				]];
				-- Faulty
				[[

				]];
				-- Okay
				[[
				]];
				-- Good
				[[
				]];
				-- Extensive
				[[
				]];
				-- Vast
				[[
				]];
				-- Excellent
				[[
				]];
			};
			labels = {
				"Unusable";
				"Seriously Broken";
				"Broken";
				"Flawed";
				"Buggy";
				"Faulty";
				"Okay";
				"Good";
				"Extensive";
				"Vast";
				"Excellent";
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

elseif scoring_system.ID == "Lemmmy" then
	categories = {
		{
			value = false;
			range = { 0, 3 };
			name = "Poopiness";
			descriptions = {
				-- Poop
				[[
				- Green poop]];
				-- Blobs
				[[
				* Small blobs of
				  spherical shape]];
				-- Supperpoop
				[[
				+ Quality poop
				- Lyqyd]];
				-- Excrement
				[[
				+ Royal shit]];
			};
			labels = {
				"Poop";
				"Blobs";
				"Supperpoop";
				"Excrement";
			}
		};
	}

elseif scoring_system.ID == "tutorial" then
	categories = {
		{
			value = 0;
			range = { 0, 0 };
			name = "Example Category";
			descriptions = {
				[[
				This is an example of
				a category.]];
			};
			labels = {
				"Example Label";
			};
		};
		{
			value = 0;
			range = { 0, 2 };
			name = "Another Example Category";
			descriptions = {
				[[
				Judgemental Hatter uses
				categories to score
				individual parts of a
				program. To change your
				rating, click the up
				and down arrows to
				the left.]];
				[[
				Category descriptions
				change based on their
				rating, they are here
				to hint you what
				should a competition
				entry of this rating
				look like. Click upvote
				again.]];
				[[
				Descriptions are usually
				organised into bullet
				points.
				+ This is a feature
				- While this is a
				  disadvantage.
				* This point is
				  neither good nor
				  bad, it's just a
				  description.]];
			};
			labels = {
				"Example Label";
				"Another Label";
				"Just a Label";
			};
		};
		{
			value = 0;
			range = { 0, 0 };
			name = "Third Category";
			descriptions = {
				[[
				You can use the mouse
				wheel to scroll up
				and down the
				category list.]];
			};
			labels = {
				"Example Label";
			};
		};
		{
			value = 0;
			range = { 0, 2 };
			name = "Example Category";
			descriptions = {
				[[
				Labels also change
				when you change your
				rating. They represent
				a summary of your
				judgement for
				the given category.]];
				[[
				Labels also change
				when you change your
				rating. They represent
				a summary of your
				judgement for
				the given category.]];
				[[
				Labels also change
				when you change your
				rating. They represent
				a summary of your
				judgement for
				the given category.]];
			};
			labels = {
				"Bad Stuff";
				"Okay Stuff";
				"Good Stuff";
			};
		};
		{
			value = 0;
			range = { 0, 0 };
			name = "Category with a Hat";
			descriptions = {
				[[
				You might have noticed
				the occasional top hats.
				These mark the highest
				score for the given
				category, and their
				overall number is
				shown in the top right
				corner of the screen.]];
			};
			labels = {
				"Hatty Label";
			};
		};
		{
			value = 0;
			range = { 0, 0 };
			name = "The End";
			descriptions = {
				[[
				+ This is it!
				* Thanks for reading
				  through this. Happy
				  judging!
				* Feel free to
				  experiment with
				  JH, Q quits
				  the program.]];
			};
			labels = {
				"Tutorial Complete";
			};
		};
	}

else
	categories = {}
end

state = states.category_screen

while running do
	local ev = { coroutine.yield() }

	if ev[ 1 ] == "mouse_scroll" then
		scroll = math.min( 1, math.max( -total_y + h, scroll - ev[ 2 ] ) )

	elseif ev[ 1 ] == "terminate" then
		running = false

	elseif ev[ 1 ] == "mouse_click" and ev[ 4 ] > top_bar_position then
		if state == states.category_screen then
			if ev[ 4 ] == h - 1 and ev[ 3 ] >= w - #finish_button_text then
				-- We hit the Finish button!
				state = states.overview_screen
			else
				-- Find the item we hit
				for i = #categories, 1, -1 do
					cat_item = categories[ i ]

					if cat_item.y_pos and cat_item.y_pos - ev[ 4 ] + scroll <= 0 and ev[ 3 ] == arrow_position then
						-- This is magic
						local relative_position = cat_item.y_pos - ev[ 4 ] + scroll

						if relative_position == -1 then
							cat_item.value = math.min( ( cat_item.value or -1 ) + 1, cat_item.range[ 2 ] )

						elseif relative_position == -3 then
							cat_item.value = ( cat_item.value or 0 ) - 1

							if cat_item.value < cat_item.range[ 1 ] then
								cat_item.value = false
							end
						end

						break
					end
				end
			end
		end

	elseif ev[ 1 ] == "char" then
		if ev[ 2 ] == "q" then
			running = false
		end
	end

	if state == states.category_screen then
		draw_category_screen()
	end
end

term.setCursorPos( 1, 1 )
