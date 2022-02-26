mob/layer = MY_MOB_LAYER
turf/layer = MY_TURF_LAYER
obj/layer = MY_OBJ_LAYER




world
	hub = "GauHelldragon.ArchipelagoRemastered"
	status = "Archipelago - Schoolboy215"
	visibility = 1

	map_format = TILED_ICON_MAP

	view = 5
	loop_checks = 0

	New()
		loading = 0
		WorldLoad()
		initBIlist()
		InititlizeOreList()
		InitilizeMetalCrafts()
		island = isItemTypeInList(/area/island,world.contents)

		loadTurfs()

		spawn(0)
			TimeLoop()
		spawn(0)
			HourLoop()
		spawn(0)
			MinuteLoop()
		..()

		spawn(10)
			loading = 2
		currentdate = time2text(realtime,"DD.MM.YY")

proc
	Type2Name(type)
		var pos = length("[type]")+1
		var char = copytext("[type]",pos-1,pos)
		//world << "Pos = [pos], char = [char]"
		for ( , char != "/" && pos > 2, pos-- )


			char = copytext("[type]",pos-1,pos)
			//world << "Pos = [pos], char = [char]"

		if ( pos <= 2 )
			return "[type]"
		else
			return copytext("[type]",pos+1)


	isItemTypeInList(type,list)
		for ( var/thing in list )
			if ( istype(thing,type) )
				return thing
		return 0


world
	mob = /mob/starter
	area = /area/island
//	turf = /turf/Water


mob/player/verb
	say(message as text)
		if (client.NoSay == 1)
			src << "<font color=red><font size=4>You're muted"
			return
		Public_message("<font color=blue>[src] says : </font>[html_encode(message)]")
		addlog(message,"say")
		usr.lastaction = "said : [message]"

	ooc(message as text)
		if (client.NoOOC == 1)
			src << "<font color=red><font size=4>You've lost that privelage"
			return
		for ( var/mob/player/PC in world.contents )
			if (src.admintype > 0)
				switch(src.admintype)
					if (1)
						PC << "(OOC)<font color=red>[src]<font color = blue><b>{R}</b><font color = black> says: </font>[html_encode(message)]"
					if (2)
						PC << "(OOC)<font color=red>[src]<font color = blue><b>{M}</b><font color = black> says: </font>[html_encode(message)]"
					if (3)
						PC << "(OOC)<font color=red>[src]<font color = blue><b>{A}</b><font color = black> says: </font>[html_encode(message)]"
					if (4)
						PC << "(OOC)<font color=red>[src]<font color = blue><b>{A}</b><font color = black> says: </font>[html_encode(message)]"
					if (5)
						PC << "(OOC)<font color=red>[src]<font color = blue><b>{C}</b><font color = black> says: </font>[html_encode(message)]"
			else
				PC << "(OOC)<font color=red>[src]<font color = black> says: </font>[html_encode(message)]"
		addlog(message,"OOC")
		usr.lastaction = "announced : [message]"

	adminhelp(message as message)
		if (client.NoAdminHelp == 1)
			src << "<font color=red><font size=4>You shouldn't have bothered us"
			return
		var/on = 0
		for ( var/mob/player/PC in world.contents )
			if (PC.admintype > 0)
				on ++
				PC << "<b><font color = blue><i>admin help from '[src]':"
				PC << "<font color = blue><i>[message]"
		if (on == 0)
			usr << "<font color = red>There are currently no admins online to receive your help request."
			usr << "<font color = red>If the problem is with another player, you can report them on the forums."
		else
			usr << "<font color = green>Your report has been received by <b>[on]</b> administrator(s)!"

		addlog("[message]","adminhelp")
		usr.lastaction = "admin-helped : [message]"

	who()
		usr << "People playing right now:"

		var tribeMessage
		usr.lastaction = "checked who was playing"
		for ( var/mob/player/PC in world.contents )
			if (PC.tribe <> null)
				if (PC:tribe:leader <> PC.key)
					tribeMessage = "<font color = red>: tribe <b>[PC:tribe:name]"
				else
					tribeMessage = "<font color = red>: leader of <b>[PC:tribe:name]"
			//if ( PC.tribeName )
				//tribeMessage = "<font color = red>Tribe : [PC.tribeName] "
			else
				tribeMessage = ""
			src << "  <B><font color=blue>[PC]</b> [tribeMessage]"

	list_admins()
		usr << "Admins playing right now:"
		usr << "_________________________"
		usr.lastaction = "checked admins"
		var/suf
		for ( var/mob/player/PC in world.contents )
			if (PC.admintype > 0)
				switch(PC.admintype)
					if (5)
						suf = "<i>Creator"
					if (4)
						suf = "<i>Head Admin"
					if (3)
						suf = "<i>Administrator"
					if (2)
						suf = "<i>Moderator"
					if (1)
						suf = "<i>Rule Enforcer"


				src << "  <B><font color=blue>[PC] : <font color = green>[suf]"
		usr << "_________________________"

	Announce_IQ()
		if (client.NoOOC == 1)
			src << "<font color=red><font size=4>You wish you could tell people that!"
			return
		usr.lastaction = "announced their IQ"
		AnnounceRank()


world/proc/WorldSave()
	world << "<B><font color = green>Saving world..."

	fdel("saves/stuff.sav")
	fdel("saves/plants.sav")
	fdel("saves/buildings.sav")
	fdel("saves/misc.sav")
	//fdel("/world.sav")

	var savefile/stuffsave = new("saves/stuff.sav")
	var savefile/plantsave = new("saves/plants.sav")
	var savefile/buildingsave = new("saves/buildings.sav")
	var savefile/miscsave = new("saves/misc.sav")
	//var savefile/worldsave = new("world.sav")

	//worldsave["/Recents"] << recentsales
	//worldsave["/Tribes"] << TribesList
	miscsave["/Recents"] << recentsales
	miscsave["/Tribes"] << NewTribesList


	var list/saveList = new()

	//for ( var/obj/thing in contents )
		//if ( ShouldSave(thing) )
			//saveList += thing
	for ( var/obj/thing in contents )
		if (istype(thing,/obj/item))
			saveList += thing
		if (istype(thing,/obj/Fire))
			saveList += thing
		if (istype(thing,/obj/Compost))
			saveList += thing
	stuffsave["/Things"] << saveList

	saveList = new()

	for ( var/obj/thing in contents )
		if (!( isItemTypeInList(/obj/NoBuildZone,thing.loc) ))
			if (istype(thing,/obj/building))
				saveList += thing
			if (istype(thing,/obj/store))
				saveList += thing
			if (istype(thing,/obj/Post_Office))
				saveList += thing
	buildingsave["/Things"] << saveList

	saveList = new()

	for ( var/obj/thing in contents )
		if (istype(thing,/obj/plant))
			saveList += thing
		if (istype(thing,/obj/Plowed_Land))
			saveList += thing

	for ( var/mob/animal/thing in contents )
		thing:lastpos = thing:loc
		saveList += thing
	plantsave["/Things"] << saveList

	//worldsave["/Things"] << saveList
			//worldsave["/Things/"] << thing

	world << "<B><font color = green>World save complete."

world/Del()
	savelog()
	WorldSave()
	return ..()

var/list/recentsales = new()
world/proc/WorldLoad()
	world.log << "Starting world load..."


	if ( !hasfile("saves/misc.sav") )
		world.log << "No world save file."
		return
	//if ( !hasfile("world.sav") )
		//world.log << "No world save file."
		//return

	var savefile/stuffsave = new("saves/stuff.sav")
	var savefile/plantsave = new("saves/plants.sav")
	var savefile/buildingsave = new("saves/buildings.sav")
	var savefile/miscsave = new("saves/misc.sav")
	//var savefile/worldsave = new("world.sav")

	miscsave["/Recents"] >> recentsales
	miscsave["/Tribes"] >> NewTribesList
	//worldsave["/Recents"] >> recentsales
	//worldsave["/Tribes"] >> TribesList


	//var list/thingList
	var list/stuffList
	var list/plantList
	var list/buildingList
	//while ( !worldsave.eof )
	buildingsave["/Things/"] >> buildingList
	stuffsave["/Things/"] >> stuffList
	plantsave["/Things/"] >> plantList

	//worldsave["/Things/"] >> thingList



	world.log << "World load complete."
	for(var/mob/animal/A in world)
		A.loc = A:lastpos


world/proc/ShouldSave(obj/thing)
	if ( ismob(thing.loc) )
		return 0


	if ( istype(thing,/obj/Fire) )
		return 1
	if ( istype(thing,/obj/Compost) )
		return 1
	if ( istype(thing,/obj/Plowed_Land) )
		return 1
	if ( istype(thing,/obj/building) )
		return 1
	if ( istype(thing,/obj/Post_Office) )
		return 1
	if ( istype(thing,/obj/store) )
		return 1
	if ( istype(thing,/obj/item) )
		return 1
	if ( istype(thing,/obj/plant) )
		return 1


	return 0

obj
	Write(savefile/SF)


		var temppointer = mouse_drag_pointer
		if ( istype(src,/obj/item) )
			mouse_drag_pointer = 0

		var ret = ..(SF)
		SF["x"] << x
		SF["y"] << y
		SF["z"] << z
		if ( istype(src,/obj/item) )
			mouse_drag_pointer = temppointer


		return ret


	Read(savefile/SF)
		var
			tempx
			tempy
			tempz

		SF["x"] >> tempx
		SF["y"] >> tempy
		SF["z"] >> tempz

		var ret = ..(SF)

		loc = locate(tempx,tempy,tempz)
		if ( istype(src,/obj/item) )

			if (!mouse_drag_pointer )

				src:LoadPointer()

		return ret


