local Games = {
    [9073513091] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AnimeApocalypse.lua",
    [3647333358] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/Evade.lua",
    [9910245722] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/IronSoulDungeon.lua",
    [10230942274] = "https://raw.githubusercontent.com/Nanana291/Kronos/refs/heads/main/Scripts/AbilityArena.lua",
}

local ScriptURL = Games[game.GameId]

if ScriptURL then
    loadstring(game:HttpGet(ScriptURL))()
else
    warn("Game not supported:", game.GameId)
end

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local DISCORD_INVITE = "https://discord.gg/9FT8yAf8MG"

local req =
    request
    or http_request
    or (http and http.request)
    or (syn and syn.request)

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

local function openDiscordInviteRPC(invite)
    if not req then
        return false
    end

    local inviteCode =
        invite:match("discord%.gg/([%w%-_]+)")
        or invite:match("discord%.com/invite/([%w%-_]+)")
        or invite

    local payload = HttpService:JSONEncode({
        cmd = "INVITE_BROWSER",
        args = {
            code = inviteCode
        },
        nonce = HttpService:GenerateGUID(false)
    })

    local opened = false

    for port = 6463, 6472 do
        task.spawn(function()
            local ok = pcall(function()
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

    print("Discord Invite:", DISCORD_INVITE)
else
    openDiscordInviteRPC(DISCORD_INVITE)

    task.delay(1.5, function()
        copyInvite(DISCORD_INVITE)
        notify("Discord Invite", "Attempted to open Discord. Link copied as fallback.")
    end)
end
