local LoaderUtils = {}

LoaderUtils.DISCORD_INVITE = "https://discord.gg/9FT8yAf8MG"

LoaderUtils.Games = {
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
}

function LoaderUtils.getScriptURL(gameId)
    return LoaderUtils.Games[gameId]
end

function LoaderUtils.notify(StarterGui, title, text)
    local ok, err = pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)
    return ok, err
end

function LoaderUtils.copyInvite(invite, clipboardFns)
    local copied = false

    pcall(function()
        if clipboardFns.setclipboard then
            clipboardFns.setclipboard(invite)
            copied = true
        elseif clipboardFns.toclipboard then
            clipboardFns.toclipboard(invite)
            copied = true
        end
    end)

    return copied
end

function LoaderUtils.parseInviteCode(invite)
    return invite:match("discord%.gg/([%w%-_]+)")
        or invite:match("discord%.com/invite/([%w%-_]+)")
        or invite
end

function LoaderUtils.buildDiscordRPCPayload(HttpService, inviteCode)
    return HttpService:JSONEncode({
        cmd = "INVITE_BROWSER",
        args = {
            code = inviteCode
        },
        nonce = HttpService:GenerateGUID(false)
    })
end

function LoaderUtils.openDiscordInviteRPC(invite, deps)
    if not deps.req then
        return false
    end

    local inviteCode = LoaderUtils.parseInviteCode(invite)
    local payload = LoaderUtils.buildDiscordRPCPayload(deps.HttpService, inviteCode)

    local opened = false

    for port = 6463, 6472 do
        deps.taskSpawn(function()
            local ok = pcall(function()
                deps.req({
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

function LoaderUtils.isMobile(UserInputService)
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

return LoaderUtils
