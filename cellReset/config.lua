local config = {}

config.resetTime = 259200 --The time in (real life) seconds that must've passed before a cell is attempted to be reset. 259200 seconds is 3 days. Set to -1 to disable automatic resetting
config.preserveCellChanges = true --If true, the script won't reset actors that have moved into/from the cell. At the moment, MUST be true.
config.alwaysPreservePlaced = false --If true, the script will always preserve any placed objects, even in cells that it's free to delete from

--Cells entered in the blacklist are exempt from cell resets.
config.blacklist = {
  --"Pelagiad, Ahnassi's House",
}
--Object with the UniqueIndexes entered in this list will be preserved as they were from a cell reset.
config.preserveUniqueIndexes = {
  --"0-1234",
}

config.checkResetTimeRank = 0 -- The staffRank required to use the /resetTime command.
config.forceResetRank = 2 -- The staffRank required to use the /forceReset command.

config.kickAffectedPlayersAfterForceReset = true -- If true, players that had information on a cell in their client memory will be kicked following a force reset. Should be set to true or problems will arise!

config.logging = true --If true, script outputs basic information to the log
config.debug = false --If true, script outputs debug information to the log

return config
