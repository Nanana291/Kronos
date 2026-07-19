local Games = {
    [9073513091] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AnimeApocalypse.lua",
    [3647333358] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/Evade.lua",
    [9910245722] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/IronSoulDungeon.lua",
    [10230942274] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AbilityArena.lua",
    [8356066619] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AnimeSquadron.lua",
    [9965411707] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/NoobIncremental.lua",
    [1268927906] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/MuscleLegends.lua",
    [1176784616] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/TowerDefenseSimulator.lua",
    [1235188606] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/DragonAdventures.lua",
    [7546582051] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/DungeonHeroes.lua",
    [4568630521] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/HeroesBattlegrounds.lua",
    [9382839773] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/LineagePiece.lua",
    [10178802449] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/MineClick.lua",
    [9073775318] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/SlimeRpg.lua",
    [578392296] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AnimeBattleArena.lua",
    [1511883870] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/ShindoLife.lua",
    [10406668651] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/MinePlanet.lua",
    [10421154706] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/BeFinalBoss.lua",
}

local ok, HttpService = pcall(game.GetService, game, "HttpService")
if not ok then
    warn("[Kronos] Failed to get HttpService:", HttpService)
    return
end

local ok2, UserInputService = pcall(game.GetService, game, "UserInputService")
if not ok2 then
    warn("[Kronos] Failed to get UserInputService:", UserInputService)
    return
end

local ok3, StarterGui = pcall(game.GetService, game, "StarterGui")
if not ok3 then
    warn("[Kronos] Failed to get StarterGui:", StarterGui)
    return
end

local ScriptURL = Games[game.GameId]

if ScriptURL then
    local fetchOk, source = pcall(game.HttpGet, game, ScriptURL)
    if not fetchOk then
        warn("[Kronos] Failed to fetch script:", source)
    else
        local loadOk, loader = pcall(loadstring, source)
        if not loadOk or not loader then
            warn("[Kronos] Failed to compile script:", loader or "loadstring returned nil")
        else
            local execOk, execErr = pcall(loader)
            if not execOk then
                warn("[Kronos] Script execution error:", execErr)
            end
        end
    end
else
    warn("[Kronos] Game not supported:", game.GameId)
end

local DISCORD_INVITE = "https://discord.gg/9FT8yAf8MG"

local req =
    request
    or http_request
    or (http and http.request)
    or (syn and syn.request)

local function notify(title, text)
    local success, err = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)

    if not success then
        warn("[Kronos] Notification failed:", err)
    end

    return success
end

local function copyInvite(invite)
    local copied = false

    local success, err = pcall(function()
        if setclipboard then
            setclipboard(invite)
            copied = true
        elseif toclipboard then
            toclipboard(invite)
            copied = true
        end
    end)

    if not success then
        warn("[Kronos] Clipboard copy failed:", err)
    end

    return copied
end

local function openDiscordInviteRPC(invite)
    if not req then
        warn("[Kronos] No HTTP request function available for Discord RPC")
        return false
    end

    local inviteCode =
        invite:match("discord%.gg/([%w%-_]+)")
        or invite:match("discord%.com/invite/([%w%-_]+)")
        or invite

    local encodeOk, payload = pcall(HttpService.JSONEncode, HttpService, {
        cmd = "INVITE_BROWSER",
        args = {
            code = inviteCode
        },
        nonce = HttpService:GenerateGUID(false)
    })

    if not encodeOk then
        warn("[Kronos] Failed to encode Discord RPC payload:", payload)
        return false
    end

    local opened = false

    for port = 6463, 6472 do
        local reqOk, reqErr = pcall(function()
            req({
                Url = ("http://127.0.0.1:%d/rpc?v=1"):format(port),
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Origin"] = "https://discord.com"
                },
                Body = payload
            })
        end)

        if reqOk then
            opened = true
            break
        end
    end

    if not opened then
        warn("[Kronos] Discord RPC failed on all ports (6463-6472)")
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

    print("[Kronos] Discord Invite:", DISCORD_INVITE)
else
    local rpcOpened = openDiscordInviteRPC(DISCORD_INVITE)

    if rpcOpened then
        notify("Discord Invite", "Discord opened via RPC.")
    else
        local copied = copyInvite(DISCORD_INVITE)
        if copied then
            notify("Discord Invite", "Could not open Discord. Link copied to clipboard.")
        else
            notify("Discord Invite", DISCORD_INVITE)
        end
    end

    print("[Kronos] Discord Invite:", DISCORD_INVITE)
end
