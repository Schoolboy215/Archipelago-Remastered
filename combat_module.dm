#define COMBAT_SWING_TIME	25


obj/item/tool
	var
		damage = 5


mob/DblClick()
	if ( usr == src )
		return ..()



	if ( get_dist(usr,src) > 1 )
		return ..()
	if ( usr:isBusy() )
		return ..()
	if ( src:health <= 0 )
		return ..()

	//if ( usr:isInSameTribe(name) )
		//return ..()

	var obj/item/tool/equip = usr:getEquipedItem()

	var weaponName
	var damage
	if ( equip )
		weaponName = equip.name
		damage = equip.damage
	else
		weaponName = "fist"
		damage = 3

	var targetSkill
	var skill = usr:GetSkill(SKILL_COMBAT)
	if (!(istype(src,/mob/animal)))
		targetSkill = src:GetSkill(SKILL_COMBAT)
	else
		targetSkill = 1

	damage += round(skill/3)

	usr:setBusy(1)

	usr.Public_message("<b>[usr] swings \his [weaponName] at [src]!",MESSAGE_COMBAT)
	addlog("","attack","[src.key]")
	usr.lastaction = "Attacking [src]"

	sleep(COMBAT_SWING_TIME)

	if ( !src )
		usr:setBusy(0)
		return
	if ( !usr )
		return

	var chance = 20 + 10 * skill

	chance -= targetSkill * 3
	chance = AdjustChance(chance)

	if ( prob(chance) )
		usr.Public_message("<b>[usr] hits [src] with \his [weaponName]!",MESSAGE_COMBAT)

		usr:GiveXP(SKILL_COMBAT,5)
		if (!(istype(src,/mob/animal)))
			src:GiveXP(SKILL_COMBAT,1)

		src:Hurt(damage,"has been struck down by [usr]!")
	else
		usr.Public_message("<b>[usr] misses [src]!",MESSAGE_COMBAT)

		usr:GiveXP(SKILL_COMBAT,5 * FAILURE_XP_BOOST)
		if (!(istype(src,/mob/animal)))
			src:GiveXP(SKILL_COMBAT,3)

	sleep(COMBAT_SWING_TIME)
	if ( usr )
		usr:setBusy(0)
