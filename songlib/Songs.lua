local MIN_SONG_SEQUENCE = 1001
local MAX_SONG_SEQUENCE = 1999

local LAYOUT_NAME = "SongLayout"

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

return {
	getSongLayout = getSongLayout,
	findFirstFreePosition = findFirstFreePosition,
	findNextFreeSequence = findNextFreeSequence,
	getSongs = getSongs
}