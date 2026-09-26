local function findNextFreeSequence()
	local seqPool = DataPool().Sequences
	local freeIdx = 1001
	while seqPool[freeIdx] do
		freeIdx = freeIdx + 1
	end
	return freeIdx
end

local function main()
	local newSong = TextInput("Song Name:")
	
	if newSong and newSong ~= "" then
		local freeIdx = findNextFreeSequence()
		Cmd(string.format("Copy Sequence 'Song Template' At Sequence %d '%s'", freeIdx, newSong))
		Cmd(string.format("Select Sequence %d", freeIdx))
	
		Printf("Created Sequence " .. freeIdx .. " ('" .. newSong .. "') and updated SongList.")
	end
end

return main
