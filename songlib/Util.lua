local progUser = require("songlib.UserConfig")

local prog_rights = {
	Program = true,
	Setup = true,
	Admin = true
}

local function asUser(user, pw, func, ...)

    local success, currentUserResult = pcall(function() return CurrentUser().Name end)
    local currentUser = success and currentUserResult or nil
    
    Cmd(string.format("Login '%s' '%s'", user, pw or ""))
    
    local results = { pcall(func, ...) }
    local ok = results[1]
    
    if currentUser then
        Cmd(string.format("Login '%s' ''", currentUser))
    end
    
    if not ok then
        error(results[2])
    end
end

local function asProgUser(func, ...)
	asUser(progUser.name, progUser.pw, func, ...)
end	

local POS_THRESHOLD = 32767
local POS_OFFSET = 65536

local function normalize_pos(val)
	if val and val > POS_THRESHOLD then
		return val - POS_OFFSET
	end
	return val
end

local function executeElevated(func, ...)
    local currentUser = CurrentUser()
    if prog_rights[currentUser.Rights] then
        return func(...)
    else
        return asProgUser(func, ...)
    end
end

return {
	normalize_pos = normalize_pos,
	asUser = asUser,
	asProgUser = asProgUser,
	prog_rights = prog_rights,
	executeElevated = executeElevated
}