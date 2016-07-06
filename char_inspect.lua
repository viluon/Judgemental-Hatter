
local i = 150

while true do
	local ev = { os.pullEvent() }

	if ev[ 1 ] == "key_up" then
		if ev[ 2 ] == keys.up then
			i = i + 1
		elseif ev[ 2 ] == keys.down then
			i = i - 1
		end
	end

	term.write( i .. "=" )
	term.setBackgroundColour( colours.white )
	term.write( " " )
	term.setBackgroundColour( colours.black )
	print( " " .. string.char( i ) .. "\n" )
end
