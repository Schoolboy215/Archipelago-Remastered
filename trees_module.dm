#define	PLUCK_TIME	30
#define MAX_WOOD 10
#define WOOD_GROWTH_RATE 5
#define CUT_TIME 60

#define HATCHET_XP	2
#define LOGS_XP		5




obj
	Tree
		icon = 'temp_tree.dmi'
		density = 1

		dayFunc = 1
		var
			woodLeft = MAX_WOOD

		DblClick()
			if ( get_dist(usr,src) > 1 )
				return
			if ( usr:isBusy() )
				return
			var obj/item/tool/tool = usr:getEquipedItem()
			if ( !tool  )
				return

			if ( woodLeft <= 0 )
				usr << "This tree has no wood left."
				return

			if ( istype(tool,/obj/item/tool/Hatchet) )
				HatchetCut(usr)
				return
			if ( istype(tool,/obj/item/tool/Axe) )
				AxeCut(usr)
				return


		proc
			HatchetCut(mob/player/owner)
				owner.Public_message("[usr] starts chopping the tree with a hatchet.",MESSAGE_LUMBERJACK)
				usr.lastaction = "chopping a tree"

				owner.setBusy(1)
				sleep(CUT_TIME)
				if ( !owner ) return
				owner.setBusy(0)

				woodLeft -= 1

				var objType

				if ( prob(50) )
					objType = /obj/item/misc/Twig
				else
					objType = /obj/item/misc/Branch

				var obj/newObj = new objType(owner.loc)
				newObj.Move(owner)
				gameMessage(owner,"You find a [newObj].",MESSAGE_LUMBERJACK)
				usr.lastaction = "found : [newObj]"
				owner.CheckIQ(IQ_FIND,/obj/item/tool/Hatchet)


				owner.GiveXP(SKILL_LUMBERJACK,HATCHET_XP)


			AxeCut(mob/player/owner)
				owner.Public_message("[usr] starts chopping the tree with an axe.",MESSAGE_LUMBERJACK)
				usr.lastaction = "chopping a tree"

				owner.setBusy(1)
				sleep(CUT_TIME)
				if ( !owner ) return
				owner.setBusy(0)

				if ( prob(owner.getSuccessRate(/obj/item/material/Logs)) )
					woodLeft -= 2
					var obj/item/material/Logs/logs = new(owner.loc)

					logs.Move(owner)
					gameMessage(owner,"You chop off some logs from the tree.",MESSAGE_LUMBERJACK)
					usr.lastaction = "chopped  : logs"
					owner.CheckIQ(IQ_FIND,logs)
					owner.GiveXP(SKILL_LUMBERJACK,LOGS_XP)
					return
				else
					gameMessage(owner,"You can't manage to chop off any useable firewood.",MESSAGE_LUMBERJACK)
					usr.lastaction = "failed to chop logs"
					owner.GiveXP(SKILL_LUMBERJACK,LOGS_XP*FAILURE_XP_BOOST)

			NewDay()
				woodLeft += WOOD_GROWTH_RATE
				if ( woodLeft > MAX_WOOD )
					woodLeft = MAX_WOOD




		verb
			Pluck()
				set src in view(1)
				if ( usr:isBusy() )
					return

				usr.Public_message("[usr] starts plucking twigs from the tree.",MESSAGE_PLUCKING)
				usr.lastaction = "plucking twigs"

				usr:setBusy(1)
				sleep(PLUCK_TIME)
				if ( !usr ) return
				usr:setBusy(0)

				gameMessage(usr,"You pluck a twig from the tree.",MESSAGE_PLUCKING)
				usr.lastaction = "found : Twig"

				var obj/item/misc/Twig/twig = new(usr.loc)

				twig.Move(usr)
				usr:CheckIQ(IQ_FIND,twig)


