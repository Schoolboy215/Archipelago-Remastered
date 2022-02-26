#define CL_RED			"#ED1C24"
#define CL_ORANGE		"#FF7E00"
#define CL_YELLOW		"#A8E61D"
#define CL_GREEN		"#22B14C"
#define CL_BLUE			"#00B7EF"

#define REFRESH_TIME	10
var/list
	allplayers
var
	MOTD
obj/LogMess
	var
		what
mob
	var
		lastaction
		admintype
obj/adminkind
	var
		who
		kind

playerlist
	var
		list
			ever

obj/Map_Icon
	icon = 'Map_Icons.dmi'
	icon_state ="Person"
	var
		_x
		_y
		monitorwindow/master
		oicon_state
		ricon_state
		screenloc
	New(_x, _y, master)
		. = ..()
		icon = "Map_Icons.dmi"
		icon_state ="person"
		screen_loc = "maplabel:1,1"
		x =  usr.x
		y = usr.y
		src._x = _x
		src._y = _y

obj/paint_object

	icon = 'Map_Icons.dmi'
	var
		_x
		_y
		paint_window/master
		oicon_state
		ricon_state
	New(_x, _y)
		. = ..()
		icon_state = "person"
		screen_loc = "maplabel:[_x]+1,[_y]"
		//src._x = _x
		//src._y = _y


/proc
	Edit(atom/o in world)
		set category = null
		var/v = input("Which variable?") in o.vars
		if (istype(o.vars[v],/list))
			for(var/l in o.vars[v])
				usr << l
			return ..()
		//usr << "variable '<b>[v]</b>' is set to <b>[o.vars[v]]</b>"
		var/result = alert(usr,"Value is '[o.vars[v]]'. Change?","Variable : [v]","Yes","No")
		if (result == "No")
			return
		if (usr.admintype < 3)
			alert(usr,"You are not allowed to change properties","Privelage Issue")
			return
		if (usr.admintype < 5)
			switch(v)
				if ("value")
					alert(usr,"You cannot change the value of objects")
					return
				if ("account")
					alert(usr,"If you want to change your account, go the bank!")
					return
				if ("key")
					alert(usr,"Probably not a good thing to edit!")
					return
			if (istype(o,/obj/item/economy))
				alert(usr,"No messing with the economy")
				return
		var/kind
		if (isnum(o.vars[v]))
			kind = "num"

		if (istext(o.vars[v]))
			kind = "text"

		if (kind == null)
			alert(usr,"You cannot edit that variable type","Error")
			return ..()
		if(v == "admintype")
			if (usr.admintype > 5)
				alert(usr,"Nice try. I congratulate your resourcefulness","Noob")
				return

		switch(kind)
			if ("num")
				var/result2 = input("Change to what?","Input","[o.vars[v]]") as null|num
				if (result2 == null)
					return
				o.vars[v] = result2

			if ("text")
				var/result2 = input("Change to what?","Input","[o.vars[v]]") as null|text
				if (result2 == null)
					return
				o.vars[v] = result2

		usr << "variable <b>[v]</b> changed to <b>[o.vars[v]]</b>"
		addlog("changed [v] property for [o]","admin")


admin/verb
	/*add_ip()
		set category = "Admin"
		usr << "Hey"
		usr << src:client.address
		var savefile/ipsave = new("ips.sav")
		ipsave["/[usr:client.address]"] << usr.key
		for(var/v in ipsave.dir)
			usr << v*/

	Spawn_Item_or_Obj(var/type in typesof(/obj))
		set category = "Admin"
		var/how = input("How many?") as num
		var/where = input("Where?") as anything in list("Inventory","Ground")
		for(var/k=0,k<how,k++)
			if (type in typesof(/obj/item))
				if (where == "Inventory")
					new type(usr)
				else
					new type(usr.loc)
			else
				if (usr.admintype < 3)
					alert(usr,"You are not allowed to spawn objects","Privelage Issue")
					return
				new type(usr.loc)
		addlog("spawned [how] [type]","admin")
		usr.lastaction = "spawned : [type]"


	GetInfo(atom/o in world)
		set category = null
		usr.lastaction = "Editing [o]"
		addlog("edited [o]","admin")
		Edit(o)

	Manage_Inventory(mob/m in world)
		set category = "Admin"
		usr.lastaction = "Managing [m:key]'s inventory"
		addlog("managed [m:key]'s inventory","admin")
		var/examine = input("Which item") as null|anything in m.contents
		if (examine == null)
			return ..()
		var/decide = input("What do you want to do with [examine]?") as null|anything in list("Change properties","Transfer to your inventory","Delete")
		if (decide == null)
			return ..()
		if (decide == "Change properties")
			usr.lastaction = "Remotely editing [m:key]'s [examine]"
			Edit(examine)
		if (decide == "Transfer to your inventory")
			usr.lastaction = "Remotely confiscated [m:key]'s [examine]"
			addlog("took [m:key]'s [examine]","admin")
			m << "An item from your inventory ([examine]) was just remotely confiscated by an admin"
			examine:Move(usr)
		if (decide == "Delete")
			usr.lastaction = "Remotely deleted [m:key]'s [examine]"
			addlog("deleted [m:key]'s [examine]","admin")
			m << "An item from your inventory ([examine]) was just remotely deleted by an admin"
			del(examine)

	Add_Overlay(var/type in typesof(/obj))
		set category = "Admin"
		usr.underlays += type
		//usr.overlays += /mob/player
		//usr.icon = null

	Remove_Overlay()
		set category = "Admin"
		usr.underlays --
		usr.icon = 'People.dmi'

	Teleport()
		set category = "Admin"
		var/result = alert(usr,"Teleport to what?","Choice","Specific Coordinates","A Player","Cancel")
		switch(result)
			if ("Cancel")
				return
			if ("Specific Coordinates")
				if(usr.admintype < 2)
					alert(usr,"You are not allowed to teleport to coordinates","Privelage Issue")
					return
				var/x = input("X coordinate?") as num
				var/y = input("Y coordinate?") as num
				usr.x = x
				usr.y = y
				addlog("teleported to [x],[y]","admin")
				usr.lastaction = "Teleported to [x],[y]"
			if ("A Player")
				var/mob/M = input("Which player?") as null|mob in world
				if (M == null)
					return
				usr.loc = M.loc
				addlog("teleported to [M:key]","admin")
				usr.lastaction = "Teleported to [M:key]"

	Warp()
		set category = "Admin"
		var/who = input("Who do you want to warp somewhere?") as null|mob in world
		if (who == null)
			return..()
		var/result = alert(usr,"Teleport to what?","Choice","Specific Coordinates","A Player","Cancel")
		switch(result)
			if ("Cancel")
				return
			if ("Specific Coordinates")
				if(usr.admintype < 2)
					alert(usr,"You are not allowed to warp to coordinates","Privelage Issue")
					return
				var/x = input("X coordinate?") as num
				var/y = input("Y coordinate?") as num
				who:x = x
				who:y = y
				addlog("Warped [who:key] to [x],[y]","admin")
				usr.lastaction = "Warped [who:key] to [x],[y]"
			if ("A Player")
				var/mob/M = input("Which player?") as null|mob in world
				if (M == null)
					return
				who:loc = M.loc
				addlog("Warped [who:key] to [M:key]","admin")
				usr.lastaction = "Warped [who:key] to [M:key]"

	Clear_All_Inventories()
		set category = "Admin"
		if (usr.admintype < 5)
			alert(usr,"You cannot do that unless you own the game")
			return ..()
		var savefile/SF = new("saves/Players",3)
		var/playerlist/M
		SF >> M
		if (M == null)
			M = new/playerlist
			M.ever = new()
		var/mob/tempo = new/mob
		for(var/each in M.ever)
			if (each != "[usr.key]")
				var savefile/SF2 = new("saves/[each]",3)
				SF2 >> tempo
				tempo.contents = new()
				tempo.wealth = 0
				tempo.account = 0
				tempo:weight = 0
				var obj/spawnPoint = GetRandomSpawnPoint()
				tempo.loc = spawnPoint.loc
				SF2 << tempo
				del(tempo)

	Clear_Recent_Sales()
		set category = "Admin"
		if (usr.admintype < 4)
			alert(usr,"If you want to clear the sales, buy everything!")
			return ..()
		var/delnum = 0
		var/delval = 0
		for(var/I in recentsales)
			delnum ++
			delval += I:value
		recentsales = new()
		alert("You just deleted [delnum] items with a total value of [delval]")

	Player_Details()
		set category = "Admin"
		if (usr.admintype < 3)
			alert(usr,"Go ask them yourself!")
			return ..()
		var/result = input("Who do you want the details of?") as null|mob in world
		if (result == null)
			return
		usr << "<b>Here is your report</b>"
		usr << "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"
		usr << result
		usr << "<font color = blue>STATUS"
		usr << "Health : [result:health]"
		usr << "Hunger : [result:stomach*6.5]% full"
		usr << "Thirst : [result:water*6.5]% full"
		usr << "Wealth : [result:wealth] carried"
		usr << "         [result:account] in the bank"
		if ((result:nicotinecraving != -1) && (result:nicotinecraving != null))
			usr << "[result] is addicted to nicotine"
			usr << "Their craving is [result:nicotinecraving]"
		usr << "<font color = blue>SKILLS</i>"
		usr << "level [result:getSkillLevel(result:XP_Building)] Building"
		usr << "level [result:getSkillLevel(result:XP_Crafting)] Crafting"
		usr << "level [result:getSkillLevel(result:XP_Smithing)] Smithing"
		usr << "level [result:getSkillLevel(result:XP_Mining)] Mining"
		usr << "level [result:getSkillLevel(result:XP_Farming)] Farming"
		usr << "level [result:getSkillLevel(result:XP_Alchemy)] Alchemy"
		usr << "level [result:getSkillLevel(result:XP_Fishing)] Fishing"
		usr << "level [result:getSkillLevel(result:XP_Swimming)] Swimming"
		usr << "level [result:getSkillLevel(result:XP_Lumberjack)] Lumberjacking"
		usr << "level [result:getSkillLevel(result:XP_Cooking)] Cooking"
		usr << "level [result:getSkillLevel(result:XP_Combat)] Combat"
		usr << "<font color = blue>INVENTORY</i>"
		for(var/I in result:contents)
			usr << I
		usr << "-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_"




	Demolish(atom/which in oview(1))
		set category = "Admin"
		set category = null
		if (which.name == "lighting")
			usr << "Don't be screwing with that"
			return
		usr.lastaction = "destroyed : [which]"
		addlog("demolished [which]","admin")
		del(which)

	Monitor_Activity()
		set category = null
		if (usr.admintype < 2)
			alert(usr,"You are not allowed to monitor players","Privelage Issue")
			return
		winshow(src, "monitorwindow")
		addlog("monitored players","admin")
		while(winget(usr,"monitorwindow","is-visible"))
			var/list/players = new()
			for (var/mob/M in world)
				if (M.client)
					players += M
			winset(src,"monitorwindow.actiongrid","cells=[3]x[players.len]")
			winset(src,"monitorwindow.adminmap","cells=300x300");
			var/row = 1
			for (var/mob/M in players)
				src << output(M,"actiongrid:1,[row]");
				src << output(M.lastaction,"actiongrid:2,[row]");
				src << output("[M.x],[M.y]","actiongrid:3,[row]");
				row ++
			usr.lastaction = "monitoring players"
			sleep(REFRESH_TIME)

	Observe(mob/M in world)
		set category = "Admin"
		if(M == usr)
			usr.client.eye = usr
			usr.client.perspective = MOB_PERSPECTIVE
		else
			usr.client.eye = M
			usr.client.perspective = EYE_PERSPECTIVE
			usr.lastaction = "Observing [M:key]"
			addlog("observed [M:key]","admin")
			usr:setBusy(1)



	Stop_Observing()
		set category = "Admin"
		usr.client.eye = usr
		usr.client.perspective = MOB_PERSPECTIVE
		usr.lastaction = "Ceased observation"
		usr:setBusy(0)

	Announce(what as text)
		set category = "Admin"
		addlog("announced, [what]","admin")
		for(var/mob/player/P in world.contents)
			P << "<font size = 4>[usr.name] would like to announce :<b>[what]"

	Change_Status()
		set category = "Admin"
		var/result = alert(usr,"This will change the status that is seen on the pager. Do you want to proceed?","Are you sure?","Yes","No")
		if (result == "No")
			return ..()
		if (result == "Yes")
			var/what = input("What do you want the status to be?","Status","[world.status]") as text
			world.status = what
			usr << "<font color = green>World status changed to <b>[what]"
			for (var/mob/M in world)
				M << "<b>[usr.name] just changed the server's status to : <i>[what]"
			addlog("changed server status to, [what]","admin")
			var savefile/SF = new("saves/MOTD",3)
			var M
			SF >> M
			if (M == null)
				M = new/mob
			if (M:contents:len == 0)
				var/obj/LogMess/N = new/obj/LogMess
				N:name = "status"
				N:what = "[what]"
				M:contents += N
			else
				for(var/k in M:contents)
					if (k:name == "status")
						k:what = "[what]"


	Add_Admin()
		set category = null
		if (usr.admintype < 5)
			alert(usr,"You are not allowed to make new admins","Privelage Issue")
			return
		var/name
		usr.lastaction = "Adding an admin"
		var/result = alert(usr,"Is the player on right now?","Currently on","Yes","No")
		if (result == "Yes")
			var/m = input("Who then?") as null|mob in world
			if (m == null)
				return
			if (m:client)
				name = m:key
		else
			name = input("Who then?") as null|anything in allplayers
			if (name == null)
				return
		var/level = input("What level are they?") as null|anything in list(1,2,3,4,5)
		if (level == null)
			return ..()
		var savefile/SF = new("saves/Admins",3)
		var M
		SF >> M
		if (M == null)
			M = new/mob
		if (M != null)
			var/list/admins = new()
			admins = M:contents
			for (var/k in admins)
				if (k:who == name)
					k:kind = level
					if (k:kind == 0)
						del(k)
					M:contents = admins
					SF << M
					return ..()
			var/obj/adminkind/n = new/obj/adminkind
			if (level != 0)
				n.who = name
				n.kind = level
				M:contents += n
				SF << M
		usr.lastaction = "Added [name] as a level [level] admin"
		addlog("added [name] to admin team","admin")
		Refresh_Admin()
		del(M)

	Manage_Admins()
		set category = null
		if (usr.admintype < 5)
			alert(usr,"You are not allowed to edit adminships","Privelage Issue")
			return
		usr.lastaction = "Managing Admins"
		var savefile/SF = new("saves/Admins",3)
		var M
		SF >> M
		if (M == null)
			M = new/mob
		if (M != null)
			var/list/admins = new()
			admins = M:contents
			var/list/choices = new()
			for(var/k in admins)
				choices += k:who
			var/result = input("Which admin do you want to do something with?") as null|anything in choices
			if (result == null)
				return
			for(var/k in admins)
				if (result == k:who)
					if (k:kind == 5)
						if(usr.admintype < 5)
							alert(usr,"You are not allowed to change the creator","Privelage Issue")
							return

			var/what = alert(usr,"What do you want to do with [result]?","Choice","Remove Adminship","Change Level")
			if (what == "Remove Adminship")
				for (var/k in admins)
					if (k:who == result)
						del(k)
						M:contents = admins
						SF << M
						for(var/mob/N in world)
							if (N:key == result)
								N << "Your adminship has been revoked"
								sleep(10)
								del(N)
								Refresh_Admin()
				usr.lastaction = "Removed [result] from the admin team"
			else
				what = input("What is their new level of adminship?") as anything in list(1,2,3,4,5)
				if (what == 5)
					if (usr.admintype < 5)
						alert(usr,"Nice try","Privelage Issue")
						return
				for (var/k in admins)
					if (k:who == result)
						k:kind = what
						M:contents = admins
						SF << M
						Refresh_Admin()
				usr.lastaction = "Changed [result]'s admin lebel to [what]"
		del(M)


	New_Pun()
		set category = null
		usr.lastaction = "Making a new punishment"
		var/result = input("How do you want to select the player?") as null|anything in list("Currently Online","All Players")
		if (result == null)
			return ..()
		var/who
		switch(result)
			if ("Currently Online")
				var/whom = input("Which player") as null|mob in world
				if (whom == null)
					return ..()
				who = whom:key
			if ("All Players")
				if (usr.admintype < 2)
					alert(usr,"You can only punish players who are currently online")
					return
				var/list/give = dd_sortedtextlist(allplayers)
				who = input("Which player") as null|anything in give
				if (who == null)
					return ..()
		var/what = input("How do you want to select the player?") as null|anything in list("Ban","Mute(OOC)","Mute(IC)","Mute(AdminHelp)")
		if (what == null)
			return ..()
		var/why = input("What is your reason?") as null|message
		if (why == null)
			return ..()
		var/long = input("How long (in hours) shall the punishment last? (-1 = forever)") as null|num
		if (long == null)
			return ..()
		addlog("gave [who] a [what] punishment","admin")
		usr.lastaction = "Gave [who] a [what] punishment"
		Modify_Punishments(who,what,why,long)
		Refresh_Admin()

	Change_MOTD()
		set category = null
		if (usr.admintype < 3)
			alert(usr,"You are not allowed to change that","Privelage Issue")
			return
		usr.lastaction = "Chaning MOTD"
		var/result = input("New MOTD","Input","[MOTD]") as null|message
		if (result == null)
			return ..()
		MOTD = result
		var savefile/SF = new("saves/MOTD",3)
		var M
		SF >> M
		if (M == null)
			M = new/mob
		if (M:contents:len == 0)
			var/obj/LogMess/N = new/obj/LogMess
			N:name = "all"
			N:what = MOTD
			M:contents += N
		else
			for(var/k in M:contents)
				if (k:name == "all")
					k:what = MOTD
		addlog("changed MOTD","admin")
		SF << M

	Admin_Panel()
		set category = "Admin"
		winshow(usr, "adminwindow")
		usr.lastaction = "Opened the admin window"
		Refresh_Admin()


proc
	Refresh_Admin()
		winset(usr,"adminwindow.specificgrid","cells=0x0")
		winset(usr,"adminwindow.whosepunishments","text=")
		var savefile/SF = new("saves/Punishments",3)
		var/mob/M
		SF >> M
		if (M != null)
			var/list/actives = new()
			for(var/k in M:contents)
				actives += k
			winshow(usr, "adminwindow")
			winset(usr,"adminwindow.activegrid","cells=[2]x[actives.len]")
			var/row = 1
			var/specifics = ""
			for(var/k in actives)
				specifics = ""
				for(var/c in k:contents)
					if (specifics != "")
						specifics += ", "
					switch(c:name)
						if ("Ban")
							specifics += "Banned"
						if ("Mute(OOC)")
							specifics += "OOC Muted"
						if ("Mute(IC)")
							specifics += "IC Muted"
						if ("Mute(AdminHelp)")
							specifics += "Admin-Help Muted"
				k:name = k:Who
				winset(usr,"adminwindow.activegrid","font-style=bold")
				winset(usr,"adminwindow.activegrid","text-color=blue")
				usr << output(k,"activegrid:1,[row]")
				winset(usr,"adminwindow.activegrid","font-style=normal")
				winset(usr,"adminwindow.activegrid","text-color=#255")
				usr << output(specifics,"activegrid:2,[row]")
				//usr << winget(usr,"adminwindow.activegrid","current-cell")
				row ++
		SF = new("saves/Admins",3)
		SF >> M
		if (M != null)
			var/list/admins = new()
			admins = M:contents
			var/row = 1
			winset(usr,"adminwindow.admingrid","cells=[2],[admins.len]")
			for (var/k in admins)
				switch(k:kind)
					if(5)
						winset(usr,"adminwindow.admingrid","text-color = [CL_RED]")
					if(4)
						winset(usr,"adminwindow.admingrid","text-color = [CL_ORANGE]")
					if(3)
						winset(usr,"adminwindow.admingrid","text-color = [CL_YELLOW]")
					if(2)
						winset(usr,"adminwindow.admingrid","text-color = [CL_GREEN]")
					if(1)
						winset(usr,"adminwindow.admingrid","text-color = [CL_BLUE]")
				usr << output(k:who,"admingrid:1,[row]")
				usr << output(k:kind,"admingrid:2,[row]")
				row ++

		var/row = 1
		winset(usr,"adminwindow.currentgrid","cells=1,1")
		for(M in world)
			if(M.client)
				usr << output(M,"currentgrid:1,[row]")
				row ++
		del(M)
admin/verb
	Show_Archives()
		set category = null
		winshow(usr,"adminwindow2")
		winset(usr,"adminwindow2.archivegrid","cells=0x0")
		winset(usr,"adminwindow2.archivegrid2","cells=0x0")
		var/savefile/SF = new("logs/punishments.sav")
		var/mob/M
		SF >> M
		if (M == null)
			alert(usr,"The archives are empty!")
			winshow(usr,"adminwindow = 0")
			return
		var/lengthy = M.contents.len
		lengthy ++
		var/maxa
		if (lengthy < 10)
			maxa = 1
		else
			maxa = lengthy - 10
		var/row = 2
		usr << output("ID#","archivegrid:1,1")
		usr << output("Criminal","archivegrid:2,1")
		usr << output("Type","archivegrid:3,1")
		usr << output("Reason","archivegrid:4,1")
		usr << output("Admin","archivegrid:5,1")
		usr << output("Date","archivegrid:6,1")
		usr << output("Status","archivegrid:7,1")
		for(var/k=lengthy,k>=maxa,k--)
			for(var/c in M.contents)
				if (text2num(c:name) == k)
					usr << output(c:name,"archivegrid:1,[row]")
					usr << output(c:Who,"archivegrid:2,[row]")
					usr << output(c:What,"archivegrid:3,[row]")
					usr << output(c:Why,"archivegrid:4,[row]")
					if (c:ByWho == usr.key)
						usr << output("<font color = blue><b>[c:ByWho]","archivegrid:5,[row]")
					usr << output("[time2text(c:Created,"MM.DD.YY")] [time2text(c:Created,"hh:mm:ss")]" ,"archivegrid:6,[row]")
					if (c:Expiration == -1)
						usr << output("<font color = red>Permanent","archivegrid:7,[row]")
					else
						if (world.realtime > c:Expiration)
							usr << output("<font color = green>Expired","archivegrid:7,[row]")
						else
							usr << output("<font color = blue>Expires in [(c:Expiration/36000)-(world.realtime/36000)] hours","archivegrid:7,[row]")
					row ++

	Search_Archives()
		set category = null
		var/result = alert(usr,"How do you want to search?","Choice","ID number","Criminal","Administrator")
		if (result == null)
			return
		var/savefile/SF = new("logs/punishments.sav")
		var/mob/M
		SF >> M
		var/list/results = new()
		winset(usr,"adminwindow2.archivegrid2","cells = 0x0")
		switch(result)
			if("ID number")
				result = input("What is the ID number you want to find?") as null|num
				if (result == null)
					return
				for(var/k in M:contents)
					if (text2num(k:name) == result)
						results += k
			if("Criminal")
				result = input("What is the name you want to search?") as null|text
				if (result == null)
					return
				for(var/k in M:contents)
					if (k:Who == result)
						results += k
			if("Administrator")
				result = input("Whose punishments are you looking for?") as null|text
				if (result == null)
					return
				for(var/k in M:contents)
					if (k:ByWho == result)
						results += k
		var/row = 2
		usr << output("ID#","archivegrid2:1,1")
		usr << output("Criminal","archivegrid2:2,1")
		usr << output("Type","archivegrid2:3,1")
		usr << output("Reason","archivegrid2:4,1")
		usr << output("Admin","archivegrid2:5,1")
		usr << output("Date","archivegrid2:6,1")
		usr << output("Status","archivegrid2:7,1")
		for(var/c in results)
			usr << output(c:name,"archivegrid2:1,[row]")
			usr << output(c:Who,"archivegrid2:2,[row]")
			usr << output(c:What,"archivegrid2:3,[row]")
			usr << output(c:Why,"archivegrid2:4,[row]")
			if (c:ByWho == usr.key)
				usr << output("<font color = blue><b>[c:ByWho]","archivegrid2:5,[row]")
			usr << output("[time2text(c:Created,"MM.DD.YY")] [time2text(c:Created,"hh:mm:ss")]" ,"archivegrid2:6,[row]")
			if (c:Expiration == -1)
				usr << output("<font color = red>Permanent","archivegrid2:7,[row]")
			else
				if (world.realtime > c:Expiration)
					usr << output("<font color = green>Expired","archivegrid2:7,[row]")
				else
					usr << output("<font color = blue>Expires in [(c:Expiration/36000)-(world.realtime/36000)] hours","archivegrid2:7,[row]")
			row ++

