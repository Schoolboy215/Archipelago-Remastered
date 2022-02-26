#define WATER_DRINK_AMOUNT	3
#define MILK_DRINK_AMOUNT	6

#define EFFECT_HEALING		0
#define EFFECT_METABOLISM	1
#define EFFECT_REGEN		2
#define EFFECT_SKILL		3
#define EFFECT_NICORETE		9
#define EFFECT_ANTIDOTE		10

#define EFFECT_HURT			4
#define EFFECT_DISEASE		5
#define EFFECT_POISON		6
#define EFFECT_FEVER		7
#define EFFECT_UBERCRAVE	8
#define EFFECT_PARALYSIS	11

obj/item/food
	var
		effType


//mob/player/verb/CreateBowl()
//	new /obj/item/container/bowl/Clay_Bowl(usr)

//mob/player/verb/CreateRice()
//	new /obj/item/food/plant/vegetable/Rice(usr)


mob/player/proc/Drink(drinkType)
	if ( isWaterFull() )
		usr << "You're already full."
		return 0


	if ( drinkType == CONTENTS_WATER )
		addWater(WATER_DRINK_AMOUNT)
		gameMessage(src, "You drink the water. Refreshing.",MESSAGE_DRINKING)
		usr.lastaction = "drank : water"
	if ( drinkType == CONTENTS_MILK )
		addWater(MILK_DRINK_AMOUNT)
		gameMessage(src, "You drink the milk. Delicious!",MESSAGE_DRINKING)
		usr.lastaction = "drank : milk"
	winset(usr,"mainwindow.thirstbar","value = [water * 6.5]")
	return 1


mob/player/proc/Eat(obj/item/food/food,obj/item/food/seasoning)
	if ( isFoodFull() )
		usr << "You're already full."
		return 0


	if ( !food.cooked )
		usr << "You don't want to eat that raw!"
		return 0
	if ( food.cooked == COOKED_BURNT )
		usr << "That is a terrible idea."
		return 0

	var foodValue = food.FoodValue
	if ( seasoning )
		foodValue += 2

	Public_message("[src] eats the [seasoning?"seasoned ":""][food].")
	usr.lastaction = "ate : [food]"
	addStomach(foodValue)
	winset(usr,"mainwindow.hungerbar","value = [stomach * 6.5]")





/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~POTION ON FOOD~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/



	if (food.effType != null)
		usr << "You detected a slightly odd flavor when you took the first bite"
		if ( food:effType == EFFECT_HEALING )
			gameMessage(src,"You feel much better!")
			health += 10
			if ( health > 100 )
				health = 100
			del food
			del seasoning
			return
		if ( food:effType == EFFECT_HURT )
			Public_message("<font color=green>[usr] doubles over in pain.")
			Hurt(4,"dies!")
			del food
			del seasoning
			return

		if ( food:effType == EFFECT_NICORETE )
			var/chance = 33
			if (prob(chance))
				usr.nicotinecraving = -1
				usr << "<font color = green><b>Your nicotine addiction is cured!"
			else
				usr << "<b>Unfortunately you still crave nicotine"
			del food
			del seasoning
			return

		if ( food:effType == EFFECT_UBERCRAVE )
			usr.nicotinecraving = 200
			usr << "<font color = red><b>You crave nicotine more than ever now!!!"
			del food
			del seasoning
			return

		Effect_Type = food:effType
		Effect_Duration = round(10 / 2)


		RunEffect()


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


	del food
	del seasoning

	return 1

obj/Spring/verb/Drink()
	set src in view(1,usr)
	usr:Drink(CONTENTS_WATER)



obj/item/food/verb/Eat()
	set src in usr.contents
	usr:Eat(src)


proc
	getFoodColor(obj/food)
		if ( istype(food,/obj/item/food) )
			return food:color
		else
			return "Green"
/*		if ( istype(food,/obj/item/food/spice) )
			return "Green"

		switch (food.type)
			if ( /obj/item/food/berry/Blueberry )	return "Blue"
			if ( /obj/item/food/berry/Strawberry )	return "Red"
			if ( /obj/item/food/mushroom/Mushroom )	return "Tan"
			if ( /obj/item/food/vegetable/Corn )	return "Yellow"
			if ( /obj/item/food/vegetable/Potato )	return "Tan"
			else
				world.log << "no color set for [food.type]"
				return "Green" */

	AdjustIconColor(icon/Icon,color,cooked)
//		world.log << "Adjust color called :color = [color]"
		switch (color)
			if ( "Blue" )	Icon.SetIntensity(0,0,1)
			if ( "Red" )	Icon.SetIntensity(1,0,0)
			if ( "Tan" )	Icon.SetIntensity(0.8,0.5,0.2)
			if ( "Green" )	Icon.SetIntensity(0,0.8,0)
			if ( "Yellow" )	Icon.SetIntensity(1,1,0)

		if ( cooked == COOKED_BURNT )
			Icon.SetIntensity(0.4,0.4,0.4)
		if ( cooked == COOKED_GOOD )
			Icon.SetIntensity(0.8,0.8,0.8)




obj/item/food/MouseDrop(over_obj)
	if ( usr:isBusy() )
		return
	if ( src.loc != usr )
		return
	if ( !over_obj )
		return
	if ( get_dist(over_obj,usr) > 1 )
		return
	//if ( src.

	if ( istype(over_obj,/obj/Fire) )
		if ( src.cooked == COOKED_BURNT)
			usr << "<font color = red>That food is already burnt"
			return
		if ( src.cooked == COOKED_GOOD )
			gameMessage(src, "You intentionally burn the [src]",MESSAGE_COOKING)
			src.setCooked(COOKED_BURNT)
			usr.lastaction = "intentionally burned : [src]"
			return
		if ( istype(src,/obj/item/food/plant/vegetable/Rice) )
			usr << "You must cook rice in a bowl."
			return
		usr:CookFood(src,over_obj)
		return

	if ( istype(over_obj,/obj/item/container/bowl) )
		var /obj/item/container/bowl/bowl = over_obj
		if ( istype(src,/obj/item/food/plant/spice))
//			usr << "Adding Spices.."

			if ( bowl.seasoning )
				gameMessage(usr,  "[bowl] already has spices in it.",MESSAGE_CONTAINER)
				return
			bowl.seasoning = src
			Move(bowl)
			gameMessage(usr, "You place the [src] into the [bowl].",MESSAGE_CONTAINER)
			usr.lastaction = "placed [src] in [bowl]"
			return
		else
//			usr << "Adding Food.."

			if ( bowl.item )
				gameMessage(usr,  "[bowl] already has something in it.",MESSAGE_CONTAINER)
				return
			bowl.item = src
			Move(bowl)
			gameMessage(usr,  "You place the [src] into the [bowl].",MESSAGE_CONTAINER)
			usr.lastaction = "placed [src] in [bowl]"
			return



	return ..()

obj/item/food
	var
		//cooked
		col = "Green"

		CookingSkill = 1
		FoodValue = 3



	plant

		vegetable
			weight = 2

			Rice
				value = 15
				icon = 'temp_rice.dmi'
				color = "White"
				CookingSkill = 3
				Eat()
					if ( cooked )
						world.log << "Cooked rice not in bowl." // should not happen

					usr << "You can't eat uncooked rice!"
					return
				FoodValue = 5

			Corn
				value = 9
				icon = 'temp_corn.dmi'
				color = "Yellow"
				CookingSkill = 2


			Potato
				value = 9
				icon = 'temp_potato.dmi'
				color = "Yellow"
		berry
			CookingSkill = 3
			FoodValue = 4
			weight = 1
			Strawberry
				value = 18
				icon = 'temp_strawberry.dmi'
				color = "Red"
			Blueberry
				value = 18
				icon = 'temp_blueberry.dmi'
				color = "Blue"
		spice
			CookingSkill = 4
			FoodValue = 1
			weight = 1
			Thyme
				value = 22
				icon = 'temp_thyme.dmi'
			Mint
				value = 23
				icon = 'temp_mint.dmi'
			Rosemary
				value = 24
				icon = 'temp_rosemary.dmi'
		mushroom
			CookingSkill = 5
			weight = 2
			FoodValue = 5
			Mushroom
				value = 25
				icon = 'temp_mushroom.dmi'
				color = "Yellow"