local MIN_SONG_SEQUENCE = 1001
local MAX_SONG_SEQUENCE = 1999

local LAYOUT_NAME = "SongLayout"
local SONG_TEMPLATE = "Song Template"

local normalize_pos = require("songlib.Util").normalize_pos



local function getSongs()
	local seqPool = DataPool().Sequences
	local songSet = {}

	for i = 1, #seqPool do
		local seq = seqPool[i]
		if IsObjectValid(seq) and seq.No >= MIN_SONG_SEQUENCE and seq.No <= MAX_SONG_SEQUENCE then
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

local function findSequenceByName(songName)
	local seqPool = DataPool().Sequences
	for i = 1, #seqPool do
		local seq = seqPool[i]
		if IsObjectValid(seq) and seq.Name == songName and seq.No >= MIN_SONG_SEQUENCE and seq.No <= MAX_SONG_SEQUENCE then
			return seq.No
		end
	end
	return nil
end


local function findFirstFreePosition(layoutName, positions)
	local layout = DataPool().Layouts[layoutName]
	local occupiedPositions = {}

	if layout then
		for i = 1, #layout do
			local item = layout[i]
			if IsObjectValid(item) then
				local posX = normalize_pos(item.posX)
				local posY = normalize_pos(item.posY)
				Printf("Found: " .. posX .." " .. posY)
				if posX and posY then
					occupiedPositions[posX .. "_" .. posY] = true
				end
			end
		end
	end

	for _, pos in ipairs(positions) do
		local key = pos.x .. "_" .. pos.y
		if not occupiedPositions[key] then
			return pos
		end
	end

	return nil
end

local function findNextFreeSequence()
	local seqPool = DataPool().Sequences
	local freeIdx = MIN_SONG_SEQUENCE
	while seqPool[freeIdx] do
		freeIdx = freeIdx + 1
	end
	return freeIdx
end

local function getSongLayout()
	local songLayout = GetVar(GlobalVars(), LAYOUT_NAME)	
	if not songLayout or songLayout == "" then
		ErrEcho("Global Variable '" .. LAYOUT_NAME .. "' not set. Set using 'SetGlobalVariable'")
		error("Global Variable '" .. LAYOUT_NAME .. "' not set. Set using 'SetGlobalVariable'")
	end
		
	return songLayout
end

local function regenerateSongMacro(seqIdx, songName)
	Cmd(string.format("Delete Macro %d", seqIdx))
	Cmd(string.format("Store Macro %d '%s' /o", seqIdx, songName))
	
	Cmd(string.format("Delete Macro %d.1 Thru /nc", seqIdx))
	
	local offCmd = string.format("Off Sequence %d Thru %d", MIN_SONG_SEQUENCE, MAX_SONG_SEQUENCE)
	local onCmd = string.format("Go Sequence %d Cue 1", seqIdx)
	local selectCmd = string.format("Select Sequence %d", seqIdx)
	
	Cmd(string.format("Insert Macro %d.1", seqIdx))
	Cmd(string.format("Insert Macro %d.2", seqIdx))
	Cmd(string.format("Insert Macro %d.3", seqIdx))
	Cmd(string.format("Set Macro %d.1 Property 'Command' '%s'", seqIdx, offCmd))
	Cmd(string.format("Set Macro %d.2 Property 'Command' '%s'", seqIdx, onCmd))
	Cmd(string.format("Set Macro %d.3 Property 'Command' '%s'", seqIdx, selectCmd))

end

local function addSongToLayout(songName, layoutName, freePos)
	local seqIdx = findSequenceByName(songName)
	if not seqIdx then
		ErrEcho("Could not find sequence for song: " .. songName)
		return
	end
	
	regenerateSongMacro(seqIdx, songName)

    Cmd(string.format("Assign Macro '%s' At Layout '%s'", songName, layoutName))
    Cmd(string.format("Set Layout '%s'.'%s' Property 'Action' 'Select'", layoutName, songName))
    Cmd(string.format("Set Layout '%s'.'%s' Property 'Appearance' 'None'", layoutName, songName))

    local targetLayout = DataPool().Layouts[layoutName]
    if targetLayout then
        local newItem = targetLayout[#targetLayout]
        if IsObjectValid(newItem) then
            newItem.posX = freePos.x
            newItem.posY = freePos.y
        end
    end
end

local function createSong(songName, seqIdx)
	Cmd(string.format("Copy Sequence '%s' At Sequence %d", SONG_TEMPLATE, seqIdx))
	Cmd(string.format("Label Sequence %d '%s'", seqIdx, songName))
	
	regenerateSongMacro(seqIdx, songName)
	
	Cmd(string.format("Select Sequence %d", seqIdx))
	
end

return {
	getSongLayout = getSongLayout,
	findFirstFreePosition = findFirstFreePosition,
	findNextFreeSequence = findNextFreeSequence,
	getSongs = getSongs,
	addSongToLayout = addSongToLayout,
	createSong = createSong
}