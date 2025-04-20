local cloneref = cloneref or function(v) return v end
local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local Players: Players = cloneref(game:GetService('Players'))
local RBXAnalyticsService: RbxAnalyticsService = cloneref(game:GetService('RbxAnalyticsService'))
local lplr = Players.LocalPlayer
local whitelist = {
    data = {WhitelistedUsers = {}},
    checked = false,
    attackable = false,
    level = 0,
}

local suc, res = pcall(function()
    return HttpService:JSONDecode(readfile('polaris/libraries/whitelist.json'))
end)
whitelist.data = suc and type(res) == 'table' and res or whitelist.data

function whitelist:check()
    if self.checked then return self.level, self.attackable end
    self.checked = true
    for i,v in pairs(self.data.WhitelistedUsers) do
        if tostring(lplr.UserId) == i then
            self.level = v.level
            self.attackable = v.attackable
            break
        end
    end
    return self.level, self.attackable
end

function whitelist:get(plr: string): (number, boolean)
    if self.data.WhitelistedUsers[plr] then
        return self.data.WhitelistedUsers[plr].level, self.data.WhitelistedUsers[plr].attackable
    end
    return self.level, self.attackable
end

function whitelist:kill(func)
    if self.data.KillPolaris then
        return func()
    end
end

if whitelist.data.BlacklistedUsers[tostring(RBXAnalyticsService:GetClientId())] then
    return lplr:Kick(whitelist.data.BlacklistedUsers[tostring(RBXAnalyticsService:GetClientId())])
end

return whitelist