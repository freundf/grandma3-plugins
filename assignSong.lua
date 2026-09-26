local function getSongs()
	local seqPool = DataPool().Sequences
	local songSet = {}

	for i = 1, #seqPool do
		local seq = seqPool[i]
		if IsObjectValid(seq) and seq.No >= 1001 and seq.No <= 1999 then
			songSet[seq.Name] = true
		end
	end
	
	local sortedSongs = {}
	for song, _ in pairs(songSet) do
		table.insert(sortedSongs, song)
	end
	table.sort(sortedSongs)
	
	return sortedSongs
end

local function main(displayHandle)
	local songs = getSongs()
	
	if #songs == 0 then
		Printf("SongList is empty.")
		return
	end

	
	local selectedIndex, selectedValue = PopupInput({
		title = "Select Song from List", 
		caller = displayHandle,
		items = songs,
		selectedValue = songs[1],
		add_args = {FilterSupport = "Yes"},
	})
	
	if selectedValue then
		Printf("Selected: " .. selectedValue)
		Cmd("Assign Sequence '" .. selectedValue .. "' At Layout 7")
	end
end

return main
