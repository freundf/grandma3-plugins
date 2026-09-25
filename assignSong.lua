local function getActiveSequenceNames()
	local seqPool = DataPool().Sequences
	local activeSeqNames = {}
	for i = 1, #seqPool do
		local seq = seqPool[i]
		if IsObjectValid(seq) and seq.No > 1000 then
			activeSeqNames[seq.Name] = true
		end
	end
	return activeSeqNames
end

local function loadSongTable()
	local songStr = GetVar(GlobalVars(), "SongList") or ""
	if songStr == "" then return {} end
	
	local songTable = {}
	for item in string.gmatch(songStr, "([^,]+)") do
		local it = string.match(item, "^%s*(.-)%s*$")
		table.insert(songTable, it)
	end
	
	local activeSeqNames = getActiveSequenceNames()
	local validSongs = {}
	for _, song in ipairs(songTable) do
		if activeSeqNames[song] then
			table.insert(validSongs, song)
		end
	end
	
	return validSongs
end

local function saveSongTable(songTable)
	local updatedStr = table.concat(songTable, ", ")
	SetVar(GlobalVars(), "SongList", updatedStr)
end

local function main(displayHandle)
	local songTable = loadSongTable()
	
	if #songTable == 0 then
		Printf("SongList is empty or no valid sequences > 1000 found.")
		return
	end
	
	saveSongTable(songTable)
	
	local selectedIndex, selectedValue = PopupInput({
		title = "Select Song from List", 
		caller = displayHandle,
		items = songTable,
		selectedValue = songTable[1],
		add_args = {FilterSupport = "Yes"},
	})
	
	if selectedValue then
		Printf("Selected: " .. selectedValue)
		Cmd("Assign Sequence " .. selectedValue .. " At Layout 7")
	end
end

return main
