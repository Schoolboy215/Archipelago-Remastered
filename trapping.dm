obj/item/trap
	icon = 'traps.dmi'
	var
		chanceofsuccess = 0
		readystate = "a"
		regstate = "a"
		ready = 0
		maker = ""
	snare
		regstate = "snare"
		readystate = "snare_set"
		name = "simple snare"
		New()
			chanceofsuccess = 20 + (usr:GetSkill(SKILL_TRAPPING)*4)
			icon_state = regstate
			maker = usr:key

	DblClick()
		if(get_dist(src,usr) > 1)
			return
		if (ready == 1)
			icon_state = regstate
			ready = 0
			usr.Public_message("[usr] just disarmed the [name]",MESSAGE_TRAPPING)
			return
		else
			icon_state = readystate
			usr.Public_message("[usr] just armed the [name]",MESSAGE_TRAPPING)
			ready = 1
	proc
		Check()
			for(var/mob/M in loc)
				if (prob(chanceofsuccess))
					src.Public_message("The [name] caught [M]!",MESSAGE_TRAPPING)
					if ((maker <> "") && (!(istype(M,/mob/player))))
						for(var/mob/player/P in world)
							if (P:name == maker)
								P:GiveXP(SKILL_TRAPPING ,50)
					M:setBusy(1)
					if (M:client)
						M:icon_state = "sleep"
						M << "<font color = red>You were caught in the [name]"
				else
					src.Public_message("The [name] sprung but missed [M]!",MESSAGE_TRAPPING)
				ready = 0
				icon_state = regstate

	verb
		Free_Catch()
			set src in view(1)
			set category = null
			if (usr:isActing == 1)
				alert("You cannot free yourself","Nice Try")
				return
			for(var/mob/M in loc)
				if (M:isActing == 1)
					if (M:health > 0)
						M:setBusy(0)
						if (M:client)
							M:icon_state = null
		Break_Down()
			set src in view(1)
			set category = null
			if (src:loc:contents:len > 3)
				alert("You need to clear the area under it first","Clear up")
				return
			usr.Public_message("[usr] starts tearing down the [src]",MESSAGE_TRAPPING)
			usr:setBusy(1)
			sleep(30)
			usr:setBusy(0)
			gameMessage(usr,"You tore down the [src]",MESSAGE_TRAPPING)
			usr:GiveXP(SKILL_TRAPPING,10)
			del(src)

		Examine()
			set src in view(1)
			set category = null
			if ((chanceofsuccess <= 30) && (chanceofsuccess > 20))
				usr << "This is a very poorly made trap"
			if ((chanceofsuccess <= 40) && (chanceofsuccess > 30))
				usr << "This trap was made by a novice"
			if ((chanceofsuccess <= 50) && (chanceofsuccess > 40))
				usr << "This is an average trap"
			if ((chanceofsuccess <= 60) && (chanceofsuccess > 50))
				usr << "This is a good trap"
			if ((chanceofsuccess <= 70) && (chanceofsuccess > 60))
				usr << "This a very good trap"
			if ((chanceofsuccess <= 80) && (chanceofsuccess > 70))
				usr << "This trap was made by a very good trapper!"
			if ((chanceofsuccess <= 90) && (chanceofsuccess > 80))
				usr << "This is an excellent trap"
			if ((chanceofsuccess <= 100) && (chanceofsuccess > 90))
				usr << "VERY few animals will escape this trap"


//CONSTRUCTION OF TRAPS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
obj/item/misc/Branch_With_Vine
	MouseDrop(Over)
		if (get_dist(usr,Over) > 1)
			return
		if (istype(Over,/turf))
			if (istype(Over,/turf/Water))
				alert("You cannot make a trap on water","Error")
				return
			if (Over:contents:len > 2)
				alert("You need to clear the area first","Clear up")
				return
			if (!(isItemTypeInList(/obj/item/trap, Over)))
				usr.Public_message("[usr] starts building a trap",MESSAGE_TRAPPING)
				usr:setBusy(1)
				sleep(40)
				usr:setBusy(0)
				gameMessage(usr,"You built a simple snare trap",MESSAGE_TRAPPING)
				usr:GiveXP(SKILL_TRAPPING,40)
				new/obj/item/trap/snare(Over)
			else
				alert("There is already a trap there","Multiple Traps")
