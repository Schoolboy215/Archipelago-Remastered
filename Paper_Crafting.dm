/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~PAPER CRAFTING MODULE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



#define SHRED_XP			8
#define SHRED_TIME			40

#define SOAK_XP			2
#define SOAK_TIME			40

#define POUND_XP			2
#define PUOUND_TIME			40

#define DRY_XP			2
#define DRY_TIME			40

#define CUT_XP			2
#define CUT_TIME			40


obj/item/misc/Shredded_Wood
	icon = 'Paper.dmi'
	icon_state = "Shredded_Wood"
	value = 5
	weight = 3
	density = 0

obj/item/misc/Wood_Pulp
	icon = 'Paper.dmi'
	icon_state = "Pulp"
	value = 7
	weight = 7
	density = 0


obj/item/misc/Pulp_Layer
	icon = 'Paper.dmi'
	icon_state = "Layer"
	value = 8
	weight = 7
	density = 0

obj/item/misc/Crude_Paper
	icon = 'Paper.dmi'
	icon_state = "Crude"
	value = 10
	weight = 5
	density = 0

obj/item/misc/Fine_Paper
	icon = 'Paper.dmi'
	icon_state = "Fine"
	value = 12
	weight = 5
	density = 0
	verb
		Make_Cigarette_Box()
			set category = null
			if (usr:GetSkill(SKILL_CRAFTING) < 5)
				usr << "<font color = red>You need a crafting level of 5 to fold paper that well"
				return ..()
			usr.Public_message("[usr.key] starts making a cigarette box",MESSAGE_CRAFTING)
			usr.lastaction = "Making a cigarette box"
			usr:setBusy(1)
			sleep(SHRED_TIME)
			var/obj/item/smoking/Cigarette_Box/C = new /obj/item/smoking/Cigarette_Box
			if (usr:hasItems(/obj/item/food/plant/berry,1) == 1)
				C.brand = usr.key
				C.icon_state = "Branded"
				C.name = "[C.brand] brand cigarettes"
				//var/b = /obj/item/food/plant/berry
				var/taken
				taken = 0
				for (var/obj/item/food/plant/berry/b in usr.contents)
					taken ++
					if (taken == 1)
						usr.contents -= b
			else
				C.brand = "plain"
			usr.contents += C
			usr:GiveXP(SKILL_CRAFTING,CUT_XP)
			gameMessage(usr,"You successfully made a cigarette box",MESSAGE_CRAFTING)
			usr.lastaction = "Made a cigarette box"
			usr:setBusy(0)
			del(src)


obj/item/misc/Sliced_Paper
	icon = 'Paper.dmi'
	icon_state = "Sliced"
	value = 5
	weight = 5
	density = 0
	verb
		Make_Deck_of_Cards()
			set category = null
			if (usr:hasItems(/obj/item/food/plant/berry,1) == 0)
				usr << "<font color = red>You need a berry to paint the patterns"
				return ..()
			if (usr:GetSkill(SKILL_CRAFTING) < 5)
				usr << "<font color = red>You need a crafting level of 5 to paint that accurately"
				return ..()
			usr.Public_message("[usr.key] starts painting card patterns on a stack of paper",MESSAGE_CRAFTING)
			usr.lastaction = "Painting a deck of cards"
			usr:setBusy(1)
			sleep(SHRED_TIME)
			usr:GiveXP(SKILL_CRAFTING,CUT_XP)
			var/taken = 0
			for (var/obj/item/food/plant/berry/b in usr.contents)
				taken ++
				if (taken == 1)
					usr.contents -= b
			var/upper = 4-usr:GetSkill(SKILL_CRAFTING)
			if (upper < 0)
				upper = 0
			var/chance = rand(0,upper)
			if (chance == 0)
				usr:GiveXP(SKILL_CRAFTING,SHRED_XP)
				gameMessage(usr,"You successfully made a fine deck of cards",MESSAGE_CRAFTING)
				usr.lastaction = "Made a deck of cards"
				var/obj/item/cards/Deck/D = new /obj/item/cards/Deck
				usr.contents += D
				D.Stock()
			else
				usr:GiveXP(SKILL_CRAFTING,2)
				gameMessage(usr,"Your painting was  sloppy, and paper was ruined",MESSAGE_CRAFTING)
				usr.lastaction = "Ruined a deck of cards"
			usr:setBusy(0)
			del(src)

obj/item/misc/Rock/MouseDrop(obj/item/material/Logs/log)
	if ( !log || !istype(log,/obj/item/material/Logs) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to work with wood like that"
		return ..()
	usr.Public_message("[usr.key] starts shredding a log",MESSAGE_CRAFTING)
	usr.lastaction = "Shredding a log"
	usr:setBusy(1)
	sleep(SHRED_TIME)
	var/upper = 4-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_CRAFTING,SHRED_XP)
		new /obj/item/misc/Shredded_Wood(usr)
		gameMessage(usr,"You successfully shred the wood",MESSAGE_CRAFTING)
		usr.lastaction = "Shredded Wood"
	else
		usr:GiveXP(SKILL_CRAFTING,2)
		gameMessage(usr,"You shredded too much and ruined the log",MESSAGE_CRAFTING)
		usr.lastaction = "Ruined a log"

	usr:setBusy(0)
	del(log)


obj/item/misc/Shredded_Wood/MouseDrop(obj/Spring/spring)
	if ( !spring || !istype(spring,/obj/Spring) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to work with wood like that"
		return ..()
	usr.Public_message("[usr.key] starts soaking the shredded wood in the spring",MESSAGE_CRAFTING)
	usr.lastaction = "Soaking shredded wood"
	usr:setBusy(1)
	sleep(SOAK_TIME)
	usr:GiveXP(SKILL_CRAFTING,SOAK_XP)
	new /obj/item/misc/Wood_Pulp(usr)
	gameMessage(usr,"You now have moist wood pulp",MESSAGE_CRAFTING)
	usr.lastaction = "Soaked shredded wood"
	usr:setBusy(0)
	del(src)



obj/item/misc/Rock/MouseDrop(obj/item/misc/Wood_Pulp/pulp)
	if ( !pulp || !istype(pulp,/obj/item/misc/Wood_Pulp) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to work with wood like that"
		return ..()
	usr.Public_message("[usr.key] starts pounding some wood pulp into a layer",MESSAGE_CRAFTING)
	usr.lastaction = "Pounding wood pulp"
	usr:setBusy(1)
	sleep(SHRED_TIME)
	var/upper = 3-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_CRAFTING,POUND_XP)
		new /obj/item/misc/Pulp_Layer(usr)
		gameMessage(usr,"You successfully pound the wet pulp into a thin layer",MESSAGE_CRAFTING)
		usr.lastaction = "Made a layer of wood pulp"
	else
		usr:GiveXP(SKILL_CRAFTING,1)
		gameMessage(usr,"You pounded too much and ruined the pulp",MESSAGE_CRAFTING)
		usr.lastaction = "Ruined wood pulp"
	usr:setBusy(0)
	del(pulp)



obj/item/misc/Pulp_Layer/MouseDrop(obj/Fire/fire)
	if ( !fire || !istype(fire,/obj/Fire) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to do that"
		return ..()
	usr.Public_message("[usr.key] starts drying a layer of wood pulp over the fire",MESSAGE_CRAFTING)
	usr.lastaction = "Drying wood pulp"
	src.Move(fire)
	fire.overlays += src
	usr:setBusy(1)
	fire.overlays -= src
	sleep(DRY_TIME)
	var/upper = 3-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_CRAFTING,DRY_XP)
		new /obj/item/misc/Crude_Paper(usr)
		gameMessage(usr,"You successfully produce a crude sheet of paper",MESSAGE_CRAFTING)
		usr.lastaction = "Dried wood pulp"
	else
		usr:GiveXP(SKILL_CRAFTING,1)
		gameMessage(usr,"You accidently burned up the paper",MESSAGE_CRAFTING)
		usr.lastaction = "Burned wood pulp"
	usr:setBusy(0)
	del(src)


obj/item/tool/Knife/MouseDrop(obj/item/misc/Crude_Paper/paper)
	if ( !paper || !istype(paper,/obj/item/misc/Crude_Paper) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to cut that"
		return ..()
	usr.Public_message("[usr.key] starts cutting a piece of crude paper",MESSAGE_CRAFTING)
	usr.lastaction = "Cutting paper"
	usr:setBusy(1)
	sleep(CUT_TIME)
	var/upper = 2-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_CRAFTING,CUT_XP)
		new /obj/item/misc/Fine_Paper(usr)
		gameMessage(usr,"You successfully cut the crude paper into a sheet of fine paper",MESSAGE_CRAFTING)
		usr.lastaction = "Cut paper"
	else
		usr:GiveXP(SKILL_CRAFTING,1)
		gameMessage(usr,"Your knife slipped and ruined the paper",MESSAGE_CRAFTING)
		usr.lastaction = "Ruined paper"
	usr:setBusy(0)
	del(paper)


obj/item/tool/Knife/MouseDrop(obj/item/misc/Fine_Paper/paper)
	if ( !paper || !istype(paper,/obj/item/misc/Fine_Paper) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 2)
		usr << "<font color = red>You need a crafting level of 2 to cut that"
		return ..()
	usr.Public_message("[usr.key] starts cutting up a piece of fine paper",MESSAGE_CRAFTING)
	usr.lastaction = "Cutting paper"
	usr:setBusy(1)
	sleep(CUT_TIME)
	var/upper = 2-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		new /obj/item/misc/Sliced_Paper(usr)
		gameMessage(usr,"You successfully cut a stack of fine paper slices",MESSAGE_CRAFTING)
		usr.lastaction = "Cut paper"
	else
		usr:GiveXP(SKILL_CRAFTING,1)
		gameMessage(usr,"Your knife slipped and ruined the paper",MESSAGE_CRAFTING)
		usr.lastaction = "Ruined paper"
	usr:setBusy(0)
	del(paper)