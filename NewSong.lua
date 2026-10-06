package.loaded["songlib.Songs"] = nil

local songLib = require("songlib.Songs")

local function main()
	local newSong = TextInput("Song Name:")
	
	if newSong and newSong ~= "" then
		local freeIdx = songLib.findNextFreeSequence()
		
		songLib.createSong(newSong, freeIdx)
	
		Printf("Created Sequence " .. freeIdx .. " ('" .. newSong .. "') and updated SongList.")
	end
end

return main