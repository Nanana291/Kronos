local Games = {
    [9073513091] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AnimeApocalypse.lua",
    [3647333358] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/Evade.lua",
}

local ScriptURL = Games[game.GameId]

if ScriptURL then
    loadstring(game:HttpGet(ScriptURL))()
else
    warn("Game not supported:", game.GameId)
end
