
#define MIXED_GOOD 1
#define MIXED_BAD 2

#define GRIND_TIME 40
#define SHAKE_TIME 60

#define DRINK_TIME 20

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




obj/item/container/vial/proc/DoAlchemyCheck(mob/player/shaker)
	// INSERT ALCHEMY SKILL CODE HERE
	var skill1 = item:skill
	var skill2 = item2:skill

	var itemSkill = ( skill1 * 2 + skill2 ) / 3

	var pSkill = shaker.GetSkill(SKILL_ALCHEMY)

	var chance = 50 + 10 * ( pSkill - itemSkill )

	chance = AdjustChance(chance)

	if ( shaker.isBusy() )
		return

	if (usr:GetSkill(SKILL_ALCHEMY) > 4)
		var/result = input("Would you like the effects of both ingredients to be incorporated into the mix?") as anything in list("Yes","No")
		if (result == "Yes")
			botheff = 1
			gameMessage(usr,"Both ingredients will now take effect on the potion",MESSAGE_ALCHEMY)
		else
			botheff =0
			gameMessage(usr,"The first ingredient will determine the effect of the potion",MESSAGE_ALCHEMY)

	shaker.Public_message("[shaker] starts stiring a [src].",SKILL_ALCHEMY)
	usr.lastaction = "Stirring a potion"

	shaker.setBusy(1)
	sleep(SHAKE_TIME)
	if ( !shaker) 	return
	shaker.setBusy(0)



	if ( prob(chance) )
		identified = 1
	else
		identified = 0
		gameMessage(usr,"You have no idea if the potion is good or not.",SKILL_ALCHEMY)
		usr.lastaction = "Mixed a mysterious potion"

	var XP = itemSkill * 5

	if ( prob(chance) )
		mixed = MIXED_GOOD
		shaker.GiveXP(SKILL_ALCHEMY,XP)
		shaker.CheckIQ(IQ_MAKE,/obj/item/container/vial)
		if ( identified )
			gameMessage(usr,"You create a benefitial potion.",SKILL_ALCHEMY)
			usr.lastaction = "Mixed a good potion"
	else
		mixed = MIXED_BAD
		shaker.GiveXP(SKILL_ALCHEMY,XP*FAILURE_XP_BOOST)
		if ( identified )
			gameMessage(usr,"You overstir and create a mysterious toxin.",SKILL_ALCHEMY)
			usr.lastaction = "Mixed a bad potion"



	return 1

obj/item/container/vial/verb/Shake()
	if ( mixed )
		world.log << "Vial is already mixed"
		return
	if ( !item || !item2 )
		world.log << "Cannot shake non-full vial"
		return


	if ( DoAlchemyCheck(usr) )


		SetName()
		SetIcon()
		SetVerbs()

obj/item/tool/Mortar_And_Pedastle/proc/getGrindChance(obj/item/food/food,mob/player/grinder)
	var pSkill = grinder.GetSkill(SKILL_ALCHEMY)
	var skill = food.CookingSkill

	var chance = 25 + 8 * ( pSkill - skill )
	return AdjustChance(chance)


obj/item/tool/Mortar_And_Pedastle/proc/getGrindXP(obj/item/food/food)
	return food.CookingSkill * 3

obj/item/powder/proc/GetAlchemyEffectType()
	if ( ispath(objType,/obj/item/food/plant/vegetable ) )
		return EFFECT_HEALING
	if ( ispath(objType,/obj/item/food/plant/berry ) )
		return EFFECT_METABOLISM
	if ( ispath(objType,/obj/item/food/plant/spice ) )
		return EFFECT_REGEN
	if ( ispath(objType,/obj/item/food/plant/mushroom ) )
		return EFFECT_SKILL
	if ( ispath(objType,/obj/item/misc/Fresh_Tobacco) )
		return EFFECT_NICORETE
	if ( ispath(objType,/obj/item/misc/Vine) )
		return EFFECT_ANTIDOTE


	world.log << "Bad alchemy ingredient: [src]"
	return EFFECT_HEALING
obj/item/powder/proc/GetBadAlchemyEffectType()
	if ( ispath(objType,/obj/item/food/plant/vegetable ) )
		return EFFECT_HURT
	if ( ispath(objType,/obj/item/food/plant/berry ) )
		return EFFECT_DISEASE
	if ( ispath(objType,/obj/item/food/plant/spice ) )
		return EFFECT_POISON
	if ( ispath(objType,/obj/item/food/plant/mushroom ) )
		return EFFECT_FEVER
	if ( ispath(objType,/obj/item/misc/Fresh_Tobacco) )
		return EFFECT_UBERCRAVE
	if ( ispath(objType,/obj/item/misc/Vine) )
		return EFFECT_PARALYSIS


	world.log << "Bad alchemy ingredient: [src]"
	return EFFECT_HURT

obj/item/powder/proc/GetAlchemyPower()
	if ( ispath(objType,/obj/item/food/plant/vegetable ) )
		return 8
	if ( ispath(objType,/obj/item/food/plant/berry ) )
		return 12
	if ( ispath(objType,/obj/item/food/plant/spice ) )
		return 15
	if ( ispath(objType,/obj/item/food/plant/mushroom ) )
		return 18
	if ( ispath(objType,/obj/item/misc/Fresh_Tobacco ) )
		return 8
	if ( ispath(objType,/obj/item/misc/Vine) )
		return 4
	world.log << "Bad alchemy ingredient: [src]"
	return 6


mob/player/var
	Effect_Type
	Effect2_Type
	Effect_Duration
	Effect2_Duration


mob/player/proc/DrinkPotion(obj/item/powder/ingredient1,obj/item/powder/ingredient2,mixed,botheff)
	// DO SOMETHING HERE
	Public_message("[usr] drinks a potion.",MESSAGE_DRINKING)
	usr.lastaction = "Drank a potion"
	var power = ingredient2.GetAlchemyPower()
	var power2 = ingredient1.GetAlchemyPower()
	var effType
	var effType2
	if ( mixed == MIXED_GOOD )
		effType = ingredient1.GetAlchemyEffectType()
		if (botheff == 1)
			effType2 = ingredient2.GetAlchemyEffectType()
	else
		effType = ingredient1.GetBadAlchemyEffectType()
		if (botheff == 1)
			effType2 = ingredient2.GetBadAlchemyEffectType()

	sleep(DRINK_TIME)


//	world.log << "[src] drinks potion: effType [effType], power [power]"
	var/eff1found = 0
	var/eff2found = 0
	while (!eff1found)
		if ( effType == EFFECT_HEALING )
			gameMessage(src,"You feel much better!")
			health += power
			if ( health > 100 )
				health = 100
			eff1found = 1
			//return
		if ( effType == EFFECT_HURT )
			Public_message("<font color=green>[usr] doubles over in pain.")
			Hurt(power,"dies!")
			eff1found = 1
			//return

		if ( effType == EFFECT_NICORETE )
			var/chance = 33
			if (prob(chance))
				usr.nicotinecraving = -1
				usr << "<font color = green><b>Your nicotine addiction is cured!"
			else
				usr << "<b>Unfortunately you still crave nicotine"
			eff1found = 1
			//return

		if ( effType == EFFECT_UBERCRAVE )
			usr.nicotinecraving = 200
			usr << "<font color = red><b>You crave nicotine more than ever now!!!"
			eff1found = 1
			//return

		if ( EFFECT_ANTIDOTE )
			gameMessage(src,"<font color=green>Any potion(s) effects on you have been cleared")
			Effect_Type = null
			Effect2_Type = null
			eff1found = 1
			Effect_Duration = null
			Effect2_Duration = null
			return ..()

		Effect_Type = effType
		Effect_Duration = round(power / 2)
		eff1found = 1

	while ((!eff2found) && (effType2 <> null))
		if ( effType2 == EFFECT_HEALING )
			gameMessage(src,"You feel much better!")
			health += power2
			if ( health > 100 )
				health = 100
			eff2found = 1
			//return
		if ( effType2 == EFFECT_HURT )
			Public_message("<font color=green>[usr] doubles over in pain.")
			Hurt(power2,"dies!")
			eff2found = 1
			//return

		if ( effType2 == EFFECT_NICORETE )
			var/chance = 33
			if (prob(chance))
				usr.nicotinecraving = -1
				usr << "<font color = green><b>Your nicotine addiction is cured!"
			else
				usr << "<b>Unfortunately you still crave nicotine"
			eff2found = 1
			//return

		if ( effType2 == EFFECT_UBERCRAVE )
			usr.nicotinecraving = 200
			usr << "<font color = red><b>You crave nicotine more than ever now!!!"
			eff2found = 1
			//return

		if ( EFFECT_ANTIDOTE )
			gameMessage(src,"<font color=green>Any potion(s) effects on you have been cleared")
			Effect_Type = null
			Effect2_Type = null
			Effect_Duration = null
			Effect2_Duration = null
			return ..()

		Effect2_Type = effType2
		Effect2_Duration = round(power2 / 2)
		eff2found = 1


	RunEffect()



mob/player/proc/RunEffect()
	if ( Effect_Type)
		if ( !Effect_Type )
			return
		if ( Effect_Duration <= 0 )
			Effect_Type = null
		if (Effect_Type)
			Effect_Duration--
			switch ( Effect_Type )
				if ( EFFECT_METABOLISM )
					gameMessage(src,"<font color=blue>You feel revitalized.")
					addStomach(1)
					addWater(1)
				if ( EFFECT_REGEN )
					gameMessage(src,"<font color=blue>A soothing feeling flows through you.")
					health += 4
					if ( health > 100 )
						health = 100
				if ( EFFECT_DISEASE )
					Public_message(src,"<font color=green>[src] coughs violently.")
					stomach--
					if ( stomach < 0 )
						stomach = 0
					water--
					if ( water < 0 )
						water = 0
				if ( EFFECT_POISON )
					gameMessage(src,"<font color=green>You shiver in agony as poison courses through you.")
					Hurt(5,"dies from poison!")
				if ( EFFECT_FEVER )
					gameMessage(src,"<font color=green>You nearly collapse from the intense fever.")

				if ( EFFECT_PARALYSIS )
					gameMessage(src,"<font color=red>You find yourself unable to move")
					src:setBusy(1)
					sleep(400)
					src:setBusy(0)
					gameMessage(src,"<font color=green>The paralysis has lifted")


	if ( !Effect2_Type )
		return
	if ( Effect2_Duration <= 0 )
		Effect2_Type = null
		return
	Effect2_Duration--
	switch ( Effect2_Type )
		if ( EFFECT_METABOLISM )
			gameMessage(src,"<font color=blue>You feel revitalized.")
			addStomach(1)
			addWater(1)
		if ( EFFECT_REGEN )
			gameMessage(src,"<font color=blue>A soothing feeling flows through you.")
			health += 4
			if ( health > 100 )
				health = 100
		if ( EFFECT_DISEASE )
			Public_message(src,"<font color=green>[src] coughs violently.")
			stomach--
			if ( stomach < 0 )
				stomach = 0
			water--
			if ( water < 0 )
				water = 0
		if ( EFFECT_POISON )
			gameMessage(src,"<font color=green>You shiver in agony as poison courses through you.")
			Hurt(5,"dies from poison!")
		if ( EFFECT_FEVER )
			gameMessage(src,"<font color=green>You nearly collapse from the intense fever.")
			src:setBusy(1)
			sleep(400)
			src:setBusy(0)

		if ( EFFECT_PARALYSIS )
			gameMessage(src,"<font color=red>You find yourself unable to move")
			src:setBusy(1)
			sleep(400)
			src:setBusy(0)
			gameMessage(src,"<font color=green>The paralysis has lifted")

	winset(usr,"mainwindow.healthbar","value = [health]")
	winset(usr,"mainwindow.hungerbar","value = [stomach * 6.5]")
	winset(usr,"mainwindow.thirstbar","value = [water * 6.5]")




obj/item/powder
	weight = 1
	var
		objType
		itemName
		col
		skill
	icon = 'temp_items.dmi'
	icon_state = "powder"

	New(loc,obj/item/food/food)
		if ( !food )
			world.log << "Powder without food"
			return
		objType = food.type
		name = "Ground [initial(food.name)]"
		itemName = initial(food.name)
		value = food.FoodValue

		var newIcon = icon(icon,icon_state)

		color = food.color
		skill = food.CookingSkill
		AdjustIconColor(newIcon,food.color)
		icon = newIcon
		..()
	MouseDrop(obj/item/container/vial/vial)
		if ( !vial || !istype(vial,/obj/item/container/vial) )
			return ..()
		if ( !canCombo(vial) )
			return

		if ( vial.item && vial.item2 )
			usr << "The vial is already full"
			return

		if ( !vial.item )
			vial.item = src
		else if ( !vial.item2 )
			vial.item2 = src

		Move(vial)
		gameMessage(usr,"You pour the [src] into the [vial].",MESSAGE_CONTAINER)
		usr.lastaction = "Added [src] to a vial"
		vial.SetName()
		vial.SetIcon()
		vial.SetVerbs()




obj/item/tool/Mortar_And_Pedastle/proc/Grind(obj/item/food,mob/player/grinder)
	if ( grinder.getEquipedItem() != src )
		return ..()
	if ( !food.canCombo(src) )
		return
	if ( grinder.isBusy() )
		return

	grinder.Public_message("[grinder] starts grinding [food].",MESSAGE_ALCHEMY)
	usr.lastaction = "Grinding [food]"

	grinder.setBusy(1)
	sleep(GRIND_TIME)
	if ( !grinder )	return

	grinder.setBusy(0)
	if ( !food )	return

	var chance = getGrindChance(food,grinder)
	var XP = getGrindXP(food,grinder)

	if ( prob(chance) )

		gameMessage(grinder,"You successfully grind [food] into powder.",MESSAGE_ALCHEMY)
		usr.lastaction = "Ground [food]"
		var obj/item/powder/newPowder = new(grinder.loc,food)
		newPowder.Move(grinder)
		grinder.GiveXP(SKILL_ALCHEMY,XP)
		grinder.CheckIQ(IQ_MAKE,newPowder)
	else
		gameMessage(grinder,"The pedastle slips and you lose the [food].",MESSAGE_ALCHEMY)
		usr.lastaction = "Ruined [food]"
		grinder.GiveXP(SKILL_ALCHEMY,XP*FAILURE_XP_BOOST)

	del food





obj/item/food/plant/MouseDrop(obj/item/tool/Mortar_And_Pedastle/mortar)
	if ( !mortar || !istype(mortar,/obj/item/tool/Mortar_And_Pedastle) )
		return ..()

	mortar.Grind(src,usr)

obj/item/misc/Fresh_Tobacco/MouseDrop(obj/item/tool/Mortar_And_Pedastle/mortar)
	if ( !mortar || !istype(mortar,/obj/item/tool/Mortar_And_Pedastle) )
		return ..()

	mortar.Grind(src,usr)

obj/item/misc/Vine/MouseDrop(obj/item/tool/Mortar_And_Pedastle/mortar)
	if ( !mortar || !istype(mortar,/obj/item/tool/Mortar_And_Pedastle) )
		return ..()

	mortar.Grind(src,usr)