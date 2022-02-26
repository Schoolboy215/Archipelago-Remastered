#define POUR_TIME			40
#define SNIFF_TIME			10
#define MIXED_GOOD			1


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

obj/item/misc/Vine
	var
		var/CookingSkill = 2
		var/FoodValue = 0

obj/item/container/vial/MouseDrop(obj/item/food/F)
	if ( !F || !istype(F,/obj/item/food) )
		return ..()
	if (usr:GetSkill(SKILL_ALCHEMY) < 3)
		usr << "<font color = red>You need an alchemy level of 3 to put potions on food"
		return ..()
	usr.Public_message("[usr.key] starts pouring a potion onto [F]",MESSAGE_ALCHEMY)
	usr.lastaction = "Adding potion to food"
	usr:setBusy(1)
	sleep(POUR_TIME)
	var/effTypey
	if ( src:mixed == MIXED_GOOD )
		effTypey = src.item:GetAlchemyEffectType()
	else
		effTypey = src.item:GetBadAlchemyEffectType()

	F.effType = effTypey
	usr.lastaction = "Added potion to food"
	gameMessage(usr,"You finished pouring the vial on the food",MESSAGE_ALCHEMY)
	gameMessage(usr,"The first ingredient's effect is now part of the food",MESSAGE_ALCHEMY)
	src.Empty()
	usr:setBusy(0)



obj/item/container/vial/MouseDrop(obj/Fire/F)
	if ( !F || !istype(F,/obj/Fire) )
		return ..()
	if (src.mixed == 2)
		gameMessage(usr,"That is already a bad potion",MESSAGE_ALCHEMY)
		return ..()
	if (usr:GetSkill(SKILL_ALCHEMY) < 4)
		usr << "<font color = red>You need an alchemy level of 4 to intentionally make potions bad"
		return ..()
	usr.Public_message("[usr.key] starts heating a vial over the fire",MESSAGE_ALCHEMY)
	usr.lastaction = "Ruining potion"
	src.Move(F)
	F.overlays += src
	usr:setBusy(1)
	sleep(POUR_TIME)
	F.overlays -= src
	F.Move(loc)
	F.Move(usr.contents)
	src.mixed = 2
	gameMessage(usr,"The potion will now have a negative effect",MESSAGE_ALCHEMY)
	usr.lastaction = "Ruined a potion"
	src.SetName()
	usr:setBusy(0)


obj/item/food/verb/Sniff()
	set src in usr.contents
	usr:setBusy(1)
	usr.Public_message("[usr.key] starts sniffing a [src]",MESSAGE_ALCHEMY)
	usr.lastaction = "Sniffing [src]"
	sleep(SNIFF_TIME)
	if(src.effType != null)
		gameMessage(usr,"You definitely detect an odd odor on the [src]",MESSAGE_ALCHEMY)
	else
		gameMessage(usr,"The [src] smells exactly as you would expect it to",MESSAGE_ALCHEMY)
	usr.lastaction = "Sniffed [src]"
	usr:setBusy(0)