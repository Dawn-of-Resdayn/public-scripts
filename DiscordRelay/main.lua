local DiscordRelay = {}

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

function DiscordRelay.DiscordCheckMessage(code)
    if not (code == 204) then
        tes3mp.LogMessage(enumerations.log.WARN, "[DiscordRelay] Failed to send message, Responce was " .. code)
        return false
    else
        return true
    end
end

function DiscordRelay.DiscordSendMessage(sender, message, type)
  local message = message
  local type = type or ""

  if message == "" then
    return
  end

  if DiscordRelay.config.discord.usePlayerName == false then
    message = sender..": "..message
  end

  if type == "ooc" then
    message = "(OOC) "..message:gsub("//", "")
  elseif type == "looc" then
    message = "(LOOC) "..message:gsub("///", "")
  elseif type == "con" then
    message = "(CONNECTION) "..message
  end

  local t = {
      ["content"] = tostring(message),
      ["username"] = tostring(sender)
  }
  local data = json.encode(t)
  local response_body = {}
  local res, code, responce_headers, status = https.request{
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

  if DiscordRelay.DiscordCheckMessage(code) == true then
    tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] Message send successfully")
  else
    tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] Message failed to send")
    tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] \n"..data)
  end
end

function DiscordRelay.Discord_PingTest()
    if (DiscordRelay.config.send_ping_on_startup == true) then
        DiscordRelay.DiscordSendMessage("TES3MP Relay", "Pong!")

        if (DiscordRelay.Discord_CheckMessage(code) == true) then
            tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] Pinged Discord Successfully")
        else
            return false
        end
    end
end

function DiscordRelay.OnPlayerSendMessage(eventStatus, pid, message)
  local playerName = GetPlayerName(pid)
  local botName = playerName
  local message = message
  local type = ""

  if message == lastMessage and pid == lastMessageSenderPID and layers[pid].data.settings.staffRank < 0 then
    tes3mp.LogMessage(enumerations.log.INFO, "[DiscordRelay] Assuming is spam, Blocking message to discord.")
    lastMessage = tostring(message)
    lastMessageSenderPID = pid
    return
  end

  if message:sub(1, 3) == "///" then
    type = "looc"
  elseif message:sub(1, 2) == "//" then
    if DiscordRelay.rpchatconfig.toggleOOC == false and Players[pid].data.settings.staffRank <= 0 then
      return
    end

    type = "ooc"
  else
    return
  end

  if not DiscordRelay.config.discord.usePlayerName then
    message = playerName..": "..message
    botName = DiscordRelay.config.discord.botUsername
  end

  DiscordRelay.DiscordSendMessage(botName, message, type)
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

function DiscordRelay.loginHandler(eventStatus, pid)
  local botName = DiscordRelay.config.discord.botUsername
  local message = "Player "..Players[pid].name.."("..pid..") as joined the server."

  DiscordRelay.DiscordSendMessage(botName, message, "con")
end

customEventHooks.registerValidator("OnPlayerSendMessage", DiscordRelay.OnPlayerSendMessage)
customEventHooks.registerHandler("OnServerPostInit", DiscordRelay.OnServerPostInit)
customEventHooks.registerHandler("OnServerPostInit", DiscordRelay.Discord_PingTest)
customEventHooks.registerHandler("OnPlayerDisconnect", function(eventStatus, pid)
  local playerName = logicHandler.GetChatName(pid)
  local botName = DiscordRelay.config.discord.botUsername
  --local message = "Player "..playerName.."("..pid..") as left the server."
  local message = "Player ID "..pid.." as left the server."

  DiscordRelay.DiscordSendMessage(botName, message, "con")
end)
customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
  local botName = DiscordRelay.config.discord.botUsername
  local message = "Player "..Players[pid].name.."("..pid..") as logged into the server."

  DiscordRelay.DiscordSendMessage(botName, message, "con")
end)
customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
  local botName = DiscordRelay.config.discord.botUsername
  local message = "Player "..Players[pid].name.."("..pid..") as finished creating their character."

  DiscordRelay.DiscordSendMessage(botName, message, "con")
end)
