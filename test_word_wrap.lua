
--- Wrap a text to the given maximum width
-- @param text Text to wrap
-- @param width Maximum line width
-- @return lines Array of lines
local function wrap( text, width )
	local lines

	if text:find( "\n" ) then
		lines = {}

		for line in ( text .. "\n" ):gmatch( "(.-)\n" ) do
			for i, l in ipairs( wrap( line, width ) ) do
				lines[ #lines + 1 ] = l
			end
		end
	else
		lines = { "" }
		
		for word in text:gmatch( "(%S+)" ) do
			if #word > width then
				local current_pos = 1

				while current_pos < #word do
					lines[ #lines + 1 ] = word:sub( current_pos, current_pos + width - 1 )
					current_pos = current_pos + width
				end

			elseif #lines[ #lines ] + #word <= width then
				lines[ #lines ] = lines[ #lines ] .. word .. " "

			else
				lines[ #lines + 1 ] = word .. " "
			end
		end
	end

	return lines
end

local txt = [[
This is some sample text right here,
just to make sure the wrap function is properly tested
asdasdasdasdasdasdasd
ondsondsonds onsdonsdonsdonsdonsdonsdononsdonsdonsasdasddonsdonsdonsdonasasdasd
blargh

Heading
=======
Paragraph. Not *just* a paragraph, a _long_ paragraph with lots and lots of text about pretty much nothing.

What about newlines?
]]

local w = 26

print( string.rep( "v", w ) )

for i, line in ipairs( wrap( txt, w ) ) do
	print( line )
end
