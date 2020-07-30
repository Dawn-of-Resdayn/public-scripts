rpconfig = require("custom/rpchat/config")

local rpchat = {}
local messageHandlers = {}

function rpchat.initPlayer(pid)
	local name = Players[pid].name

	if not Players[pid].data.customVariables.rpchat then
		Players[pid].data.customVariables.rpchat = {
			["name"] = rpchat.correctName(name),
			["color"] = color.White,
		}
	end
end

function rpchat.format(message)
	message = message:gsub("^%l", string.upper)
	local stringLength = string.len(message)
	local punctuated = string.find(message, ".", stringLength, stringLength)

	if string.find(message, ",", stringLength, stringLength) == nil and string.find(message, ".", stringLength, stringLength) == nil and string.find(message, "!", stringLength, stringLength) == nil and string.find(message, "?", stringLength, stringLength) == nil then
		message = message .. "."
	end

	return message
end

function rpchat.formatP(message)
	local punctuated = string.find(message, ".", stringLength, stringLength)
	if punctuated == nil then
		message = message .. "."
	end
	return message
end

function rpchat.correctName(playerName)
	playerName = playerName:gsub("^%l", string.upper)
	rpchat.log("Name " .. playerName .. " corrected.", "debug")
	return playerName
end

function rpchat.verifyColor(colorString)
	if string.len(colorString) == 6 then
		if tonumber(colorString, 16) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function rpchat.setColor(pid, newColor, originPID)
	if rpchat.verifyColor(newColor) then
		local name = Players[pid].name
		newColor = "#" .. newColor

		Players[pid].data.customVariables.rpchat.color = newColor
		rpchat.log("COLOR FOR " .. name .. " CHANGED TO " .. newColor, "debug")
	else
		rpchat.systemMessage(originPID, "Invalid color, please use hex color codes.")
	end
end

function rpchat.getColor(pid)
	return Players[pid].data.customVariables.rpchat.color
end

function rpchat.setName(pid, newName, originPID)
	local name = Players[pid].name
	local targetUserData

	Players[pid].data.customVariables.rpchat.name = newName

	rpchat.systemMessage(originPID, "RP name for PID " .. pid .. " changed to " .. newName)
end

function rpchat.getName(pid, rp)
	rp = rp or true

	if rp == true then
		if Players[pid].data.customVariables.rpchat.nick ~= nil then
			return rpconfig.colors.nickname .. Players[pid].data.customVariables.rpchat.nick
		else
			return Players[pid].data.customVariables.rpchat.name
		end

	else
		return Players[pid].data.customVariables.rpchat.name
	end
end

messageHandlers["local"] = function(pid, message, pColor)
	message = pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessageDist(pid, message, rpconfig.talkDist)
end

messageHandlers["ooc"] = function(pid, message, pColor)
	message = rpconfig.colors.ooc  .. "[OOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
	tes3mp.SendMessage(pid, message, true)
end

messageHandlers["looc"] = function(pid, message, pColor)
	message = rpconfig.colors.looc .. "[LOOC] " .. pColor .. Players[pid].name .. color.White .. ": " .. rpchat.format(message) .. "\n"
	rpchat.localMessage(pid, message)
end

messageHandlers["emote"] = function(pid, message, pColor)
	message = rpconfig.colors.emote .. "[ACTION] " .. pColor .. rpchat.getName(pid) .. color.White .. " " .. rpchat.formatP(message) .. "\n"
	rpchat.localMessageDist(pid, message, rpconfig.talkDist)
end

messageHandlers["whisper"] = function(pid, message, pColor)
	message = rpconfig.colors.whisper .. "[WHISPER] " .. pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessageDist(pid, message, rpconfig.whisperDist)
end

messageHandlers["shout"] = function(pid, message, pColor)
	message = rpconfig.colors.shout .. "[SHOUT] " .. pColor .. rpchat.getName(pid) .. color.White .. ": \"" .. rpchat.format(message) .. "\"\n"
	rpchat.localMessage(pid, message, rpconfig.shoutDist)
end

function rpchat.messageHandler(pid, message, messageType)
	local pColor = rpchat.getColor(pid)
	if pColor == nil then pColor = color.White end
	if not messageType then messageType = "local" end

	rpchat.log("PLAYER COLOR IS " .. pColor, "debug")
	rpchat.log(Players[pid].name.."("..rpchat.getName(pid).."): "..message.." - "..messageType)
	messageHandlers[messageType](pid, message, pColor)
end

function rpchat.localMessage(pid, message)
	for index, value in pairs(Players) do
		if tes3mp.GetCell(index) == tes3mp.GetCell(pid) then
			tes3mp.SendMessage(index, message, false)
		end
	end
end

function rpchat.localMessageDist(pid, message, dist)
	originX = tes3mp.GetPosX(pid)
	originY = tes3mp.GetPosY(pid)

	rpchat.log("PLAYER POSITION IS " .. originX .. " " .. originY, "debug")

	for ply,val in pairs(Players) do
		if tes3mp.GetCell(ply) == tes3mp.GetCell(pid) then
			local plyX = tes3mp.GetPosX(ply)
			local plyY = tes3mp.GetPosY(ply)

			local plydist = math.sqrt(math.pow(plyX - originX, 2) + math.pow(plyY - originY, 2))

			if plydist <= dist then
				tes3mp.SendMessage(ply, message, false)
			end
		end
	end
end

function rpchat.log(message, logType)
	if logType == nil or logType == "normal" then
		message = "[RP-CHAT]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[RP-CHAT]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[RP-CHAT]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[RP-CHAT]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" and rpconfig.debug then
		message = "[RP-CHAT]DBG: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)

	else
		rpchat.log("INVALID LOG CALL", "error")
		message = "[RP-CHAT](invalid): " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

function rpchat.systemMessage(pid, message, all)
	local all = all or false
	local message = color.Cyan .. "[RP-CHAT]: " .. color.White .. message .. "\n"

	tes3mp.SendMessage(pid, message, all)
end

function rpchat.commandHandler(pid, cmd)
	if cmd[2] ~= nil then
		if cmd[2] == "name" then
			local newName = ""
			if cmd[3] ~= nil then
				for index, value in pairs(cmd) do
					if index > 2 and index <= 3 then
						newName = newName .. value:gsub("^%l", string.upper)
					elseif index > 3 then
						newName = newName .. " " .. value:gsub("^%l", string.upper)
					end
				end

				if newName:len() <= rpconfig.nameMaxLen then
					rpchat.setName(pid, newName, pid)
				else
					rpchat.systemMessage(pid, "The max len allowed for a RP name is " .. rpconfig.nameMaxLen)
				end
			else
				rpchat.systemMessage(pid, "Invalid name.")
			end

		elseif cmd[2] == "color" and Players[pid].data.settings.staffRank > 0 then
			if cmd[3] ~= nil and logicHandler.CheckPlayerValidity(pid, cmd[3]) then
				if cmd[4] ~= nil then
					local newColor = cmd[4]
					rpchat.setColor(tonumber(cmd[3]), newColor, pid)
				else
					rpchat.systemMessage(pid, "Invalid color.")
				end
			else
				rpchat.systemMessage(pid, "Invalid PID.")
			end

		elseif cmd[2] == "toggleooc" and Players[pid].data.settings.staffRank > 0 then
			if cmd[3] == "false" then
				config.toggleOOC = false
				rpchat.systemMessage(pid, "OOC has been turned off by staff.", true)
			elseif cmd[3] == "true" then
				config.toggleOOC = true
				rpchat.systemMessage(pid, "OOC has been turned on by staff.", true)
			else
				rpchat.systemMessage(pid, "Argument has to be true/false. (OOC is set to "..config.toggleOOC..")")
			end

		else
			rpchat.systemMessage(pid, "Invalid command.")
		end

	else
		rpchat.systemMessage(pid, "Invalid command.")
	end
end

function rpchat.nickname(pid, cmd)
	local nick = ""

	if rpconfig.enableNicks then
		if cmd[2] ~= nil then
			for index, value in pairs(cmd) do
				if index > 1 and index <= 2 then
					nick = nick .. value
				elseif index > 2 then
					nick = nick .. " " .. value
				end
			end

			if nick:len() >= rpconfig.nickMinLen and nick:len() <= rpconfig.nickMaxLen then
				Players[pid].data.customVariables.rpchat.nick = nick
				rpchat.systemMessage(pid, "Your nickname as been set to: " .. nick)
			else
				rpchat.systemMessage(pid, "That nickname is incorrect. The max length allowed is " .. rpconfig.nickMaxLen)
			end
		else
			Players[pid].data.customVariables.rpchat.nick = nil
			rpchat.systemMessage(pid, "Your nickname as been reset.")
		end

	else
		rpchat.systemMessage(pid, "Nicknames are disabled.")
	end
end

function rpchat.ooc(pid, cmd)
	if not config.toggleOOC and Players[pid].data.settings.staffRank > 0 then
		rpchat.systemMessage(pid, "OOC has been disabled by staff.")
		return
	end

	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "ooc")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.looc(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "looc")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.emote(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "emote")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.shout(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "shout")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.whisper(pid, cmd)
	local message = ""

	if cmd[2] ~= nil then
		for index, value in pairs(cmd) do
			if index > 1 and index <= 2 then
				message = message .. tostring(value)
			elseif index > 2 then
				message = message .. " " .. tostring(value)
			end
		end
		rpchat.messageHandler(pid, message, "whisper")
	else
		rpchat.systemMessage(pid, "That's not a valid message.")
	end
end

function rpchat.loginHandler(eventStatus, pid)
	rpchat.initPlayer(pid)
end

customEventHooks.registerHandler("OnPlayerFinishLogin", rpchat.loginHandler)
customEventHooks.registerHandler("OnPlayerEndCharGen", rpchat.loginHandler)

customEventHooks.registerHandler("OnServerPostInit", function()
	rpchat.log("RP-CHAT has been loaded successfully.")
end)

customEventHooks.registerValidator("OnPlayerSendMessage", function(event, pid, message)
	if message:sub(1,1) ~= "/" then
		rpchat.messageHandler(pid, message)
		return customEventHooks.makeEventStatus(false, nil)
	end
end)

customCommandHooks.registerCommand("rpchat", rpchat.commandHandler)
customCommandHooks.registerCommand("nick", rpchat.nickname)
customCommandHooks.registerCommand("ooc", rpchat.ooc)
customCommandHooks.registerCommand("/", rpchat.ooc)
customCommandHooks.registerCommand("looc", rpchat.looc)
customCommandHooks.registerCommand("//", rpchat.looc)
customCommandHooks.registerCommand("me", rpchat.emote)
customCommandHooks.registerCommand("s", rpchat.shout)
customCommandHooks.registerCommand("yell", rpchat.shout)
customCommandHooks.registerCommand("w", rpchat.whisper)

return rpchat
