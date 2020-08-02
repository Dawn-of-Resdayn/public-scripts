local rpconfig = {}

rpconfig.debug = true
rpconfig.dataType = "json"

rpconfig.toggleOOC = false

rpconfig.enableNicks = true
rpconfig.nickMinLen = 3
rpconfig.nickMaxLen = 20
rpconfig.nameMaxLen = 20

rpconfig.talkDist = 750
rpconfig.whisperDist = 250
rpconfig.shoutDist = 2000

rpconfig.colors = {
	ooc = color.GreenText,
	looc = color.LimeGreen,
	emote = color.Teal,
	shout = color.Orange,
	whisper = color.Grey,
	nickname = color.Grey
}

return rpconfig
