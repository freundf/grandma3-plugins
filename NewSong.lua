local songLib = require("songlib.Songs")

local function main()
	local newSong = TextInput("Song Name:")
	
	if newSong and newSong ~= "" then
		local freeIdx = songLib.findNextFreeSequence()
		
		Cmd(string.format("Copy Sequence 'Song Template' At Sequence %d", freeIdx))
		Cmd(string.format("Label Sequence %d '%s'", freeIdx, newSong))
		Cmd(string.format("Select Sequence %d", freeIdx))
	
		Printf("Created Sequence " .. freeIdx .. " ('" .. newSong .. "') and updated SongList.")
	end
end

return main