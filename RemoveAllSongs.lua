local layoutModule = require("songlib.Layout")
local positions = layoutModule.positions
local songLib = require("songlib.Songs")
local util = require("songlib.Util")

local function main(displayHandle)
	local songLayoutName = songLib.getSongLayout()
	local layout = DataPool().Layouts[songLayoutName]
	
	if not layout or #layout == 0 then
		Printf(string.format("Layout '%s' is already empty.", songLayoutName))
		return
	end

	local indicesToDelete = {}
	for i = 1, #layout do
		local item = layout[i]
		if IsObjectValid(item) then
			local posX = util.normalize_pos(item.posX)
			local posY = util.normalize_pos(item.posY)
			if posX and posY then
				for _, pos in ipairs(positions) do
					if pos.x == posX and pos.y == posY then
						table.insert(indicesToDelete, i)
						break
					end
				end
			end
		end
	end

	if #indicesToDelete == 0 then
		Printf(string.format("No song positions found to remove on Layout '%s'.", songLayoutName))
		return
	end
	
	table.sort(indicesToDelete, function(a, b) return a > b end)

	local function clearSongs()
		for _, index in ipairs(indicesToDelete) do
			Cmd(string.format("Delete Layout '%s'.%d /nc", songLayoutName, index))
		end
	end

	local currentUser = CurrentUser()
	if util.prog_rights[currentUser.Rights] then
		clearSongs()
	else
		util.asProgUser(clearSongs)
	end

	Printf(string.format("Successfully removed all song positions from Layout '%s'.", songLayoutName))
end

return main