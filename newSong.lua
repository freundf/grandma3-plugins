local function loadSongTable()
	local songStr = GetVar(GlobalVars(), "SongList") or ""
	if songStr == "" then return {} end
	
	local songTable = {}
	for item in string.gmatch(songStr, "([^,]+)") do
		local it = string.match(item, "^%s*(.-)%s*$")
		table.insert(songTable, it)
	end
	return songTable
end

local function saveSongTable(songTable)
	local updatedStr = table.concat(songTable, ", ")
	SetVar(GlobalVars(), "SongList", updatedStr)
end

local function findNextFreeSequence()
	local seqPool = DataPool().Sequences
	local freeIdx = 1001
	while seqPool[freeIdx] do
		freeIdx = freeIdx + 1
	end
	return freeIdx
end

local function main()
	local songTable = loadSongTable()
	
	local newSong = TextInput("Song Name:")
	
	if newSong and newSong ~= "" then
		local freeIdx = findNextFreeSequence()
		Cmd(string.format("Store Sequence %d \"%s\"", freeIdx, newSong))
		table.insert(songTable, newSong)
		saveSongTable(songTable)
	
		Printf("Created Sequence " .. freeIdx .. " ('" .. newSong .. "') and updated SongList.")
	end
end

return main
