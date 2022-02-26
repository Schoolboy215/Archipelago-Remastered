mob
	animal
		var
			health = 0
			list/drops = new()
			tmp/isActing
			lastpos = null

		Move()
			if ( health <= 0 )
				setBusy(1)
				return 0

			if ( isActing )
				return 0
			..()
		proc

			setBusy(busy)
				isActing = busy

			isBusy()
				if ( health <= 0 )
					return 1

				return isActing

			Hurt(amount as num,message as text)
				health -= amount
				if (health <= 0)
					health = 0
					view(src) << "[name] [message]"
					var/kind = pick(drops)
					new kind(src.loc)
					kind = pick(drops)
					new kind(src.loc)
					del(src)
		//DblClick()
		icon = 'animals.dmi'
		monkey
			icon_state = "monkey"
			name = "Monkey"
			drops = list(/obj/item/misc/Vine,/obj/item/misc/Rock,/obj/item/drops/Monkey_Skin)
			name = "monkey"
			var/stomach
			var/busy
			var/hunting
			var/obj/item/food/target
			New()
				stomach = 15
				hunting = 0
				health = 10
				target = null
				walk_rand(src,8)
				busy = 0
				setBusy(0)
				sleep(20)
				src.Check_Loop()
			proc
				Check_Loop()
					spawn(1)
						//while (1)
						sleep(5)
						if ((busy == 0) && (isActing == 0))
							src.Make_Decision()

				Make_Decision()
					if ((stomach < 10) && (hunting == 0))
						hunting = 1

					for(var/mob/player/P in view(src))
						if (get_dist(P,src) < 4)
							busy = 1
							walk_away(src,P,15,3)
							hunting = 0
							target = null
							var/away = 0
							while (away == 0)
								if (isItemTypeInList(/mob/player,view(src)))
									away = 0
								else
									away = 1
								sleep (2)

					if (hunting == 1)
						target = null
						for(var/obj/item/food/F in view(src))
							if (F:cooked <> 2)
								target = F
						if (target <> null)
							hunting = 2
							walk_towards(src,src:target)

					if (hunting <> 2)
						walk_rand(src,8)
					else
						if (target:loc == src:loc)
							Eat_Food(target)
					busy = 0
					src.Check_Loop()
				Eat_Food(what as obj)
					stomach += what:FoodValue
					if (stomach > 15)
						stomach = 15
					target = null
					hunting = 0
					del(what)
					sleep(10)
					if (isBusy())
						walk(src,0)
						setBusy(1)
				HourTick()
					stomach --
					if (stomach <= 0)
						var/kind = pick(drops)
						new kind(src.loc)
						kind = pick(drops)
						new kind(src.loc)
						del(src)

obj
	item
		drops
			Monkey_Skin
				icon = 'animals.dmi'
				icon_state = "monkey_skin"
				value = 50
				weight = 5

admin
	verb
		Make_Monkey()
			set category = "Admin"
			new/mob/animal/monkey(usr.loc)

proc
	Random_Monkey()
		var/howmany = 0
		for(var/mob/animal/monkey/H in world)
			howmany ++
		if (howmany >= 5)
			return ..()
		var/newx
		var/newy
		newx = rand(1,MAPWIDTH)
		newy = rand(1,MAPHEIGHT)
		var/mob/animal/monkey/M = new/mob/animal/monkey(locate(newx,newy,2))
		var/P = null
		var/okspot = 0
		while(okspot == 0)
			P = null
			P = locate(/mob/player) in view(M)
			if (P == null)
				if (!(istype(M:loc,/turf/Grass)))
					var/T = locate(/turf/Grass) in view(M)
					if (T <> null)
						M:loc = T
						okspot = 1
						return ..()
				else
					okspot = 1
					return ..()
			newx = rand(1,MAPWIDTH)
			newy = rand(1,MAPHEIGHT)
			M.loc = locate(newx,newy,2)

