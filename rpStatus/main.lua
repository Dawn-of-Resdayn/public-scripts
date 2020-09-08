--Created by Wishbone https://github.com/SaintWish for Dawn of Resdayn RP
--Github Repo: https://github.com/Dawn-of-Resdayn/public-scripts
--Under GPLv2 license https://github.com/Dawn-of-Resdayn/public-scripts/blob/master/LICENSE

--Based on jrpStatus by malic
local rpStatus = {}
local debug = true
local guiIDs = {
  ["playerCard"] = 31501,
  ["bioInput"] = 31502
}

function rpStatus.log(logType, message, ...)
  local message = string.format(message, ...)

  if logType == nil or logType == "normal" then
    message = "[RP-STATUS]: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "error" then
    message = "[RP-STATUS]ERR: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "warning" then
    message = "[RP-STATUS]WARN: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "notice" then
    message = "[RP-STATUS]NOTE: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "debug" then
    if debug then
      message = "[RP-STATUS]DBG: " .. message
      tes3mp.LogMessage(enumerations.log.INFO, message)
    end

  else
    rpStatus.log("INVALID LOG CALL", "error")
    message = "[RP-STATUS](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

function rpStatus.systemMessage(pid, message, ...)
  local msg = string.format(message, ...)
	local fMsg = color.Orange .. "[RP-STATUS]: " .. color.White .. msg .. "\n"
	rpStatus.log("debug", "MESSAGE FORMATTED %s", msg)

	tes3mp.SendMessage(pid, fMsg, false)
end

function rpStatus.openPlayerCard(pid, target)
  local targetName = Players[target].data.customVariables.rpchat.name or Players[target].name
  if Players[target].data.customVariables.rpchat.nick then
    local nick = Players[target].data.customVariables.rpchat.nick

    local split = targetName:split(" ")
    if #split > 1 then
      targetName = split[1] .. " '" .. nick .. "' " .. split[2]
    else
      targetName = Players[target].data.customVariables.rpchat.name .. " '"  .. nick .. "'"
    end
  end

  local message = color.Yellow .. targetName .. "\n\n" ..
	color.Orange .. "Age: " .. color.Default ..  Players[target].data.customVariables.rpStatus.age .. "\n" ..
	color.Orange .. "Height: " .. color.Default .. Players[target].data.customVariables.rpStatus.height .. "\n" ..
	color.Orange .. "Gender: " .. color.Default .. Players[target].data.customVariables.rpStatus.gender .. "\n" ..
	color.Orange .. "Sexuality: " .. color.Default .. Players[target].data.customVariables.rpStatus.sexuality ..  "\n\n" ..
	color.Orange .. "Appearance: " .. color.Default .. Players[target].data.customVariables.rpStatus.appearance .. "\n\n" ..
	color.Orange .. "Biography: " .. color.Default .. Players[target].data.customVariables.rpStatus.biography

  tes3mp.CustomMessageBox(pid, guiIDs.playerCard, message, "Cancel")
end

function rpStatus.setInfo(pid, type, data)
  if Players[pid].data.customVariables.rpStatus[type] == nil then
    return false
  end

  if type == "biography" then
    Players[pid].data.customVariables.rpStatus.biography = data
  else
    Players[pid].data.customVariables.rpStatus[type] = table.concat(data, " ", 3)
  end

  Players[pid]:Save()
  return true
end

function rpStatus.openInputGUI(pid, type)
  if type == "biography" then
    tes3mp.InputDialog(pid, guiIDs.bioInput, "Enter your biography:", "")
  end
end

customEventHooks.registerHandler("OnServerPostInit", function()
	rpStatus.log("normal", "rpStatus loaded (through scriptHook)")
end)

customEventHooks.registerHandler("OnObjectActivate", function(eventStatus, pid, cellDesc)
  for i=0, tes3mp.GetObjectListSize()-1 do
    if tes3mp.IsObjectPlayer(i) and tes3mp.DoesObjectHavePlayerActivating(i) then
      local targetPid = tes3mp.GetObjectPid(i)
      rpStatus.openPlayerCard(pid, targetPid)
      rpStatus.log("debug", "%s activated player %s", Players[pid].name, Players[targetPid].name)
    end
  end
end)

customEventHooks.registerHandler("OnGUIAction", function(eventStatus, pid, guiID, data)
  if data == nil then
    data = "Unknown"
  end

  if guiID == guiIDs.bioInput then
    rpStatus.setInfo(pid, "biography", data)
  end
end)

customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
  if Players[pid].data.customVariables.rpStatus == nil then
    Players[pid].data.customVariables.rpStatus = {
      ["age"] = "Unknown",
      ["height"] = "Unknown",
      ["gender"] = "Unknown",
      ["sexuality"] = "Unknown",
      ["appearance"] = "Unknown",
      ["biography"] = "Unknown"
    }
  end

  if Players[pid].data.customVariables.jrpStatus ~= nil then
    rpStatus.log("debug", "jrpStatus field found, converting to rpStatus")
    Players[pid].data.customVariables.rpStatus = Players[pid].data.customVariables.jrpStatus
    Players[pid].data.customVariables.jrpStatus = nil --Remove jrpStatus field once it's been converted over
  end
end)

customCommandHooks.registerCommand("status", function(pid, args)
  if #args > 1 then
    if args[2] ~= "biography" then
      if rpStatus.setInfo(pid, args[2], args) == false then
        rpStatus.systemMessage(pid, "Failed to set %s info. Incorrect type?", args[2])
      end
    else
      rpStatus.openInputGUI(pid, "biography")
    end
  else
    rpStatus.openPlayerCard(pid, pid)
  end
end)

return rpStatus
