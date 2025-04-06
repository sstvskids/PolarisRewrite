local cloneref = cloneref or function(v) return v end
local HttpService: HttpService = cloneref(game:GetService("HttpService"))
for _,v in {'polaris', 'polaris/libraries', 'polaris/games', 'polaris/configs'} do
    if not isfolder(v) then makefolder(v) end
end

local suc, res = pcall(function()
    for _, v in {'', 'libraries', 'games'} do
        local url: string = game:HttpGet('https://api.github.com/repos/sstvskids/PolarisRewrite/contents/'..v)
        local jsonURL: table = HttpService:JSONDecode(url)
        for _, i in jsonURL do
            if i.type == 'file' then
                local file: string = 'polaris/'..i.path
                if isfile(file) then
                    delfile(file)
                    writefile(file, game:HttpGet(i.download_url))
                else
                    writefile(file, game:HttpGet(i.download_url))
                end
            end
        end
    end
end)

if suc then
    return loadfile('polaris/init.lua')()
else
    return warn('._stav on discord for issues like this: '..res)
end