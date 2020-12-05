--Made by Kyoufu, edited by Vidi_Aquam, based on JRPAnim by malic

local AnimationMenu = {}
local guiID = {}
guiID.animMenu = 42110

function AnimationMenu.showAnimMenu(eventStatus,pid)
	local message = color.Yellow.. "Animation Menu"

	optionList = "Lay Down (On Back);Lay Down (On Right Side);Sit on Ground (Legs to the Side);Sit on Ground (Legs Crossed);Pray;Lay Down (On Left Side);Sit on Ground (Legs Forward);Sit on Chair"

	tes3mp.CustomMessageBox(pid, guiID.animMenu, message, optionList .. ";Cancel (Stand Up)")
end

local function OnServerPostInitHandler()
    local recordStore = RecordStores["spell"] -- we need this spell to stop players from moving which breaks their anim
    recordStore.data.permanentRecords["sittingAnim_paralyze"] = {
        name = "Sitting Paralyze (/anim)",
        subtype = 1,
		cost = 0,
		flags = 0,
		effects = {{
			id = 45,
			attribute = -1,
			skill = -1,
			rangeType = 0,
			duration = -1,
			area = 0,
			magnitudeMin = 1,
			magnitudeMax = 1
		}}
	}
	recordStore:Save()
end

function AnimationMenu.checkGUI(newStatus,pid,idGui,data)
	if idGui == guiID.animMenu then
		if tonumber(data) == 0 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle9", 0, -1, false)
		elseif tonumber(data) == 1 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle7", 0, -1, false)
		elseif tonumber(data) == 2 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle3", 0, -1, false)
		elseif tonumber(data) == 3 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle4", 0, -1, false)
		elseif tonumber(data) == 4 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle2", 0, -1, false)
		elseif tonumber(data) == 5 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle8", 0, -1, false)
		elseif tonumber(data) == 6 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle5", 0, -1, false)
		elseif tonumber(data) == 7 then
			table.insert(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle6", 0, -1, false)
		elseif tonumber(data) == 8 then
			logicHandler.RunConsoleCommandOnPlayer(pid, "player->removespell sittingAnim_paralyze")
			tableHelper.removeValue(Players[pid].data.spellbook, "sittingAnim_paralyze")
			Players[pid]:LoadSpellbook()
			tes3mp.PlayAnimation(pid, "idle", 0, -1, false)
		end
	else
	end
end

function AnimationMenu.ChatListener(pid, cmd)

	if cmd[1] == "sit" and cmd[2] == nil then
		AnimationMenu.showAnimMenu(eventStatus,pid)
	end
end

customEventHooks.registerHandler("OnServerPostInit", OnServerPostInitHandler)
customEventHooks.registerValidator("OnGUIAction", AnimationMenu.checkGUI)
customCommandHooks.registerCommand("sit", AnimationMenu.ChatListener)
