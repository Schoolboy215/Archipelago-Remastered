obj/NoBuildZone
	icon = 'misc.dmi'
	icon_state = "red"
	New()
		icon = null

obj/RandomSpawnPoint/
	icon = 'misc.dmi'
	icon_state = "spawn"
	New()
		icon = null

obj/TitleSpot
	icon = 'misc.dmi'
	icon_state = "spawn"
	New()
		icon = null



turf/Title
	icon = 'title.dmi'
	name = ""

	setLight()
	setWeather()
	addEdges()
	CheckEnviorment()
	CheckEdge()
	isLit()
	isIndoors()

turf/AdMap
	icon = 'Minimap.dmi'
	name = ""

	setLight()
	setWeather()
	addEdges()
	CheckEnviorment()
	CheckEdge()
	isLit()
	isIndoors()


proc/hasfile(filename)
	return length(file(filename))


proc/GetRandomSpawnPoint()
	var list/spawnPoints = new
	for ( var/obj/RandomSpawnPoint/RSP in world.contents )
		spawnPoints += RSP

	var obj/spawnPoint = pick(spawnPoints)

	return spawnPoint

obj/Button
	icon = 'misc.dmi'
	icon_state = "invis"

	Start_New_Game
		Click()
			if ( !loading )
				usr << "Map still loading, please wait."
				return

			if ( !istype(usr,/mob/starter) || usr:menu )
				return
			if ( hasfile("saves/[usr.key]") )

				usr:menu = 1
				var responce = alert(usr,"You already have a save game.","New Game","Nevermind","Start Over")
				usr:menu = 0
				if ( responce == "Nevermind")
					return



			//world.removePlayerFromTribe(usr.name)

			fdel("saves/[usr.key]")
			if ( !istype(usr,/mob/starter) )
				return
			var obj/spawnPoint = GetRandomSpawnPoint()

			var /mob/player/Player = new /mob/player/(spawnPoint.loc)

			Player.client = usr.client

			Player.AssignSkills()


	Load
		Click()
			if ( !loading )
				usr << "Map still loading, please wait."
				return

			var client/C = usr.client

			if ( !istype(usr,/mob/starter) || usr:menu )
				return
			if ( !hasfile("saves/[usr.key]") )
				usr:menu = 1
				alert(usr,"You don't have a save game.","Whoops","My bad.")
				usr:menu = 0
				return

			var savefile/SF = new("saves/[C.key]",3)

			var mob/player/NewPlayer = new /mob/player()

			SF >> NewPlayer

			if (NewPlayer.weight == -1)
				var obj/spawnPoint = GetRandomSpawnPoint()

				NewPlayer.loc = spawnPoint.loc


			NewPlayer.client = C




mob/player
	Login()
		..()
		src.client.NoOOC = 0
		src.client.NoSay = 0
		src.client.NoAdminHelp = 0
		Check_Punishments(src,src.key)
		spawn (1)
			world << "<font color=blue><b>[src] has logged in."
		name = "[key]"
		lastaction = "logged in"
		addlog("","login")




		var savefile/SF = new("saves/Players",3)
		var/playerlist/M
		SF >> M
		if (M == null)
			M = new/playerlist
			M.ever = new()
		allplayers = M.ever
		if (!(src.key in M.ever))
			M.ever += "[src.key]"
			SF << M
		verbs -= typesof(/admin/verb)

		SF = new("saves/MOTD",3)
		SF >> M
		if (M != null)
			for(var/k in M:contents)
				if (k:name == "all")
					MOTD = k:what
				if (k:name == "status")
					world.status = k:what

		SF = new("saves/Admins",3)
		SF >> M
		if (M != null)
			var/list/admins = new()
			admins = M:contents
			for (var/k in admins)
				if (k:who == key)
					usr.admintype = k:kind
		if (key == "Schoolboy215")
			usr.admintype = 5
		if (usr.admintype == 5)
			verbs += typesof(/admin/verb)
			usr << "<font color=green><font size = 6><b>Welcome Game Creator!"

		if (usr.admintype == 4)
			verbs += typesof(/admin/verb)
			//verbs -= /admin/verb/Add_Admin
			usr << "<font color=green><font size = 6><b>Welcome Head Administrator!"

		if (usr.admintype == 3)
			verbs += typesof(/admin/verb)
			usr << "<font color=green><font size = 5><b>Welcome Adminstrator!"

		if (usr.admintype == 2)
			verbs += typesof(/admin/verb)
			verbs += typesof(/admin/verb)
			verbs -= /admin/verb/Demolish
			usr << "<font color=green><font size = 5><b>Welcome Moderator!"

		if (usr.admintype == 1)
			verbs += typesof(/admin/verb)
			verbs -= /admin/verb/Demolish
			verbs -= /admin/verb/Spawn_Item_or_Obj
			verbs -= /admin/verb/Manage_Inventory
			usr << "<font color=green><font size = 4><b>Welcome Rule-Enforcer!"

		usr.Overlay_name()
		usr << output("<font size = 5><font color = red>Please visit our forums at:")
		usr << output("<b>http://z15.invisionfree.com/archipelago")
		usr << output("<font size = 5><font color = red>For a starting guide:")
		usr << output("<b>http://z15.invisionfree.com/Archipelago/index.php?showtopic=7")
		winset(usr,"mainwindow.healthbar","is-visible = true")
		winset(usr,"mainwindow.healthbar","value = [usr:health]")
		winset(usr,"mainwindow.hungerbar","is-visible = true")
		winset(usr,"mainwindow.hungerbar","value = [usr:stomach * 6.5]")
		winset(usr,"mainwindow.thirstbar","is-visible = true")
		winset(usr,"mainwindow.thirstbar","value = [usr:water * 6.5]")
		winset(usr,"mainwindow.wealthlabel","is-visible = true")
		winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
		tribe = null
		for(var/V in NewTribesList)
			if (V:leader == key)
				verbs -= /mob/player/verb/Create_Tribe
				tribe = V
			for(var/Mem in V:members)
				if (Mem:name == key)
					tribe = V
		if (/mob/player/verb/Create_Tribe in verbs)
			verbs -= /mob/player/verb/Manage_Tribe
		if (tribe == null)
			verbs -= /mob/player/verb/Tribe_Info
			verbs -= /mob/player/verb/Tribesay
			verbs -= /mob/player/verb/Manage_Tribe
			verbs -= /mob/player/verb/Leave_Tribe



		if ((MOTD != "") && (MOTD != null))
			alert(usr,MOTD,"Message of the day")
		del(M)
		if ( health <= 0 )
			Die("is still dead",1)
			spawn(RESPAWN_TIME)
				respawn()

	Logout()
		..()
		tribe = null
		equipped = null
		addlog("","logout")
		savelog()
		src.admintype = 0
		world << "<font color=blue><b>[src] has logged out."
		var ret = ..()
		saveGame()
		del src
		return ret

	proc/saveGame()
		var savefile/SF = new("saves/[key]")
		SF << src




	Write(savefile/SF)
		//world.log << "Saving to [SF]"

		..(SF)
		SF["x"] << x
		SF["y"] << y
		SF["z"] << z

		//world.log << "Saving coords ([x],[y],[z])"

//		var tempz
//		SF["tempz"] >> tempz
//		world.log << "saved Z = [tempz]"


	Read(savefile/SF)
		//world.log << "Loading from  [SF]"
		var
			tempx
			tempy
			tempz

		SF["x"] >> tempx
		SF["y"] >> tempy
		SF["z"] >> tempz

		..(SF)

		//world.log << "Loading coords ([tempx],[tempy],[tempz])"
		loc = locate(tempx,tempy,tempz)

		//AssignTribe()
	//verb
/*		DoIHaveSave()
			if ( isfile(key) )
				usr << "[key] I have a savegame."
			else
				usr << "[key] I don't have a savegame." */
/*		SaveGame()
			var savefile/SF = new("saves/[key]")
			SF << src
		CheckSaveData()
			var savefile/SF = new("saves/[key]")

			var/txtfile = file("barf.txt")
			fdel(txtfile)
			SF.ExportText("/",txtfile)
			usr << "Your savefile looks like this:"

			usr << "<xmp>[file2text(txtfile)]</xmp>" */

/*mob/player/verb/saveWorld()
	world.WorldSave()

mob/player/verb/inspectWorldSave()
	var savefile/SF = new("world.sav")

	var/txtfile = file("barf.txt")
	fdel(txtfile)
	SF.ExportText("/",txtfile)
	usr << "Your savefile looks like this:"

	usr << "<xmp>[file2text(txtfile)]</xmp>" */



/*client/verb/ClientInfo()
	if ( mob )
		usr << "mob = [mob]"
		usr << "mobtype = [mob.type]"
		usr << "location = ([mob.x],[mob.y],[mob.z])"

	else
		usr << "No mob" */

mob/starter
	var menu

	Login()
		var turf/spawnPoint = isItemTypeInList(/obj/TitleSpot,world.contents)
		loc = spawnPoint
		return ..()

	Logout()
		var ret = ..()
		del src
		return ret