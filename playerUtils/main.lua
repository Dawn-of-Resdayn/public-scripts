--Created by Wishbone https://github.com/SaintWish for Dawn of Resdayn RP
--Github Repo: https://github.com/Dawn-of-Resdayn/public-scripts
--Under GPLv2 license https://github.com/Dawn-of-Resdayn/public-scripts/blob/master/LICENSE
local config = require("custom/playerUtils/config")

local playerUtils = {}

function playerUtils.log(logType, message, ...)
	local message = string.format(message, ...)

	if logType == nil or logType == "normal" then
		message = "[PLAYER-UTILS]: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "error" then
		message = "[PLAYER-UTILS]ERR: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "warning" then
		message = "[PLAYER-UTILS]WARN: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "notice" then
		message = "[PLAYER-UTILS]NOTE: " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	elseif logType == "debug" then
		if config.debug then
			message = "[PLAYER-UTILS]DBG: " .. message
			tes3mp.LogMessage(enumerations.log.INFO, message)
		end

	else
		playerUtils.log("INVALID LOG CALL", "error")
		message = "[PLAYER-UTILS](invalid): " .. message
		tes3mp.LogMessage(enumerations.log.INFO, message)
	end
end

function playerUtils.systemMessage(pid, prefix, message, ...)
  local msg = string.format(message, ...)
	local fMsg = config.prefixColor .. prefix .. ": " .. config.msgColor .. msg .. "\n"
	playerUtils.log("debug", "MESSAGE FORMATTED %s", msg)

	tes3mp.SendMessage(pid, fMsg, false)
end

function playerUtils.stuckCmd(pid, args)
  local cooldown = Players[pid].data.customVariables.plyUtils.stuck

  if cooldown == 0 or cooldown < os.time() then
    playerUtils.log("debug", "Player %s used /stuck", Players[pid].name)

    Players[pid].data.customVariables.plyUtils.stuck = os.time() + config.stuckCooldown
    Players[pid]:LoadCell()
  	Players[pid]:Save()

    playerUtils.systemMessage(pid, "[STUCK]", "You have been unstuck.")
  else
    local timeLeft = cooldown - os.time()
    playerUtils.log("debug", "Player %s could not use /stuck, %i seconds left", Players[pid].name, timeLeft)
    playerUtils.systemMessage(pid, "[STUCK]", "You can unstuck again in %i seconds.", timeLeft)
  end
end

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
  for _,v in pairs(config.startItems) do
    local itemStruct = {refId = v[1], count = v[2], charge = v[3]}
    table.insert(Players[pid].data.inventory, itemStruct)
  end

  Players[pid]:LoadInventory()
  Players[pid]:LoadEquipment()
end)

customEventHooks.registerHandler("OnPlayerFinishLogin", function(eventStatus, pid)
  if not Players[pid].data.customVariables.plyUtils then
    Players[pid].data.customVariables.plyUtils = {
      ["stuck"] = 0,
    }
  end
end)

customEventHooks.registerHandler("OnServerPostInit", function()
	playerUtils.log("normal", "PLAYER-UTILS has been loaded (through scriptHook)")
end)

customCommandHooks.registerCommand("stuck", playerUtils.stuckCmd)

return playerUtils
