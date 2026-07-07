local Utils = {}

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

Utils.req =
    request
    or http_request
    or (http and http.request)
    or (syn and syn.request)

function Utils.notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 6
        })
    end)
end

function Utils.copyToClipboard(text)
    local copied = false

    pcall(function()
        if setclipboard then
            setclipboard(text)
            copied = true
        elseif toclipboard then
            toclipboard(text)
            copied = true
        end
    end)

    return copied
end

function Utils.openDiscordInviteRPC(invite)
    if not Utils.req then
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
                Utils.req({
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

function Utils.isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function Utils.promptDiscordInvite(invite)
    if Utils.isMobile() then
        local copied = Utils.copyToClipboard(invite)

        if copied then
            Utils.notify("Discord Invite", "Invite copied to clipboard.")
        else
            Utils.notify("Discord Invite", invite)
        end

        print("Discord Invite:", invite)
    else
        Utils.openDiscordInviteRPC(invite)

        task.delay(1.5, function()
            Utils.copyToClipboard(invite)
            Utils.notify("Discord Invite", "Attempted to open Discord. Link copied as fallback.")
        end)
    end
end

return Utils
