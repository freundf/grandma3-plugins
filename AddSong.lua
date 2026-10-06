local layout = require("songlib.Layout")
local positions = layout.positions
local songLib = require("songlib.Songs")
local util = require("songlib.Util")


local function main(displayHandle)
	local songLayout = songLib.getSongLayout()	
	local songs = songLib.getSongs()
	
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
	
	if not selectedValue then
		return
	end
	
	local freePos = songLib.findFirstFreePosition(songLayout, positions)
		
	if not freePos then
		Printf("Error: All 10 layout positions are currently occupied!")
		return
	end

	
	
	local currentUser = CurrentUser()
	
	local function addSong()
		Cmd(string.format("Assign Sequence '%s' At Layout '%s'", selectedValue, songLayout))
		Cmd(string.format("Set Layout '%s'.'%s' Property 'Action' 'Select'", songLayout, selectedValue))

		local targetLayout = DataPool().Layouts[songLayout]
		if targetLayout then
			local newItem = targetLayout[#targetLayout]
			if IsObjectValid(newItem) then
				newItem.posX = freePos.x
				newItem.posY = freePos.y
			end
		end
	end
	
	if util.prog_rights[currentUser.Rights] then
		addSong()
	else
		util.asProgUser(addSong)
	end
end

return main