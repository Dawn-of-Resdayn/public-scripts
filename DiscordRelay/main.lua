local DiscordRelay = {}

DiscordRelay.scriptName = "DiscordRelay"

DiscordRelay.config = require("custom/DiscordRelay/config")
if DiscordRelay.config.use_rpchat then
    DiscordRelay.rpchatconfig = require("custom/rpchat/config")
end

json = require("dkjson")
https = require("ssl.https")

local lastMessage = ""
local lastMessageSenderPID = 0

local function GetPlayerName(pid)
  local accountName = Players[pid].name

  if DiscordRelay.config.use_tes3mp_getName then
    accountName = tes3mp.GetName(pid)
  end

  if not config.use_rpchat == true then
    return accountName
  end

  if Players[pid].customVariables.rpchat then
    return Players[pid].customVariables.rpchat.name.."("..accountName..")"
  end
end

function DiscordRelay.OnServerPostInit()
    if (DiscordRelay.config.discord.webhook_url == "" or DiscordRelay.config.discord.webhook_url == nil) then
        tes3mp.LogMessage(enumerations.log.ERROR, "[DiscordRelay] " .. "webhook_url is blank or empty.")
    end
    if not (DiscordRelay.config.use_tes3mp_getName == true or DiscordRelay.config.use_tes3mp_getName == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, "[DiscordRelay] " .. "use_tes3mp_getName can only be true/false.")
    end
    if not (DiscordRelay.config.send_ping_on_startup == true or DiscordRelay.config.send_ping_on_startup == false) then
        tes3mp.LogMessage(enumerations.log.ERROR, "[DiscordRelay] " .. "send_ping_on_startup can only be true/false.")
    end

    tes3mp.LogMessage(enumerations.log.INFO, "[DISCORD-RELAY]: DiscordRelay loaded (through scriptHook)")
end

function DiscordRelay.Discord_CheckMessage(code)
    if not (code == 204) then
        tes3mp.LogMessage(enumerations.log.WARN, "[DiscordRelay] " .. "Failed to send message, Responce was " .. code)
        return false
    else
        return true
    end
end

function DiscordRelay.Discord_PingTest()
    if (DiscordRelay.config.send_ping_on_startup == true) then
        local message = "Pong!"
        local BotName = "DiscordRelay"
        local t = {
            ["content"] = tostring(message),
            ["username"] = tostring(BotName)
        }
        local data = json.encode(t)
        local response_body = {}
        local res, code, responce_headers, status =
            https.request {
            url = DiscordRelay.config.discord.webhook_url,
            method = "POST",
            protocol = "tlsv1_2",
            headers = {
                ["Content-Type"] = "application/json",
                ["Content-Length"] = string.len(data)
            },
            source = ltn12.source.string(data),
            sink = ltn12.sink.table(response_body)
        }
        if (DiscordRelay.Discord_CheckMessage(code) == true) then
            tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] " .. "Pinged Discord Successfully")
        else
            return false
        end
    end
end

function DiscordRelay.Discord_SendMessage(eventStatus, pid, message)
    local Playername = ""
    local message = message

    if message:sub(1, 3) == "///" then
        message = "(LOOC) " .. message:gsub("///", "")
    elseif message:sub(1, 2) == "//" then
        if DiscordRelay.rpchatconfig.toggleOOC == false and Players[pid].data.settings.staffRank <= 0 then
            message = ""
        else
            message = "(OOC) " .. message:gsub("//", "")
        end
    else
        return
    end

    if (DiscordRelay.config.discord.usePlayerName == true) then
        Playername = GetPlayerName(pid)
    else
        Playername = DiscordRelay.config.discord.botUsername
    end

    local t = {
        ["content"] = tostring(message),
        ["username"] = tostring(Playername)
    }

    if message == "" then
      return
    end

    if tostring(message) ~= lastMessage or Players[pid].data.settings.staffRank > 0 then
        if (lastMessageSenderPID == pid and lastMessage == tostring(message) and (Players[pid].data.settings.staffRank < 0)) then
            print("Assuming is spam, Blocking message to discord.")
            lastMessage = tostring(message)
            lastMessageSenderPID = pid
        else
            lastMessage = tostring(message)
            lastMessageSenderPID = pid
            local data = json.encode(t)
            local response_body = {}
            local res, code, responce_headers, status =
                https.request {
                url = DiscordRelay.config.discord.webhook_url,
                method = "POST",
                protocol = "tlsv1_2",
                headers = {
                    ["Content-Type"] = "application/json",
                    ["Content-Length"] = string.len(data)
                },
                source = ltn12.source.string(data),
                sink = ltn12.sink.table(response_body)
            }
            if (DiscordRelay.Discord_CheckMessage(code) == true) then
                tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] " .. "Message Send Successfully")
            else
                tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] " .. "Message Did not send Successfully")
                tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] " .. "\n" .. data)
            end
        end
    end
end

customEventHooks.registerValidator("OnPlayerSendMessage", DiscordRelay.Discord_SendMessage)
customEventHooks.registerHandler("OnServerPostInit", DiscordRelay.OnServerPostInit)
customEventHooks.registerHandler("OnServerPostInit", DiscordRelay.Discord_PingTest)
