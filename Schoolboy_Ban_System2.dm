/***
*************************************************************************************************************
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Schoolboy215's Ban System~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*************************************************************************************************************

This code was written on September 09, 2010 by James McKay for use in the BYOND game Cowed. It was specifically
written for use by Maxdax222, but could be used by others as well. To implement this code, use the file called,

"Insertion Instructions.dm"

It gives detailed instructions on what you need to do. Read it thoroughly before attempting anything. As for this
file, simply put it in the same folder as your Cowed source and that should do it.




All ban information is saved to "Players.sav" in the following heirarchy:

Players.sav
  players
    All BYOND accounts
      Ban
      Mute(OOC)
      Mute(IC)
      Mute(AdminHelp)
      reasons
        Ban
          Who
        Mute(OOC)
          Who
        Mute(IC)
          Who
        Mute(AdminHelp)
          Who
  Online
    All BYOND accounts currently logged in
***/




/***
////////////////////////////////////////////////////////////////////////////////////////////////////////////
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
----------------------------Part0-Universal Functions and Procdures-----------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
////////////////////////////////////////////////////////////////////////////////////////////////////////////
***/
proc

  Select_Name()
    var/savefile/F = new("players.sav")
    var/list/choices = new()
    choices += "Current Players"
    choices += "All Players"
    var/result = input("How do you want to choose the player?") as null|anything in choices
    if (result == null)
      return()
    if (result == "Current Players")
      F.cd = "/Online"
    else
      F.cd = "/players"
    var/list/characters = F.dir
    var/list/give = dd_sortedtextlist(characters)
    result = input("Who do you want to choose?") as null|anything in give
    if (result == null)
      return null
    else
      return result

  Select_Punishment_Type()
    var/list/choices = new()
    choices += "Ban"
    choices += "Mute(OOC)"
    choices += "Mute(IC)"
    choices += "Mute(AdminHelp)"
    choices += "Clear All Punishments"
    return input("What punishment do you want to toggle?") as null|anything in choices


  Select_Mob()
    var/list/choices = new()
    for(var/mob/M in world)
      if (M.client)
        choices += M.key
    return input("Which mob do you wish to select?") as null|anything in choices




/***
////////////////////////////////////////////////////////////////////////////////////////////////////////////
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
----------------------------Part1-Main Punishments and punishment management--------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
////////////////////////////////////////////////////////////////////////////////////////////////////////////
***/
obj/Punishment
	var
		Who
		What
		Why
		ByWho
		Expiration
		Created
	Click()
		if (ByWho != usr.key)
			//usr << output("You are not authorized to do that!")
			if (usr.admintype < 4)
				alert(usr,"Only the admin in charge of that punishment ([ByWho]) can edit it","Not your punishment")
				return ..()
		//var/result = input("What do you want to do with this punishment?") as null|anything in list("Remove it","Change it's properties")
		usr.lastaction = "Modifying a punishment"
		var/result = alert(usr,"What do you want to do with this punishment?","Change [What]","Remove it","Change it's properties")
		if (result == null)
			return ..()
		switch(result)
			if ("Remove it")
				Modify_Punishments(Who,What,"a",1)
				for(var/mob/Q in world)
					if(Q:key == Who)
						Q << "<font color = green> Your <b>[What]<b> punishment was just removed"
						switch(What)
							if ("Mute(OOC)")
								Q:client:NoOOC = 0

							if ("Mute(IC)")
								Q:client:NoSay = 0

							if ("Mute(AdminHelp)")
								Q:client:NoAdminHelp = 0
				usr.lastaction = "Removed a punishment"
			if ("Change it's properties")
				var/newwhy = input("What is the new reason?","Give reason","[Why]") as null|message
				if (newwhy == null)
					newwhy = Why
				var/newexp = input("How many hours from now would you like it to expire?(-1 = never expire)") as null|num
				if (newexp == null)
					return
				if ((newexp == -1) || (newexp >= 168))
					if (usr.admintype < 3)
						alert(usr,"You are not allowed to punish players that long")
						return
				var savefile/SF = new("saves/Punishments",3)
				var/mob/M
				SF >> M
				for (var/k in M:contents)
					if (k:Who == Who)
						for  (var/c in k:contents)
							if (c:What == What)
								c:Why = newwhy
								if (newexp != -1)
									c:Expiration = world.realtime + (newexp * 36000)
								else
									c:Expiration = -1
								SF << M
				usr.lastaction = "Changed a punishment"
		Refresh_Admin()

obj/Criminal
	var
		Who
		/*Banned
		OOCMute
		ICMute
		AdminHMute
		BanReason
		OOCReason
		ICReason
		AdminReason
		BanAdmin
		OOCAdmin
		ICAdmin
		AdminAdmin*/
	Click()
		//usr << "You just clicked on the punishments of [Who]"
		usr.lastaction = "Examining [Who]'s punishments"
		var savefile/SF = new("saves/Punishments",3)
		var M
		SF >> M
		if (M != null)
			//winset(usr,"adminwindow.whosepunishments","text = [mes]")
			usr << output("Punishment            Reason                Expires        Administrator in charge","whosepunishments")
			winset(usr,"adminwindow.specificgrid","cells=[4]x[contents.len]")
			var/row = 1
			for (var/k in contents)
				usr << output(k,"specificgrid:1,[row]")
				usr << output(k:Why,"specificgrid:2,[row]")
				if (k:Expiration != -1)
					usr << output(time2text(k:Expiration),"specificgrid:3,[row]")
				else
					usr << output("Permanent","specificgrid:3,[row]")
				usr << output("Admin : [k:ByWho]","specificgrid:4,[row]")
				row ++
		//usr:Observe(src.observer)


			/*for(var/obj/Criminal/k in M:contents)
				if (k.Who == Who)
					var/number = 0
					for(var/c in k.contents)
						number ++
					winset(usr,"adminwindow.whosepunishments","text=Punishments of [Who]")
					winset(usr,"adminwindow.specificgrid","cells=[3]x[number]")*/
					/*var/row = 1
					if (k.Banned)
						usr << output("Banned","specificgrid:1,[row]")
						usr << output(k.BanReason,"specificgrid:2,[row]")
						usr << output("Admin : [k.BanAdmin]","specificgrid:3,[row]")
						row ++
					if (k.OOCMute)
						usr << output("Muted(OOC)","specificgrid:1,[row]")
						usr << output(k.OOCReason,"specificgrid:2,[row]")
						usr << output("Admin : [k.OOCAdmin]","specificgrid:3,[row]")
						row ++
					if (k.ICMute)
						usr << output("Muted(IC)","specificgrid:1,[row]")
						usr << output(k.ICReason,"specificgrid:2,[row]")
						usr << output("Admin : [k.ICAdmin]","specificgrid:3,[row]")
						row ++
					if (k.AdminHMute)
						usr << output("Muted(Admin Help)","specificgrid:1,[row]")
						usr << output(k.AdminReason,"specificgrid:2,[row]")
						usr << output("Admin : [k.AdminAdmin]","specificgrid:3,[row]")
						row ++*/


proc

	Modify_Punishments(punishing as text,kind as text,reason as message,duration as num)
		if (punishing == null)
			return
		if (kind == null)
			return
		if (duration == null)
			return
		if(kind == "Ban")
			if (usr.admintype < 3)
				alert(usr,"You are not allowed to ban players")
				return
		if ((duration == -1) || (duration >= 168))
			if (usr.admintype < 3)
				alert(usr,"You are not allowed to punish players that long")
				return

		var savefile/SF = new("saves/Punishments",3)
		var/mob/M
		SF >> M
		if (M == null)
			M = new /mob
		var/obj/Punishment/adding = new/obj/Punishment
		var/foundcorrect = 0
		for(var/obj/Criminal/k in M:contents)
			if (k:Who == punishing)
				k:name = punishing
				foundcorrect = 1
				var/already = 0
				for (var/obj/Punishment/c in k:contents)
					if (c.What == kind)
						k:contents -= c
						if (k:contents.len == 0)
							del(k)
						already = 1
				if (already == 0)
					adding.Who = punishing
					adding.What = kind
					adding.Why = reason
					adding.ByWho = usr.key
					adding.Created = world.realtime
					if (duration != -1)
						adding.Expiration = world.realtime + (duration*36000)
					else
						adding.Expiration = -1
					adding.name = kind
					k.contents += adding

		if (foundcorrect == 0)
			var/obj/Criminal/n = new/obj/Criminal
			adding.What = kind
			adding.Who = punishing
			adding.Why = reason
			adding.ByWho = usr.key
			adding.Created = world.realtime
			if (duration != -1)
				adding.Expiration = world.realtime + (duration*36000)
			else
				adding.Expiration = -1
			adding.name = kind
			n.contents += adding
			n.name = punishing
			n.Who = punishing
			M:contents += n
		SF << M
		if (adding.ByWho != null)
			var/savefile/punlog = new("logs/punishments.sav")
			var/mob/R
			punlog >> R
			if (R == null)
				R = new/mob
			var/totalpunishments = R.contents.len
			totalpunishments ++
			adding.name = ""
			if (length("[totalpunishments]") < 5)
				for(var/ko=1,ko<=5-length("[totalpunishments]"),ko++)
					adding.name += "0"
			adding.name += "[totalpunishments]"
			R.contents += adding
			punlog << R
		for(var/mob/Q in world)
			if(Q:key == adding:Who)
				if (adding:What == "Ban")
					del(Q)
				Q << "<font color = red> Your <b>[adding:What]<b> status has been toggled"
				var/status
				switch(adding:What)
					if ("Mute(OOC)")
						if (Q:client:NoOOC)
							Q:client:NoOOC = 0
							status = 0
						else
							Q:client:NoOOC = 1
							status = 1

					if ("Mute(IC)")
						if (Q:client:NoSay)
							Q:client:NoSay = 0
							status = 0
						else
							Q:client:NoSay = 1
							status = 1

					if ("Mute(AdminHelp)")
						if (Q:client:NoAdminHelp)
							Q:client:NoAdminHelp = 0
							status = 0
						else
							Q:client:NoAdminHelp = 1
							status = 1
				if (status == 1)
					Q << "<font color = red> It is now <b> active"
					Q << "<font color = red> For more details, log out,then back in"
				else
					Q << "<font color = green> It is now inactive!"
		del(M)





proc
	Check_Punishments(who as mob,checking as text)
		var savefile/S = new("saves/Punishments",3)
		var/mob/M
		S >> M
		if (M != null)
			var/list/applytouser = new()
			var/Expired = 0
			for (var/k in M:contents)
				if (k:Who == checking)
					for(var/c in k:contents)
						Expired = 0
						if (c:Expiration <= world.realtime)
							if (c:Expiration != -1)
								who << "<font color = green>Your <b>[c:What]</b> punishment has expired"
								Expired = 1
								k:contents -= c
								if (k:contents:len == 0)
									M:contents -= k
								S << M
						if (Expired == 0)
							if (c:What == "Ban")
								who << "<font size = 5><font color = red>You are banned!"

								who << "<font style = underline><font color = red><b>[c:ByWho]</b> gave the following reason for the ban:"
								who << ""
								who << "<font color = red><b>[c:Why]"
								if (c:Expiration != -1)
									who << "<font color = red>You can next play at :<b>[time2text(c:Expiration)]"
								else
									who << "<font color = red>The duration is <font size = 4> PERMANENT"
								who << ""
								who << "<font color = red>If you disagree, go to the forums"
								who << "You will be kicked in 3"
								sleep(10)
								who << "2"
								sleep(10)
								who << "1"
								sleep(10)
								del(who)
							applytouser += c
			if (applytouser.len == 0)
				who << "<font color = green>You have no active punishments!"
				return
			who << "<font color = red>You have [applytouser.len] active punishment(s)"
			who << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
			for (var/k in applytouser)
				switch(k:What)
					if ("Mute(OOC)")
						who:client:NoOOC = 1
					if ("Mute(IC)")
						who:client:NoSay = 1
					if ("Mute(AdminHelp)")
						who:client:NoAdminHelp = 1
				who << "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				who << "Type of punishment : <b>[k:What]"
				who << "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
				who << ""
				who << "Reason for punishment : <b>[k:Why]"
				who << ""
				if (k:Expiration != -1)
					who << "Punishment expires in : <b>[k:Expiration/36000 - world.realtime/36000] hours"
				else
					who << "Punishment expires : <font color = red><b>Never!"
				who << ""
				who << "Punishment issuer : <b>[k:ByWho]"
			who << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		del(M)











/***
////////////////////////////////////////////////////////////////////////////////////////////////////////////
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-----------------------------------Part2-Extra Punishments--------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
////////////////////////////////////////////////////////////////////////////////////////////////////////////
***/






