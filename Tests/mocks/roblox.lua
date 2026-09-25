local Mocks = {}

function Mocks.createStarterGui(opts)
    opts = opts or {}
    local gui = {}
    gui.notifications = {}
    gui.shouldFail = opts.shouldFail or false

    function gui:SetCore(action, data)
        if self.shouldFail then
            error("SetCore failed")
        end
        if action == "SendNotification" then
            table.insert(self.notifications, data)
        end
    end

    return gui
end

function Mocks.createHttpService()
    local svc = {}
    svc.encodeCalls = {}
    svc.guidCounter = 0

    function svc:JSONEncode(data)
        table.insert(self.encodeCalls, data)
        local parts = {}
        for k, v in pairs(data) do
            if type(v) == "string" then
                table.insert(parts, string.format('"%s":"%s"', k, v))
            elseif type(v) == "table" then
                local inner = {}
                for ik, iv in pairs(v) do
                    table.insert(inner, string.format('"%s":"%s"', ik, iv))
                end
                table.insert(parts, string.format('"%s":{%s}', k, table.concat(inner, ",")))
            end
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end

    function svc:GenerateGUID(braces)
        self.guidCounter = self.guidCounter + 1
        local guid = string.format("00000000-0000-0000-0000-%012d", self.guidCounter)
        if braces then
            return "{" .. guid .. "}"
        end
        return guid
    end

    return svc
end

function Mocks.createUserInputService(opts)
    opts = opts or {}
    return {
        TouchEnabled = opts.TouchEnabled or false,
        KeyboardEnabled = opts.KeyboardEnabled == nil and true or opts.KeyboardEnabled,
    }
end

function Mocks.createClipboardFns(opts)
    opts = opts or {}
    local fns = {}
    fns.lastCopied = nil

    if opts.hasSetclipboard then
        fns.setclipboard = function(text)
            fns.lastCopied = text
        end
    end

    if opts.hasToclipboard then
        fns.toclipboard = function(text)
            fns.lastCopied = text
        end
    end

    return fns
end

function Mocks.createRequestFn(opts)
    opts = opts or {}
    local fn = {}
    fn.calls = {}
    fn.shouldFail = opts.shouldFail or false

    setmetatable(fn, {
        __call = function(self, request)
            table.insert(self.calls, request)
            if self.shouldFail then
                error("Request failed")
            end
            return { StatusCode = 200 }
        end
    })

    return fn
end

function Mocks.createTaskSpawn(opts)
    opts = opts or {}
    local spawn = {}
    spawn.callbacks = {}
    spawn.executeImmediately = opts.executeImmediately == nil and true or opts.executeImmediately

    setmetatable(spawn, {
        __call = function(self, fn)
            if self.executeImmediately then
                fn()
            else
                table.insert(self.callbacks, fn)
            end
        end
    })

    return spawn
end

return Mocks
