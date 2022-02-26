#define COOKING_BASE_SUCCESS_CHANCE	30
#define COOKING_SKILL_PERCENT_BONUS	10
#define CUT_MEAT_SKILL_BONUS	25



obj/item/food/proc/GetXP()
	return CookingSkill * 4


mob/player/proc/getCookingSuccessRate(obj/item/food/food,mod = 0)
	var chance = COOKING_BASE_SUCCESS_CHANCE
	var skill = GetSkill(SKILL_COOKING)





	chance += COOKING_SKILL_PERCENT_BONUS * ( mod + skill - food.CookingSkill )

	if ( istype(food,/obj/item/food/meat) && food:cut )
		chance += CUT_MEAT_SKILL_BONUS

	return AdjustChance(chance)


mob/player/proc/CookBowl(obj/item/container/bowl/bowl,obj/Fire/fire)
	// INSERT COOKING CODE HERE
	if ( isBusy() )
		return
	if ( !bowl.item && !bowl.seasoning )
		world.log << "Cannot cook empty bowl"
		return

	Public_message("[usr] starts cooking the [bowl]",MESSAGE_COOKING)
	usr.lastaction = "cooking : [bowl]"

	bowl.Move(fire)
	fire.overlays += bowl
	sleep(COOK_TIME)

	bowl.Move(fire.loc)
	fire.overlays -= bowl

	if ( !usr )
		return

	bowl.Move(usr.loc)
	bowl.Move(usr)

	var chance
	var xp
	if ( bowl.item )
		chance = getCookingSuccessRate(bowl.item,1)
		xp = bowl.item:GetXP()
	else
		chance = getCookingSuccessRate(bowl.seasoning,1)
		xp = bowl.seasoning:GetXP()

	if ( prob(chance) )
		gameMessage(src, "You succesefully cook the [bowl].",MESSAGE_COOKING)
		usr.lastaction = "cooked : [bowl]"

		GiveXP(SKILL_COOKING,xp)

		if ( bowl.item )
			bowl.item:setCooked(COOKED_GOOD)
			bowl.item:value = bowl.item:value*2.5
		if ( bowl.seasoning )
			bowl.seasoning:setCooked(COOKED_GOOD)
			bowl.seasoning:value = bowl.seasoning:value*2.5

	else
		gameMessage(src, "You burn the [bowl].",MESSAGE_COOKING)
		usr.lastaction = "burned : [bowl]"

		GiveXP(SKILL_COOKING,xp*FAILURE_XP_BOOST)

		if ( bowl.item )
			bowl.item:setCooked(COOKED_BURNT)
			bowl.item:value = 1
		if ( bowl.seasoning )
			bowl.seasoning:setCooked(COOKED_BURNT)
			bowl.seasoning:value = 1


	return 1



mob/player/proc/CookFood(obj/item/food/food,obj/Fire/fire)
	// COOKING CODE HERE

	Public_message("[src] starts cooking [food] over the fire.",MESSAGE_COOKING)
	usr.lastaction = "cooking : [food]"

	food.Move(fire)
	fire.overlays += food

	setBusy(1)
	sleep(COOK_TIME)
	setBusy(0)

	if ( !fire )
		return

	fire.overlays -= food
	food.Move(loc)
	food.Move(src)



	if ( prob(getSuccessRate(food)) )

		if (food.cooked == COOKED_GOOD)
			gameMessage(src, "You burned the [food] on purpose.",MESSAGE_COOKING)
			food.setCooked(COOKED_BURNT)
			food:value = 1
			usr.lastaction = "intentionally burned : [food]"

		if (!food.cooked == COOKED_GOOD)
			gameMessage(src, "You cook the [food].",MESSAGE_COOKING)
			usr.lastaction = "cooked : [food]"

			CheckIQ(IQ_MAKE,food)
			GiveXP(SKILL_COOKING,food.GetXP())
			food.setCooked(COOKED_GOOD)
			food:value = food:value*2

		//food.icon_state = "cooked"
	else


		gameMessage(src, "You burn the [food].",MESSAGE_COOKING)
		usr.lastaction = "burned : [food]"

		GiveXP(SKILL_COOKING,food.GetXP()*FAILURE_XP_BOOST)
		food.setCooked(COOKED_BURNT)
		food:value = 1

		//food.icon_state = "burnt"




obj/item/food/proc/setCooked(C)
	//if ( cooked )
		//return

	var icon/newIcon = icon(initial(icon),initial(icon_state))
	if ( C == COOKED_GOOD )

		//name = "Cooked [src]"
		cooked = COOKED_GOOD
		newIcon.SetIntensity(0.8,0.8,0.8)
	if ( C == COOKED_BURNT )
		//name = "Burnt [src]"
		cooked = COOKED_BURNT
		newIcon.SetIntensity(0.4,0.4,0.4)
	setName()

	icon = newIcon

obj/item/food/proc/setName()
	name = initial(name)

	switch ( cooked )
		if ( COOKED_BURNT) name = "Burnt [name]"
		if ( COOKED_GOOD) name = "Cooked [name]"

obj/item/tool/Knife/MouseDrop(obj/item/food/meat/meat)
	if ( !meat || !istype(meat,/obj/item/food/meat) )
//		world.log << "isn't meat"
		return ..()
	var equip = usr:getEquipedItem()
	if ( !equip || equip != src  )
//		world.log << "not equipped"
		return
	if ( !canCombo(meat) )
//		world.log << "can't combine"

		return

	if ( meat.cut )
//		world.log << "already cut"
		return

	usr:Public_message("[usr] slices up [meat] with [src].",MESSAGE_COOKING)
	usr.lastaction = "sliced : [meat]"
	meat.Cut()


obj/item/food/meat
	color = "Yellow"
	var
		cut
	value = 12

	setCooked(C)
		..(C)
		if ( cut )
			Cut()
	setName()
		var sliced = cut?"Sliced ":""
		name = initial(name)
		switch ( cooked )
			if ( COOKED_BURNT) 	name = "Burnt [sliced][name]"
			if ( COOKED_GOOD) 	name = "Cooked [sliced][name]"
			else				name = "[sliced][name]"


	proc
		Cut()
			cut = 1
			icon = 'temp_sliced_meat.dmi'
			if ( cooked == COOKED_BURNT )
				icon_state = "burnt"
			if ( cooked == COOKED_GOOD )
				icon_state = "cooked"
			setName()


obj/item/food/meat/fish/setCooked(C)
	if ( cooked )
		icon = 'Burnt_Fish.dmi'
		icon_state = initial(icon_state)
		//return

	if ( C == COOKED_GOOD )
		icon = 'cookedfish.dmi'
		icon_state = initial(icon_state)
	if ( C == COOKED_BURNT )
		icon = 'Burnt_Fish.dmi'
		icon_state = initial(icon_state)

	cooked = C
	setName()

	if ( cut )
		Cut()

