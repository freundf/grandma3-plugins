package.loaded["songlib.Layout"] = nil
package.loaded["songlib.Songs"] = nil
package.loaded["songlib.Util"] = nil

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
		Printf("Error: All layout positions are currently occupied!")
		return
	end

	util.executeElevated(function()
		songLib.addSongToLayout(selectedValue, songLayout, freePos)
	end)
end

return main