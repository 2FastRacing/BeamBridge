-- BeamMP RCON Bridge Plugin
-- Author: Justin Stephens
-- Reads RCON commands from external bridge file and processes them

local M = {}

local commandFile = "Resources/Server/RCON-Connector/bridge/rcon_commands.json"
local responseFile = "Resources/Server/RCON-Connector/bridge/rcon_responses.json"
local seenCommands = {}
local lastReply = nil

-- Called on server init
function onInit()
    print("[RCONBridge] Plugin initializing...")

    -- Register event hook for external command processing
    MP.RegisterEvent("RCONPoll", "onRCONPoll")
    MP.CreateEventTimer("RCONPoll", 1000) -- every second

    -- Register listener for triggered RCON commands
    MP.RegisterEvent("onRconCommand", "onRconCommand")

    print("[RCONBridge] Plugin loaded successfully.")
end

-- Poll the command file for new entries
function onRCONPoll()
    if not FS.Exists(commandFile) then return end

    local content = io.open(commandFile, "r"):read("*a")
    if not content or content == "" then return end

    local data = Util.JsonDecode(content)
    if type(data) ~= "table" then
        print("[RCONBridge] ⚠️ Invalid JSON in rcon_commands.json")
        return
    end

    for _, cmd in ipairs(data) do
        if seenCommands[cmd.timestamp] then goto continue end

        local ip = cmd.ip or "?"
        local port = cmd.port or "?"
        local clientID = ip .. ":" .. port
        local command = (cmd.command or ""):gsub("%z", ""):gsub("%s+$", "")
        local password = cmd.password or ""
        local prefix = cmd.prefix or "rcon"

        print(string.format("[RCONBridge] ▶️ Received command from %s | [%s] %s", clientID, prefix, command))
        MP.TriggerGlobalEvent("onRconCommand", clientID, command, password, prefix)

        seenCommands[cmd.timestamp] = true
        ::continue::
    end

    -- If a reply was queued from a handler
    if lastReply then
        writeResponse({
            timestamp = lastReply.timestamp,
            to = lastReply.clientID,
            reply = lastReply.reply
        })
        lastReply = nil
    end
end

-- Handle the triggered RCON command
function M.onRconCommand(clientID, command, password, prefix)
    if password ~= "secret123" then
        print("[RCONBridge] ❌ Invalid password from " .. clientID)
        return
    end

    print(string.format("[RCONBridge] ✅ Valid command from %s: %s", clientID, command))

    local chatCommand = "/" .. command

    local ok, err = pcall(function()
        MP.TriggerGlobalEvent("onChatMessage", -1, "RCON", chatCommand)
    end)

    if not ok then
        print("[RCONBridge] ❌ Failed to dispatch chat command: " .. tostring(err))
    else
        print("[RCONBridge] 🛠️ Dispatched as chat: " .. chatCommand)
    end

    lastReply = {
        timestamp = os.time(),
        clientID = clientID,
        reply = "BeamMP dispatched: " .. command
    }
end


-- Write response back to JSON file
function writeResponse(entry)
    local responses = {}
    if FS.Exists(responseFile) then
        local content = io.open(responseFile, "r"):read("*a")
        responses = Util.JsonDecode(content) or {}
    end

    table.insert(responses, entry)

    FS.CreateDirectory(FS.GetParentFolder(responseFile))
    local f = io.open(responseFile, "w")
    f:write(Util.JsonPrettify(Util.JsonEncode(responses)))
    f:close()
end

MP.RegisterEvent("onInit", "onInit")

return M
