--Created by Wishbone https://github.com/SaintWish for Dawn of Resdayn RP
--based on David's AW disableAssassins for 0.6.0
--Feel free to use this for whatever.
local config = require("custom/objectBlacklist/config")

local objectBlacklist = {}

function objectBlacklist.log(message, logType)
  if logType == nil or logType == "normal" then
    message = "[OBJECT-BLACKLIST]: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "error" then
    message = "[OBJECT-BLACKLIST]ERR: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "warning" then
    message = "[OBJECT-BLACKLIST]WARN: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "notice" then
    message = "[OBJECT-BLACKLIST]NOTE: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  elseif logType == "debug" and config.debug then
    message = "[OBJECT-BLACKLIST]DBG: " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)

  else
    objectBlacklist.log("INVALID LOG CALL", "error")
    message = "[OBJECT-BLACKLIST](invalid): " .. message
    tes3mp.LogMessage(enumerations.log.INFO, message)
  end
end

function objectBlacklist.checkItem(itemRef)
  objectBlacklist.log("Checking object blacklist for "..itemRef, "debug")

  for k,v in pairs(config.blacklist) do
    if string.match(v, itemRef) then
      return true
    end
  end

  return false
end

function objectBlacklist.deleteObject(pid, obj, cellDesc)
  objectBlacklist.log("Deleting object "..obj.." for player "..pid.." in cell "..cellDesc, "debug")

  for ply,v in pairs(Players) do
    if tes3mp.GetCell(ply) == tes3mp.GetCell(pid) then
      tes3mp.InitializeEvent(ply)
      tes3mp.SetEventCell(cellDesc)
      tes3mp.SetObjectRefNumIndex(0)
      tes3mp.SetObjectMpNum(obj)
      tes3mp.AddWorldObject() -- Add actor to packet
      tes3mp.SendObjectDelete() -- Send Delete
    end
  end

  if LoadedCells[cellDesc] ~= nil then
    local index = "0-"..obj
      LoadedCells[cellDesc].data.objectData[index] = nil
      tableHelper.removeValue(LoadedCells[cellDesc].data.packets.spawn, index)
      tableHelper.removeValue(LoadedCells[cellDesc].data.packets.actorList, index)
      LoadedCells[cellDesc]:Save()
  end
end

function objectBlacklist.ObjectSpawn(eventStatus, pid, cellDesc)
  objectBlacklist.log("Object spawned for player "..pid, "debug")
  tes3mp.ReadLastEvent()

  local delete = {}

  local i
  for i=0, tes3mp.GetObjectChangesSize() - 1 do
    local refID = tes3mp.GetObjectRefId(i)
    if objectBlacklist.checkItem(refID) then
      table.insert(delete, tes3mp.GetObjectMpNum(i))
    end
  end

  if #delete > 0 then
    for _,v in pairs(delete) do
      objectBlacklist.deleteObject(pid, v, cellDesc)
    end
  end
end

customEventHooks.registerHandler("OnServerPostInit", function()
  objectBlacklist.log("objectBlacklist loaded (through scriptHook)")
end)
customEventHooks.registerHandler("OnObjectSpawn", objectBlacklist.ObjectSpawn)

return objectBlacklist
