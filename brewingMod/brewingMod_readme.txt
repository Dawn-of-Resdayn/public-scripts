--ReinhartXIV's Custom Potions V0.04--

Changelog:

V0.04
- Brewing now requires empty bottles
- Added Skooma as a recipe, requires 4 ingredients and a relatively high skill level.

V0.03
- Leveling alchemy increases level progression and attribute multiplier properly.
- Fixed fatigue potions

V0.02 
- Fixed a bug with some ingredients not getting removed properly when brewing a potion.
- Loosened the skill requirement of some negative effect potions
V0.01
- Initial Release

Installation:

- Either use the edited files provided in the archive or do as instructed below. 

- Open guiIds.lua and replace

GUI.ID = enum {
"LOGIN",
"REGISTER",
"PLAYERSLIST",
"CELLSLIST"
}

With

GUI.ID = enum {
"LOGIN",
"REGISTER",
"PLAYERSLIST",
"CELLSLIST",
"POTIONSLIST",
"INGREDIENTSLIST"
}

GUI.ShowPotionList = function(pid,potionData)
	tes3mp.CustomMessageBox(pid, GUI.ID.POTIONSLIST, "Choose a potion to brew:",potionData)
end

GUI.ShowIngredientList = function(pid,ingredientData)
	tes3mp.CustomMessageBox(pid, GUI.ID.INGREDIENTSLIST, brewingMod.label,ingredientData)
end

- Open myMod.lua and add

elseif idGui == GUI.ID.POTIONSLIST then
	brewingMod.PickBrewable(pid,data)
elseif idGui == GUI.ID.INGREDIENTSLIST then
	brewingMod.PickIngredient(pid,data)

after 

Players[pid]:Message("You have successfully registered.\nUse Y by default to chat or change it from your client config.\n")

- Open server.lua and add  

elseif cmd[1] == "brew" then
	brewingMod.CheckIngredients(pid)
	
after 

if cmd[1] == "players" or cmd[1] == "list" then
	GUI.ShowPlayerList(pid)

also add require("brewingMod") after require("time")

Usage:
- Type /brew in chat

Todo:
- Easy configuration options
- Fix UI clutter when there are many potions to craft
