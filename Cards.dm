//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Deck of Cards~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

obj/item/cards/Card
	name = "Card"
	icon = 'Market.dmi'
	var
		deckid
	verb
		Examine()
			set category = null
			usr << "This card's id is <font color = blue><b>[deckid]"

		Gather_Deck()
			set category = null
			var/decks = 0
			for(var/obj/item/cards/Deck/D in usr)
				if (D.deckid == deckid)
					decks ++
					for(var/obj/item/cards/Card/C in usr)
						if (C.deckid == D.deckid)
							D.hasleft += C
							D.howmany ++
							usr.contents -= C
			if (decks == 0)
				var/obj/item/cards/Deck/creating = new /obj/item/cards/Deck
				creating.hasleft = new()
				creating.howmany = 0
				for(var/obj/item/cards/Card/C in usr)
					if (C.deckid == deckid)
						creating.hasleft += C
						creating.howmany ++
						usr.contents -= C
				creating.deckid = deckid
				usr.contents += creating





obj/item/cards/Deck
	icon = 'Market.dmi'
	icon_state = "Deck"
	density = 0
	name = "Deck of Cards"
	var
		howmany
		list/hasleft
		deckid

	verb
		Shuffle()
			set category = null
			howmany = length(hasleft)
			var/list/buffer = new()
			var/list/used = new()
			for(var/k=1,k<=53,k++)
				buffer += null
				used += 0
			var/check
			var/foundspot
			usr.Public_message("[usr.key] has shuffled the deck of cards with id <b>[deckid]",MESSAGE_CARDS)
			for(var/k=1,k<=howmany,k++)
				foundspot = 0
				while (foundspot == 0)
					check = rand(1,howmany)
					if (used[check] == 0)
						buffer[k] = hasleft[check]
						used[check] = 1
						foundspot = 1

			for(var/k=1,k<=howmany,k++)
				hasleft[k] = buffer[k]
			usr.lastaction = "Shuffled cards"


		Examine()
			set category = null
			usr << "This deck's id is <font color = blue><b>[deckid]"
			usr << "It contains [howmany] cards."

		View()
			set category = null
			usr << "<b>Deck Contains [howmany] cards:"
			usr << "-_-_TOP OF DECK_-_-"
			for(var/k in hasleft)
				usr << k
			usr << "-_BOTTOM OF DECK_-"
			usr.Public_message("[usr.key] just looked at the deck of cards with id <b>[deckid]",MESSAGE_CARDS)

		Deal_Face_Down()
			set category = null
			var/number = input("How many cards?") as null|num
			if (number == null)
				return ..()
			var/M = input("Who do you want to deal to?") as null|mob in view(1)
			if (M == null)
				return ..()
			if (number > howmany)
				usr << number
				usr << howmany
				usr << "<font color = red>You don't have enough cards left!"
				return ..()
			for(var/k=1,k <=number,k++)
				var/obj/item/cards/Card/taking = hasleft[1]
				M:contents += taking
				hasleft -= taking
				howmany --
			if (howmany == 0)
				del(src)
			usr.Public_message("[usr.key] just dealt [number] face down cards to [M:key]",MESSAGE_CARDS)
			usr.Public_message("The deck's id was <b>[deckid]",MESSAGE_CARDS)
			usr.lastaction = "Dealt card to [M:key]"

		Deal_Face_Up()
			set category = null
			var/number = input("How many cards?") as null|num
			if (number == null)
				return ..()
			var/M = input("Who do you want to deal to?") as null|mob in view(1)
			if (M == null)
				return ..()
			if (number > howmany)
				usr << number
				usr << howmany
				usr << "<font color = red>You don't have enough cards left!"
				return ..()
			usr.Public_message("[usr.key] just dealt [number] face up cards to [M:key]",MESSAGE_CARDS)
			for(var/k=1,k <=number,k++)
				var/obj/item/cards/Card/taking = hasleft[1]
				usr.Public_message("[taking]",MESSAGE_CARDS)
				M:contents += taking
				hasleft -= taking
				howmany --
			if (howmany == 0)
				del(src)
			usr.Public_message("The deck's id was <b>[deckid]",MESSAGE_CARDS)
			usr.lastaction = "Dealt card to [M:key]"


	proc
		Stock()
			set category = null
			howmany = 52
			hasleft = new()
			deckid = rand(1,1000000)
			var/obj/item/cards/Card/adding = new /obj/item/cards/Card
			for(var/k = 1,k<=4,k++)
				for(var/c = 1,c<=13,c++)
					adding = new /obj/item/cards/Card
					if (c == 1)
						adding.name = "Ace of "
					if ((c>=2) && (c<=10))
						adding.name = "[c] of "
					if (c == 11)
						adding.name = "Jack of "
					if (c == 12)
						adding.name = "Queen of "
					if (c == 13)
						adding.name = "King of "
					if (k == 1)
						adding.name += "Clubs"
						adding.icon_state = "Club"
					if (k == 2)
						adding.name += "Diamonds"
						adding.icon_state = "Diamond"
					if (k == 3)
						adding.name += "Spades"
						adding.icon_state = "Spade"
					if (k == 4)
						adding.name += "Hearts"
						adding.icon_state = "Heart"
					adding.deckid = deckid
					hasleft += adding
					adding = ""