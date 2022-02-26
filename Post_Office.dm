obj/Post_Office
	icon = 'Postal.dmi'
	icon_state = "Mailbox"
	density = 1

obj/item/postal/Letter
	icon = 'Postal.dmi'
	icon_state = "Letter"
	density = 0
	var
		ToAddress
		FromAddress
	var/Written = ""
	verb
		Who_For()
			set category = null
			var/result = input("Who is this letter for?") as text|null
			if (result == null)
				ToAddress = null
				return ..()
			ToAddress = result

			result = input("What do you want to call the letter?") as text|null
			if (result == null)
				name = "Letter"
				return ..()
			name = result

		Compose_Message()
			set category = null
			var/result = input("What do you want to write in the letter?") as null|message
			if (result == null)
				Written = ""
				return ..()
			Written = result

		Examine()
			set category = null
			if (ToAddress == null)
				usr << "<font color = blue>This is a letter to no one that says:"
			else
				usr << "<font color = blue>This is a letter to [ToAddress],"
				usr << "<font color = blue>from [FromAddress] that says:"
			if (ToAddress == null)
				usr << "Absolutely Nothing!"
			else
				usr << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
				usr << "<b>[Written]"
				usr << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"


obj/item/postal/Package
	icon = 'Postal.dmi'
	icon_state = "Package"
	density = 0
	var
		ToAddress
		FromAddress
	verb
		Open_Up()
			set category = null
			usr.contents += contents
			loc:weight += (2*src:weight)
			del(src)

obj/item/MouseDrop(obj/Post_Office/office)
	if (!istype(office,/obj/Post_Office))
		return ..()
	if (src.type == /obj/item/postal/Letter)
		if (src:ToAddress == null)
			usr << "<font color = red>You need to mark who the letter is for first"
			return ..()
		var/list/choices = new()
		choices += "Yes"
		choices += "No"
		var/result = input("Will you accept the 5 wealth cost to send the letter?") as anything in choices
		if (result == "No")
			return ..()
		if (usr.wealth < 5)
			usr << "<font color = red>You don't have enough wealth in your inventory to cover the cost"
			return ..()
		Remove_Wealth(5)
		src:FromAddress = usr.key
		var savefile/SF = new("saves/Postal",3)
		var M
		SF >> M
		if (M == null)
			M = new /mob
		M:contents += src
		SF << M
		usr << "<font color = green>Letter sent to [src:ToAddress]!"
		del(src)

	if (src.type == /obj/item/economy/Check)
		var/list/choices = new()
		choices += "Yes"
		choices += "No"
		var/result = input("Will you accept the 2 wealth cost to send the check?") as anything in choices
		if (result == "No")
			return ..()
		if (usr.wealth < 2)
			usr << "<font color = red>You don't have enough wealth in your inventory to cover the cost"
			return ..()
		Remove_Wealth(2)
		var savefile/SF = new("saves/Postal",3)
		var M
		SF >> M
		if (M == null)
			M = new /mob
		src:ToAddress = src:WhoTo
		M:contents += src
		SF << M
		usr << "<font color = green>Check sent to [src:ToAddress]!"
		del(src)


	else
		var/W
		if (src.weight == null)
			W = 1
		else
			W = src.weight
		var/list/choices = new()
		choices += "Yes"
		choices += "No"
		var/result = input("Will you accept the [W*3] wealth cost to send this package?") as anything in choices
		if (result == "No")
			return ..()
		if (usr.wealth < (W*3))
			usr << "<font color = red>You don't have enough wealth in your inventory to cover the cost"
			if (usr.account > (W*3))
				result = alert(usr,"You can take the cost out of your bank account. Is that ok?","Confirmation","Yes","No")
				if (result == "No")
					return ..()
				else
					usr.account = usr.account - (W*3)
			else
				return ..()
		else
			Remove_Wealth(W*3)
		result = input("Who is this package going to?") as null|text
		if (result == null)
			return ..()
		var/whofor = result
		result = input("What do you want to call the package?") as null|text
		if (result == null)
			result = "Package"
		if (result == "")
			result = "Package"
		var/obj/item/postal/Package/P = new /obj/item/postal/Package(usr)
		loc:weight -= src.weight
		P:contents += src
		P:weight = src.weight
		P:ToAddress = whofor
		P:name = result
		P:FromAddress = usr.key
		//usr.contents -= src
		var savefile/SF = new("saves/Postal",3)
		var M
		SF >> M
		if (M == null)
			M = new /mob
		M:contents += P
		SF << M
		//del(P)



obj/Post_Office/verb

	Check_Mail()
		set src in oview(1)
		set category = null
		var savefile/SF = new("saves/Postal",3)
		var M
		SF >> M
		usr << " "
		usr << "You have the following items awaiting pickup"
		usr << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
		var/list/forme = new()
		for (var/k in M)
			if (k:ToAddress == usr.key)
				usr << "<b>[k]"
				forme += k
		if (forme.len == 0)
			usr << "<font color = blue>~~~~~~~~~NOTHING~~~~~~~~~~"
		usr << "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

		var/obj/item/result = input("What do you want to pickup?") as null|anything in forme
		if (result == null)
			return ..()
		usr.contents += result
		SF << M

	Purchase_Letter()
		set src in oview(1)
		set category = null
		var/list/choices = new()
		choices += "Yes"
		choices += "No"
		var/result = input("1 letter costs 1 wealth. Is that ok?") as anything in choices
		if (result == "No")
			return ..()
		if (usr.wealth < 1)
			usr << "<font color = red>You're too poor right now"
			return ..()
		Remove_Wealth(1)
		//var/obj/item/postal/Letter/N =
		new /obj/item/postal/Letter(usr)

