package.path = package.path .. ";../?.lua;../Modules/?.lua;./?.lua;./mocks/?.lua"

local lu = require("luaunit")
local LoaderUtils = require("Modules.LoaderUtils")
local Mocks = require("Tests.mocks.roblox")

-- ============================================================
-- Game ID Mapping
-- ============================================================

TestGameMapping = {}

function TestGameMapping:test_known_game_ids_return_urls()
    local expectedMappings = {
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

    for id, scriptName in pairs(expectedMappings) do
        local url = LoaderUtils.getScriptURL(id)
        lu.assertNotNil(url, "Expected URL for game ID " .. id)
        lu.assertStrContains(url, scriptName .. ".lua")
        lu.assertStrContains(url, "https://raw.githubusercontent.com/Nanana291/Kronos/")
    end
end

function TestGameMapping:test_unknown_game_id_returns_nil()
    lu.assertNil(LoaderUtils.getScriptURL(0))
    lu.assertNil(LoaderUtils.getScriptURL(9999999999))
    lu.assertNil(LoaderUtils.getScriptURL(-1))
end

function TestGameMapping:test_games_table_has_expected_count()
    local count = 0
    for _ in pairs(LoaderUtils.Games) do
        count = count + 1
    end
    lu.assertEquals(count, 15)
end

function TestGameMapping:test_all_urls_point_to_main_branch()
    for id, url in pairs(LoaderUtils.Games) do
        lu.assertStrContains(url, "refs/heads/main/Scripts/",
            "URL for game " .. id .. " should point to main branch")
    end
end

function TestGameMapping:test_all_urls_are_valid_github_raw_urls()
    for id, url in pairs(LoaderUtils.Games) do
        lu.assertStrContains(url, "https://raw.githubusercontent.com/",
            "URL for game " .. id .. " should be a GitHub raw URL")
        lu.assertTrue(url:match("%.lua$") ~= nil,
            "URL for game " .. id .. " should end with .lua")
    end
end

-- ============================================================
-- Notify
-- ============================================================

TestNotify = {}

function TestNotify:test_sends_notification()
    local gui = Mocks.createStarterGui()
    local ok = LoaderUtils.notify(gui, "Test Title", "Test Text")

    lu.assertTrue(ok)
    lu.assertEquals(#gui.notifications, 1)
    lu.assertEquals(gui.notifications[1].Title, "Test Title")
    lu.assertEquals(gui.notifications[1].Text, "Test Text")
    lu.assertEquals(gui.notifications[1].Duration, 6)
end

function TestNotify:test_handles_setcore_failure_gracefully()
    local gui = Mocks.createStarterGui({ shouldFail = true })
    local ok = LoaderUtils.notify(gui, "Title", "Text")

    lu.assertFalse(ok)
    lu.assertEquals(#gui.notifications, 0)
end

function TestNotify:test_empty_strings()
    local gui = Mocks.createStarterGui()
    local ok = LoaderUtils.notify(gui, "", "")

    lu.assertTrue(ok)
    lu.assertEquals(gui.notifications[1].Title, "")
    lu.assertEquals(gui.notifications[1].Text, "")
end

function TestNotify:test_special_characters_in_notification()
    local gui = Mocks.createStarterGui()
    local ok = LoaderUtils.notify(gui, "Title & <special>", 'Text "with" quotes')

    lu.assertTrue(ok)
    lu.assertEquals(gui.notifications[1].Title, "Title & <special>")
    lu.assertEquals(gui.notifications[1].Text, 'Text "with" quotes')
end

-- ============================================================
-- CopyInvite
-- ============================================================

TestCopyInvite = {}

function TestCopyInvite:test_copies_with_setclipboard()
    local fns = Mocks.createClipboardFns({ hasSetclipboard = true })
    local copied = LoaderUtils.copyInvite("https://discord.gg/test", fns)

    lu.assertTrue(copied)
    lu.assertEquals(fns.lastCopied, "https://discord.gg/test")
end

function TestCopyInvite:test_copies_with_toclipboard_fallback()
    local fns = Mocks.createClipboardFns({ hasToclipboard = true })
    local copied = LoaderUtils.copyInvite("https://discord.gg/test", fns)

    lu.assertTrue(copied)
    lu.assertEquals(fns.lastCopied, "https://discord.gg/test")
end

function TestCopyInvite:test_prefers_setclipboard_over_toclipboard()
    local fns = Mocks.createClipboardFns({ hasSetclipboard = true, hasToclipboard = true })
    local setUsed = false
    local toUsed = false

    fns.setclipboard = function(text)
        setUsed = true
        fns.lastCopied = text
    end
    fns.toclipboard = function(text)
        toUsed = true
        fns.lastCopied = text
    end

    LoaderUtils.copyInvite("https://discord.gg/test", fns)
    lu.assertTrue(setUsed)
    lu.assertFalse(toUsed)
end

function TestCopyInvite:test_returns_false_without_clipboard_functions()
    local fns = Mocks.createClipboardFns({})
    local copied = LoaderUtils.copyInvite("https://discord.gg/test", fns)

    lu.assertFalse(copied)
end

function TestCopyInvite:test_handles_clipboard_error_gracefully()
    local fns = {
        setclipboard = function()
            error("clipboard unavailable")
        end
    }
    local copied = LoaderUtils.copyInvite("https://discord.gg/test", fns)

    lu.assertFalse(copied)
end

-- ============================================================
-- ParseInviteCode
-- ============================================================

TestParseInviteCode = {}

function TestParseInviteCode:test_parses_discord_gg_url()
    lu.assertEquals(LoaderUtils.parseInviteCode("https://discord.gg/9FT8yAf8MG"), "9FT8yAf8MG")
end

function TestParseInviteCode:test_parses_discord_gg_without_https()
    lu.assertEquals(LoaderUtils.parseInviteCode("discord.gg/abcdef"), "abcdef")
end

function TestParseInviteCode:test_parses_discord_com_invite_url()
    lu.assertEquals(LoaderUtils.parseInviteCode("https://discord.com/invite/xyz123"), "xyz123")
end

function TestParseInviteCode:test_returns_raw_code_if_no_match()
    lu.assertEquals(LoaderUtils.parseInviteCode("someRawCode123"), "someRawCode123")
end

function TestParseInviteCode:test_handles_hyphen_in_code()
    lu.assertEquals(LoaderUtils.parseInviteCode("https://discord.gg/my-server"), "my-server")
end

function TestParseInviteCode:test_handles_underscore_in_code()
    lu.assertEquals(LoaderUtils.parseInviteCode("https://discord.gg/my_server"), "my_server")
end

function TestParseInviteCode:test_prefers_discord_gg_pattern()
    local code = LoaderUtils.parseInviteCode("discord.gg/first")
    lu.assertEquals(code, "first")
end

function TestParseInviteCode:test_empty_code_after_slash()
    -- Pattern requires at least one character
    local result = LoaderUtils.parseInviteCode("discord.gg/")
    lu.assertEquals(result, "discord.gg/")
end

-- ============================================================
-- BuildDiscordRPCPayload
-- ============================================================

TestBuildRPCPayload = {}

function TestBuildRPCPayload:test_builds_valid_payload()
    local http = Mocks.createHttpService()
    local payload = LoaderUtils.buildDiscordRPCPayload(http, "testCode")

    lu.assertNotNil(payload)
    lu.assertStrContains(payload, "INVITE_BROWSER")
    lu.assertStrContains(payload, "testCode")
    lu.assertEquals(#http.encodeCalls, 1)
    lu.assertEquals(http.encodeCalls[1].cmd, "INVITE_BROWSER")
    lu.assertEquals(http.encodeCalls[1].args.code, "testCode")
end

function TestBuildRPCPayload:test_generates_unique_nonce()
    local http = Mocks.createHttpService()
    LoaderUtils.buildDiscordRPCPayload(http, "code1")
    LoaderUtils.buildDiscordRPCPayload(http, "code2")

    local nonce1 = http.encodeCalls[1].nonce
    local nonce2 = http.encodeCalls[2].nonce
    lu.assertNotEquals(nonce1, nonce2)
end

-- ============================================================
-- OpenDiscordInviteRPC
-- ============================================================

TestOpenDiscordInviteRPC = {}

function TestOpenDiscordInviteRPC:test_returns_false_without_req()
    local result = LoaderUtils.openDiscordInviteRPC("https://discord.gg/test", {
        req = nil,
        HttpService = Mocks.createHttpService(),
        taskSpawn = Mocks.createTaskSpawn(),
    })
    lu.assertFalse(result)
end

function TestOpenDiscordInviteRPC:test_sends_requests_to_ports_6463_through_6472()
    local reqFn = Mocks.createRequestFn()
    local result = LoaderUtils.openDiscordInviteRPC("https://discord.gg/testCode", {
        req = reqFn,
        HttpService = Mocks.createHttpService(),
        taskSpawn = Mocks.createTaskSpawn(),
    })

    lu.assertEquals(#reqFn.calls, 10)
    local ports = {}
    for _, call in ipairs(reqFn.calls) do
        local port = call.Url:match(":(%d+)/")
        ports[tonumber(port)] = true
    end
    for port = 6463, 6472 do
        lu.assertTrue(ports[port], "Should have sent request to port " .. port)
    end
end

function TestOpenDiscordInviteRPC:test_request_has_correct_headers()
    local reqFn = Mocks.createRequestFn()
    LoaderUtils.openDiscordInviteRPC("https://discord.gg/test", {
        req = reqFn,
        HttpService = Mocks.createHttpService(),
        taskSpawn = Mocks.createTaskSpawn(),
    })

    for _, call in ipairs(reqFn.calls) do
        lu.assertEquals(call.Method, "POST")
        lu.assertEquals(call.Headers["Content-Type"], "application/json")
        lu.assertEquals(call.Headers["Origin"], "https://discord.com")
    end
end

function TestOpenDiscordInviteRPC:test_parses_invite_code_from_url()
    local reqFn = Mocks.createRequestFn()
    local http = Mocks.createHttpService()
    LoaderUtils.openDiscordInviteRPC("https://discord.gg/myCode123", {
        req = reqFn,
        HttpService = http,
        taskSpawn = Mocks.createTaskSpawn(),
    })

    lu.assertEquals(http.encodeCalls[1].args.code, "myCode123")
end

function TestOpenDiscordInviteRPC:test_handles_request_failure_gracefully()
    local reqFn = Mocks.createRequestFn({ shouldFail = true })
    local result = LoaderUtils.openDiscordInviteRPC("https://discord.gg/test", {
        req = reqFn,
        HttpService = Mocks.createHttpService(),
        taskSpawn = Mocks.createTaskSpawn(),
    })

    lu.assertFalse(result)
end

function TestOpenDiscordInviteRPC:test_deferred_spawn_collects_callbacks()
    local spawn = Mocks.createTaskSpawn({ executeImmediately = false })
    LoaderUtils.openDiscordInviteRPC("https://discord.gg/test", {
        req = Mocks.createRequestFn(),
        HttpService = Mocks.createHttpService(),
        taskSpawn = spawn,
    })

    lu.assertEquals(#spawn.callbacks, 10)
end

-- ============================================================
-- IsMobile
-- ============================================================

TestIsMobile = {}

function TestIsMobile:test_desktop_with_keyboard()
    local uis = Mocks.createUserInputService({
        TouchEnabled = false,
        KeyboardEnabled = true,
    })
    lu.assertFalse(LoaderUtils.isMobile(uis))
end

function TestIsMobile:test_mobile_touch_only()
    local uis = Mocks.createUserInputService({
        TouchEnabled = true,
        KeyboardEnabled = false,
    })
    lu.assertTrue(LoaderUtils.isMobile(uis))
end

function TestIsMobile:test_tablet_with_keyboard_not_mobile()
    local uis = Mocks.createUserInputService({
        TouchEnabled = true,
        KeyboardEnabled = true,
    })
    lu.assertFalse(LoaderUtils.isMobile(uis))
end

function TestIsMobile:test_no_input_not_mobile()
    local uis = Mocks.createUserInputService({
        TouchEnabled = false,
        KeyboardEnabled = false,
    })
    lu.assertFalse(LoaderUtils.isMobile(uis))
end

-- ============================================================
-- DISCORD_INVITE constant
-- ============================================================

TestConstants = {}

function TestConstants:test_discord_invite_is_set()
    lu.assertNotNil(LoaderUtils.DISCORD_INVITE)
    lu.assertStrContains(LoaderUtils.DISCORD_INVITE, "discord.gg/")
end

function TestConstants:test_discord_invite_matches_loader()
    lu.assertEquals(LoaderUtils.DISCORD_INVITE, "https://discord.gg/9FT8yAf8MG")
end

os.exit(lu.LuaUnit.run())
