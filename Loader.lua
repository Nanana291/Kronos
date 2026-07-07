local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local TRUSTED_URL_PREFIX = "https://raw.githubusercontent.com/Nanana291/Kronos/"
local DISCORD_INVITE = "https://discord.gg/9FT8yAf8MG"

local Games = {
    [9073513091] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/AnimeApocalypse.lua",
    [3647333358] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/Evade.lua",
    [9910245722] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/IronSoulDungeon.lua",
    [10230942274] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/AbilityArena.lua",
    [8356066619] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/AnimeSquadron.lua",
    [9965411707] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/NoobIncremental.lua",
    [1268927906] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/MuscleLegends.lua",
    [1176784616] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/TowerDefenseSimulator.lua",
    [1235188606] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/DragonAdventures.lua",
    [7546582051] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/DungeonHeroes.lua",
    [4568630521] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/HeroesBattlegrounds.lua",
    [9382839773] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/LineagePiece.lua",
    [10178802449] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/MineClick.lua",
    [9073775318] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/SlimeRpg.lua",
    [578392296] = TRUSTED_URL_PREFIX .. "refs/heads/main/Scripts/AnimeBattleArena.lua",
}

local function isTrustedURL(url)
    return type(url) == "string"
        and url:sub(1, #TRUSTED_URL_PREFIX) == TRUSTED_URL_PREFIX
        and not url:find("%.%.")
        and url:match("%.lua$") ~= nil
end

local function loadGameScript()
    local scriptURL = Games[game.GameId]
    if not scriptURL then
        warn("[Kronos] Game not supported:", game.GameId)
        return
    end

    if not isTrustedURL(scriptURL) then
        warn("[Kronos] Blocked untrusted URL:", scriptURL)
        return
    end

    local ok, source = pcall(function()
        return game:HttpGet(scriptURL)
    end)

    if not ok or type(source) ~= "string" or #source == 0 then
        warn("[Kronos] Failed to fetch script:", scriptURL)
        return
    end

    local fn, compileErr = loadstring(source)
    if not fn then
        warn("[Kronos] Failed to compile script:", compileErr)
        return
    end

    local execOk, execErr = pcall(fn)
    if not execOk then
        warn("[Kronos] Script runtime error:", execErr)
    end
end

loadGameScript()

local req =
    (typeof(request) == "function" and request)
    or (typeof(http_request) == "function" and http_request)
    or (type(http) == "table" and typeof(http.request) == "function" and http.request)
    or (type(syn) == "table" and typeof(syn.request) == "function" and syn.request)
    or nil

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)
end

local function copyInvite(invite)
    local copied = false

    pcall(function()
        if setclipboard then
            setclipboard(invite)
            copied = true
        elseif toclipboard then
            toclipboard(invite)
            copied = true
        end
    end)

    return copied
end

local DISCORD_RPC_PORT_MIN = 6463
local DISCORD_RPC_PORT_MAX = 6472

local function openDiscordInviteRPC(invite)
    if not req then
        return false
    end

    local inviteCode =
        invite:match("discord%.gg/([%w%-_]+)")
        or invite:match("discord%.com/invite/([%w%-_]+)")

    if not inviteCode or #inviteCode == 0 then
        return false
    end

    local payload = HttpService:JSONEncode({
        cmd = "INVITE_BROWSER",
        args = {
            code = inviteCode
        },
        nonce = HttpService:GenerateGUID(false)
    })

    local opened = false

    for port = DISCORD_RPC_PORT_MIN, DISCORD_RPC_PORT_MAX do
        if opened then break end

        task.spawn(function()
            local ok = pcall(function()
                req({
                    Url = ("http://127.0.0.1:%d/rpc?v=1"):format(port),
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                    },
                    Body = payload
                })
            end)

            if ok then
                opened = true
            end
        end)
    end

    return opened
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobile then
    local copied = copyInvite(DISCORD_INVITE)

    if copied then
        notify("Discord Invite", "Invite copied to clipboard.")
    else
        notify("Discord Invite", DISCORD_INVITE)
    end
else
    openDiscordInviteRPC(DISCORD_INVITE)

    task.delay(1.5, function()
        copyInvite(DISCORD_INVITE)
        notify("Discord Invite", "Attempted to open Discord. Link copied as fallback.")
    end)
end
