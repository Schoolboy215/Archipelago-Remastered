/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~CIAGARETTE MAKING MODULE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define DRY_XP			10
#define DRY_TIME			40

#define ROLL_XP			10
#define ROLL_TIME			40

obj/item/misc/Fresh_Tobacco
	value = 15
	icon = 'Smoking.dmi'
	icon_state = "Fresh_Tobacco"
	var/CookingSkill = 2
	var/FoodValue = 0
	var/col = "#964B00"

obj/item/misc/Dry_Tobacco
	value = 20
	icon = 'Smoking.dmi'
	icon_state = "Dry_Tobacco"

obj/plant/Tobacco_Plant
	name = "Tobacco Plant"
	icon = 'Smoking.dmi'
	icon_state = "Tobacco_Plant"
	plant_left = 2
	plant_obj = /obj/item/misc/Fresh_Tobacco

obj/item/seed/Tobacco_Seeds
	value = 30
	food_obj = /obj/plant/Tobacco_Plant
	farm_skill = 4




obj/item/misc/Fresh_Tobacco/MouseDrop(obj/Fire/fire)
	if ( !fire || !istype(fire,/obj/Fire) )
		return ..()
	if (usr:GetSkill(SKILL_COOKING) < 4)
		usr << "<font color = red>You need a cooking level of 4 to dry tobacco"
		return ..()
	usr.Public_message("[usr.key] starts drying some fresh tobacco on the fire",MESSAGE_COOKING)
	usr.lastaction = "Drying tobacco"
	src.Move(fire)
	fire.overlays += src
	usr:setBusy(1)
	sleep(DRY_TIME)
	fire.overlays -= src
	var/upper = 5-usr:GetSkill(SKILL_COOKING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_COOKING,usr:GetSkill(SKILL_COOKING)*4)
		new /obj/item/misc/Dry_Tobacco(usr)
		gameMessage(usr,"You successfully dried the tobacco",MESSAGE_COOKING)
		usr.lastaction = "Dried tobacco"
	else
		usr:GiveXP(SKILL_COOKING,2)
		if(prob(20))
			gameMessage(usr,"You accidently burned the tobacco (and didn't breathe the smoke)",MESSAGE_COOKING)
		else
			if ((usr.nicotinecraving == null) || (usr.nicotinecraving == -1))
				gameMessage(usr,"You burned to tobacco and breathed in the smoke! You are now addicted to nicotine!")
				usr.nicotinecraving = 0
			else
				gameMessage(usr,"You burned to tobacco and breathed in the smoke! You got a good nicotine fix out of it")
				usr.nicotinecraving = usr.nicotinecraving - 30
				if (usr.nicotinecraving < 0)
					usr.nicotinecraving = 0
		usr.lastaction = "Ruined tobacco"
	usr:setBusy(0)
	del(src)


obj/item/misc/Dry_Tobacco/MouseDrop(obj/item/misc/Crude_Paper/paper)
	if ( !paper || !istype(paper,/obj/item/misc/Crude_Paper) )
		return ..()
	if (usr:GetSkill(SKILL_CRAFTING) < 5)
		usr << "<font color = red>You need a crafting level of 5 to roll cigarettes"
		return ..()
	usr.Public_message("[usr.key] starts rolling a cigarette",MESSAGE_CRAFTING)
	usr.lastaction = "Rolling a cigarette"
	usr:setBusy(1)
	sleep(DRY_TIME)
	var/upper = 3-usr:GetSkill(SKILL_CRAFTING)
	if (upper < 0)
		upper = 0
	var/chance = rand(0,upper)
	if (chance == 0)
		usr:GiveXP(SKILL_CRAFTING,ROLL_XP)
		new /obj/item/smoking/Cigarette(usr)
		gameMessage(usr,"You roll a cigarette",MESSAGE_CRAFTING)
		usr.lastaction = "Rolled a cigarette"
		del(paper)
	else
		usr:GiveXP(SKILL_CRAFTING,2)
		gameMessage(usr,"You accidently ruin your supplies while making the cigarette",MESSAGE_CRAFTING)
		usr.lastaction = "Ruined a cigarette"
		del(paper)
	usr:setBusy(0)
	del(src)

