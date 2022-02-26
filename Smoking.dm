/*

add this to the health_module after the part about getting hungrier

if (nicotinecraving > -1)
				nicotinecraving = nicotinecraving + 10
				if (nicotinecraving >= 150)
					var/chance = rand(1,5)
					if ( chance == 2)
						gameMessage(src,"Your addiction is cured",MESSAGE_SMOKING)
						usr << "<font color = green>Your urge to smoke is gone!"
						nicotinecraving = -1
						return ..()
				gameMessage(src,"You are craving a cigarette.",MESSAGE_SMOKING)
				if (nicotinecraving >= 100)
					nicotinecraving = 100
					gameMessage(src,"Your urges are so bad that you hurt yourself!",MESSAGE_SMOKING)
					Hurt(30,"commited suicide for lack of cigarettes!")


You will also need to define MESSAGE_SMOKING and add a mob variable called nicotinecraving

Also add this in the health_module after the parts that display stats:

if (usr.nicotinecraving > -1)
				statpanel("Status","Nicotine Craving",usr.nicotinecraving)
			else
				statpanel("Status","Nicotine Craving","NOT ADDICTED")








~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SMOKING~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
mob/var
	nicotinecraving

admin/verb
	Cure_Smoking_Addiction()
		set category = "Admin"
		var/M = input("Who do you want to cure?") as null|mob in world
		if (M == null)
			return ..()
		if (M:nicotinecraving > -1)
			M:nicotinecraving = null
			M << "<font color = green>Your nicotine addiction was cured by an admin"
			usr << "Cure Successful"
			usr.lastaction = "Nicotine addiction cured"
		else
			usr << "That player is not addicted"

obj/item/smoking/Cigarette_Box
	icon = 'Smoking.dmi'
	icon_state = "Generic"
	value = 13
	weight = 5
	density = 0
	var
		brand
	verb
		Examine()
			set category = null
			usr << "This box contains [length(contents)] cigarettes"

		Take_Cigarette()
			set category = null
			if (length(contents) == 0)
				usr << "<font color = red>That box is empty!"
				return ..()
			usr:contents += contents[1]
			usr.lastaction = "Took cigarette out of box"

obj/item/smoking/Cigarette
	icon = 'Smoking.dmi'
	icon_state = "Unsmoked"
	value = 15
	var
		puffs
		brand
	verb
		Smoke()
			set category = null
			if ((brand != "") && (brand != "plain"))
				usr.Public_message("[usr.key] takes a drag on their [brand] cigarette",MESSAGE_SMOKING)
			else
				usr.Public_message("[usr.key] takes a drag on their cigarette",MESSAGE_SMOKING)
			if (icon_state == "Unsmoked")
				icon_state = "Smoking"
			puffs ++
			usr.nicotinecraving = usr.nicotinecraving - 5
			if (usr.nicotinecraving < 0)
				usr.nicotinecraving = 0
			if (puffs >= 5)
				gameMessage(src,"Your cigarette is gone",MESSAGE_SMOKING)
				var/obj/item/smoking/Butt/B = new /obj/item/smoking/Butt
				B.name = "Cigarette Butt"
				usr.contents += B
				del(src)
			usr.lastaction = "Smoked cigarette"


		Gather_Cigarettes()
			set category = null
			var/list/boxes = new()
			for(var/obj/item/smoking/Cigarette_Box/C in usr)
				boxes += C
			if (length(boxes) == 0)
				usr << "You dont have any boxes"
				return ..()
			var/which = input("Which box?") as null|anything in boxes
			if (which == null)
				return ..()
			if (length(which:contents) >= 20)
				usr << "That box is full"
				return ..()
			for(var/obj/item/smoking/Cigarette/C in usr)
				if (C.icon_state == "Unsmoked")
					if (C.brand == "")
						C.brand = which:brand
					which:contents += C
					if (length(which:contents) >= 20)
						usr << "That box is now full"
						return ..()
					//del(C)
			usr.lastaction = "Put cigarettes in a box"

obj/item/smoking/Butt
	icon = 'Smoking.dmi'
	icon_state = "Butt"


