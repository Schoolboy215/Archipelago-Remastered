var/said
var/currentdate
var/list/pendinglog
admin/verb
	Download_Log()
		set category = "Admin"
		addlog("downloaded log","admin")
		savelog()
		usr << ftp(said,"chat_log [time2text(world.realtime,"MM.DD.YY")].txt")

admin/verb
	Punishment_Log()
		set category = "Admin"
		var/savefile/S = new("logs/punishments.sav")
		var/mob/M
		S >> M
		for (var/k in M.contents)
			usr << k

proc/addlog(var/what,var/kind,var/extra = "")
	//var/gar = world.realtime
	var/add = "\[[time2text(world.realtime,"DD.MM.YY")] [time2text(world.timeofday,"hh:mm:ss")]\]"
	switch(kind)
		if ("say")
			add += " [usr.key] - [usr.key] says: [what]"
		if ("OOC")
			add += " [usr.key] - [usr.key] OOC: [what]"
		if ("adminhelp")
			add += " [usr.key] - [usr.key] adminhelp: [what]"
		if ("admin")
			add += " [usr.key] - [usr.key] admin: [what]"
		if ("get")
			add += " [usr.key] - [usr.key] got: [what]"
		if ("drop")
			add += " [usr.key] - [usr.key] dropped: [what]"
		if ("login")
			add += " [usr.key] - [usr.key] login:"
		if ("logout")
			add += " [usr.key] - [usr.key] logout:"
		if ("attack")
			add += " [usr.key] - [usr.key] attacks [extra] - [extra]!"

	pendinglog += add

proc/savelog()
	said = file("logs/[currentdate].txt")
	for(var/k in pendinglog)
		said << k
	pendinglog = new()
	if (time2text(world.realtime,"DD.MM.YY") != currentdate)
		currentdate = time2text(world.realtime,"DD.MM.YY")