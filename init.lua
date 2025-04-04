local FilePath = "polaris/games/"..game.PlaceId..".lua"
if isfile(FilePath) then
    return loadfile(FilePath)()
else
    return loadfile('polaris/universal.lua')()
end