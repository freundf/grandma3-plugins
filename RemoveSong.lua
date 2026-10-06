package.loaded["songlib.Layout"] = nil
package.loaded["songlib.Songs"] = nil
package.loaded["songlib.Util"] = nil

local layoutModule = require("songlib.Layout")
local positions = layoutModule.positions
local songLib = require("songlib.Songs")
local util = require("songlib.Util")

local function main(displayHandle)
	local songLayoutName = songLib.getSongLayout()
	local layout = DataPool().Layouts[songLayoutName]
	
	if not layout or #layout == 0 then
		Printf(string.format("Layout '%s' is empty.", songLayoutName))
		return
	end

	local positionToLayoutIndex = {}
	for i = 1, #layout do
		local item = layout[i]
		if IsObjectValid(item) then
			local posX = util.normalize_pos(item.posX)
			local posY = util.normalize_pos(item.posY)
			if posX and posY then
				positionToLayoutIndex[posX .. "_" .. posY] = i
			end
		end
	end

	local targetLayoutIndex = nil
	local targetPos = nil

	for i = #positions, 1, -1 do
		local pos = positions[i]
		local key = pos.x .. "_" .. pos.y
		if positionToLayoutIndex[key] then
			targetLayoutIndex = positionToLayoutIndex[key]
			targetPos = pos
			break
		end
	end

	local function removeSong()
		if targetLayoutIndex then
			Printf("Removing song at Position X: " .. targetPos.x .. ", Y: " .. targetPos.y)
			Cmd("Delete Layout '%s'.%d /nc", songLayoutName, targetLayoutIndex)
		else
			Printf(string.format("No items found in Layout '%s' matching the song positions.", songLayoutName))
		end
	end

	util.executeElevated(removeSong)
end

return main