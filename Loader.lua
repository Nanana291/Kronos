local BASE_URL = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/"
local UTILS_URL = BASE_URL .. "Utils.lua"
local DISCORD_INVITE = "https://discord.gg/9FT8yAf8MG"

local Games = {
    [9073513091]  = "AnimeApocalypse",
    [3647333358]  = "Evade",
    [9910245722]  = "IronSoulDungeon",
    [10230942274] = "AbilityArena",
    [8356066619]  = "AnimeSquadron",
    [9965411707]  = "NoobIncremental",
    [1268927906]  = "MuscleLegends",
    [1176784616]  = "TowerDefenseSimulator",
    [1235188606]  = "DragonAdventures",
    [7546582051]  = "DungeonHeroes",
    [4568630521]  = "HeroesBattlegrounds",
    [9382839773]  = "LineagePiece",
    [10178802449] = "MineClick",
    [9073775318]  = "SlimeRpg",
    [578392296]   = "AnimeBattleArena",
}

local scriptName = Games[game.GameId]

if scriptName then
    loadstring(game:HttpGet(BASE_URL .. scriptName .. ".lua"))()
else
    warn("Game not supported:", game.GameId)
end

local Utils = loadstring(game:HttpGet(UTILS_URL))()

Utils.promptDiscordInvite(DISCORD_INVITE)
