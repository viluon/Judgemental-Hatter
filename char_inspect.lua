
local i = 150
local last_i = i

while true do
	local ev = { os.pullEvent() }

	if ev[ 1 ] == "key_up" then
		if ev[ 2 ] == keys.up then
			i = i + 1
		elseif ev[ 2 ] == keys.down then
			i = i - 1
		end
	end

	if i ~= last_i then
		term.write( i .. "=" )
		term.setBackgroundColour( colours.white )
		term.write( " " )
		term.setBackgroundColour( colours.black )
		print( " " .. string.char( i ) .. "\n" )

		last_i = i
	end
end
