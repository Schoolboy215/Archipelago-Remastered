#define MAX_WEIGHT	100

mob/player/verb
	Mass_Drop()
		var/result = alert("What do you want to drop?","Choice","Burnt food","All of a certain item","Cancel")
		switch(result)
			if("Cancel")
				return
			if("Burnt food")
				var/choice = alert("Are you sure you want to drop all burnt food?","Yes/No","Yes","No")
				switch(choice)
					if("No")
						return
					if("Yes")
						for(var/obj/item/food/I in usr.contents)
							if(istype(I,/obj/item/food))
								if(I:cooked == 2)
									I:loc = usr.loc
									I:CleanUpOcean()
									usr:weight -= I:weight
			if("All of a certain item")
				var/thing = input("What do you want to drop all of?") as null|obj in usr.contents
				if (thing == null)
					return
				if (istype(thing,/obj/item/economy/Money))
					alert(usr,"You cannot do this with money.")
					return
				var/choice = alert("Are you sure you want to drop all of your [thing]?","Yes/No","Yes","No")
				switch(choice)
					if("No")
						return
					if("Yes")
						var/dropnum = 0
						var/dropweight = 0
						for(var/obj/I in usr.contents)
							if(istype(I,thing:type))
								I:loc = usr.loc
								I:CleanUpOcean()
								dropnum ++
								dropweight += I:weight
								usr:weight -= I:weight
						alert("You dropped [dropnum] for a total weight of [dropweight]")

	Mass_Pickup()
		var/list/listed = new()
		for(var/obj/item/I in usr:loc)
			listed += I
		var/result = input("What do you want to pickup") as null|obj in listed
		if (result == null)
			return
		if (istype(result,/obj/item/economy/Money))
			alert(usr,"You cannot do this with money.")
			return
		var/getnum = 0
		var/getweight = 0
		for (var/obj/item/I in usr:loc)
			if (istype(I,result:type))
				if (I:weight + usr:weight > 100)
					alert("You have picked up as many as you could ([getnum]).")
					return ..()
				getnum ++
				getweight += I:weight
				I.Move(usr)
		alert("You picked up [getnum] for a total weight of [getweight]")



mob/player
	var weight = 0

	Stat()
		HealthStat()
		statpanel("Inventory",contents)
		statpanel("Inventory","Weight","[weight]/[MAX_WEIGHT]")

		StatSkills()
		ChestStats()

	proc/hasItems(itemType,num)
		var found = 0
		for ( var/obj/item/thing in contents )
			if ( istype(thing,itemType) )
				found++
				if ( found >= num )
					return 1

		return 0

/*	proc/getItems(itemType,num)
		var list/retList = new()
		var found = 0
		for ( var/obj/item/thing in contents )
			if ( istype(thing,itemType) )

				retList += thing
				found++
				if ( found >= num )
					return retList

		return retList */




obj
	item
		tool
			DblClick()
				..()
				if ( loc != usr )
					return
				if ( usr:isBusy() )
					return

				if ( usr:equipped )
					usr:overlays -= new/obj/overlay(usr:equipped:name)
					if ( src == usr:equipped )
						suffix = null
						usr:equipped = null
						return
					usr:equipped.suffix = null

				suffix = "Equipped"
				usr.lastaction = "equipped : [src]"
				usr:equipped = src
				usr:overlays += new/obj/overlay(src:name)

		verb
			Get()
				set src in oview(1)
				if ( usr:isBusy() )
					return

				if (src.type == /obj/item/economy/Money)
					//var totalheld = usr.wealth
					for(var/obj/item/economy/Money/M in usr)
						del(M)
					var/obj/item/economy/Money/noo = new /obj/item/economy/Money(usr)
					//set src as obj in oview(1)
					var/obj/item/economy/Money/onground = src
					//totalheld += onground.worth
					usr.wealth += onground.worth
					winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
					noo.worth = usr.wealth
					noo.name = "Wealth x [noo.worth]"
					noo.name = "Wealth x [noo.worth]"
					del(src)
					return()
				else
					Move(usr)
					pickedUp = 1
				usr.lastaction = "got : [src]"
				addlog("[src]","get")
			Drop()
				set src in usr
				if ( usr:isBusy() )
					return

				density = 0
				if (src.type == /obj/item/economy/Money)
					var howmuch = input("How much money do you want to drop?") as null|num
					if (howmuch >= usr.wealth)
						//var/obj/item/economy/Money/noo = new /obj/item/economy/Money(usr.loc)
						Move(usr.loc)
						usr.wealth = 0
						winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
						//del(src)
						//noo.worth = usr.wealth
						//noo.name = "Wealth x [usr.wealth]"
						//usr.wealth = 0
						return ..()
					else
						//var/obj/item/economy/Money/held = src
						usr.wealth -= howmuch
						winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
						var/obj/item/economy/Money/old = new /obj/item/economy/Money(usr)
						var/obj/item/economy/Money/noo = new /obj/item/economy/Money(usr.loc)
						noo.worth = howmuch
						old.worth = usr.wealth
						noo.name = "Wealth x [noo.worth]"
						old.name = "Wealth x [old.worth]"
						del(src)
						return ..()
				Move(usr.loc)
				usr.lastaction = "dropped : [src]"
				addlog("[src]","drop")
				density = initial(density)

				if ( usr:equipped == src )
					usr:equipped = null
					suffix = null


		var	weight

		New(newLoc)
			..(newLoc)
			LoadPointer()

			if ( istype(newLoc,/mob/player) )
				if ( newLoc:weight + weight > MAX_WEIGHT )
					newLoc << "You cannot pick up [src], it's too heavy"
					src.Move(newLoc:loc)

				else
					newLoc:weight += weight


//			spawn(1)
//				CleanUpDrop()


		proc/LoadPointer()
			var icon/pointerIcon = icon(icon,icon_state)

			pointerIcon.Blend('item_pointer.dmi',ICON_OVERLAY)

			mouse_drag_pointer = pointerIcon

		Del()
			if ( !istype(loc,/mob/player) )
				return ..()

			loc:weight -= weight
			return ..()

		Move(newLoc)
			var oldLoc = loc

			if ( istype(newLoc,/mob/player) )
				if ( newLoc:weight + weight > MAX_WEIGHT )
					newLoc << "You cannot pick up [src], it's too heavy"
					return 0

			var ret = ..(newLoc)

			if ( !ret )
				return ret

			if ( istype(newLoc,/mob/player) )
				newLoc:weight += weight
			if ( istype(oldLoc,/mob/player) )
				oldLoc:weight -= weight




			return ret



		icon = 'Things.dmi'




		tool

			Hoe
				value = 8
				weight = 6
				icon = 'temp_hoe.dmi'
			Fishing_Rod
				value = 30
				damage = 3
				weight = 4

				icon_state = "Fishing Rod"
			Shovel
				value = 8
				weight = 4
				//icon = 'temp_shovel.dmi'
				icon_state = "Small Shovel"
			Long_Shovel
				value = 8
				weight = 6
				//icon = 'temp_long_shovel.dmi'
				icon_state = "Shovel"
			Hammer
				value = 8
				weight = 5
				//icon = 'temp_hammer.dmi'
				icon_state = "Hammer"
			Harpoon
				value = 10
				weight = 6
				icon_state = "Harpoon"
			Pickaxe
				value = 8
				weight = 6
				icon_state = "Pickaxe"
			Blow_Pipe
				value = 25
				damage = 3
				weight = 6
				icon = 'temp_items.dmi'
				icon_state = "blow pipe"
			Tongs
				value = 25
				damage = 2
				weight = 4
				icon_state = "tongs"
				icon = 'temp_items.dmi'
			Knife
				value = 16
				weight = 4
				icon_state = "Knife"
			Spade
				value = 30
				weight = 4
				icon_state = "Spade"
				icon = 'temp_items.dmi'


			Hatchet
				value = 8
				damage = 6
				weight = 5
				icon_state = "Hatchet"
				MouseDrop(obj/item/misc/over_obj)
					if ( !over_obj || !istype(over_obj,/obj/item/misc) || over_obj.loc != usr )
						return ..()
					if ( usr:getEquipedItem() != src )
						return ..()

					var newItemType

					switch ( over_obj.type )
						if ( /obj/item/misc/Bundle_Of_Twigs )	newItemType = /obj/item/misc/Twig
						if ( /obj/item/misc/Bundle_Of_Branches)	newItemType = /obj/item/misc/Branch
						if ( /obj/item/misc/Bundle_Of_Vines )	newItemType = /obj/item/misc/Vine

					if ( newItemType )
						var obj/newItem = new newItemType(usr.loc)
						newItem.Move(usr)
						newItem = new newItemType(usr.loc)
						newItem.Move(usr)

						usr:CheckIQ(IQ_FIND,over_obj)
						usr << "You split the [over_obj] into 2 [newItem]s."
						usr.lastaction = "split up [over_obj]"
						del over_obj
						return



			Axe
				value = 25
				weight = 6
				icon_state = "Axe"
				damage = 6
			Fishing_Net
				value = 14
				weight = 4
				icon_state = "Fishing Net"
				damage = 2
			Mortar_And_Pedastle
				value = 10
				weight = 4
				icon = 'temp_items.dmi'
				icon_state = "mortar ped"
				damage = 2

		misc
			var
				burnable


			Nails
				value = 12
				//icon = 'temp_nails.dmi'
				icon_state = "Nails"
				weight = 3
			Hook
				value = 20
				icon = 'temp_items.dmi'
				icon_state = "hook"
				weight = 1


			Twig
				value = 0
				icon_state = "Twig"
				burnable = 1
				weight = 1
			Branch
				value = 2
				icon_state = "Branch"
				weight = 2
				burnable = 2
			Rock
				value = 1
				icon_state = "Big Rock"
				weight = 3
			Flint
				value = 2
				icon_state = "Flint"
				weight = 3
			Vine
				value = 1
				icon_state = "Vine"
				weight = 1

			Bundle_Of_Vines
				value = 5
				icon_state = "Vine 2"
				weight = 2
			Bundle_Of_Twigs
				value = 5
				icon_state = "Twigs"
				burnable = 2
				weight = 2
			Bundle_Of_Branches
				value = 7
				icon_state = "Branches"
				weight = 4
				burnable = 4

			Branch_With_Vine
				value = 12
				icon_state = "Branch with Vine"
				weight = 3
			Twig_With_Vine
				value = 6
				icon_state = "Twig with Vine"
				weight = 2
			Sharpened_Rock
				value = 3
				icon_state = "Sharpened Rock"
				weight = 2
			Branch_With_Twine
				value = 18
				icon_state = "Branch with Twine"
				weight = 3


//			Rice
//				icon = 'temp_rice.dmi'
//				weight = 1
			Cotton
				value = 5
				icon = 'temp_cotton.dmi'
				weight = 1
			Twine
				value = 10
				icon = 'temp_items.dmi'
				icon_state = "twine"




			Straw
				value = 6
				icon = 'temp_straw.dmi'
				weight = 1
				burnable = 1

			Earthworm
				value = 4
				icon = 'temp_items.dmi'
				icon_state = "worm"
				weight = 1
			Sand
				value = 1
				//icon_state = "sand"
				icon = 'temp_sand.dmi'
				weight = 3

			Clay
				value = 4
				icon_state = "clay"
				icon = 'temp_clay.dmi'
				weight = 1

			Softened_Clay
				value = 6
				icon_state = "soft clay"
				icon = 'temp_clay.dmi'
				weight = 1

			Brick_Mold
				value = 12
				icon_state = "brick mold"
				icon = 'temp_items.dmi'
				weight = 6


			Mortar
				value = 7
				icon_state = "mortar"
				icon = 'temp_items.dmi'
				weight = 3

			Soft_Clay_Bowl
				value = 8
				icon_state = "soft clay bowl"
				icon = 'temp_items.dmi'
				weight = 4

			Raft
				value = 8
				icon_state = "raft"
				icon = 'temp_items.dmi'
				weight = 15

			Bundle_Of_Straw
				value = 11
				icon_state = "straw bundle"
				//icon = 'temp_icons.dmi'
				icon = 'temp_straw.dmi'
				weight = 2
			Rope
				value = 20
				weight = 5
				icon = 'temp_items.dmi'
				icon_state = "rope"

		container
			bowl
				Clay_Bowl
					value = 10
					name = "Clay Bowl"
					weight = 4
					icon = 'temp_bowl.dmi'

			jar
				Glass_Jar
					value = 18
					name = "Glass Jar"
					weight = 3
					icon = 'temp_jar.dmi'
			vial
				Glass_Vial
					value = 18
					name = "Glass Vial"
					weight = 2
					icon = 'temp_vial.dmi'

