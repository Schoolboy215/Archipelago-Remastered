obj
	var
		value
		cooked
		material

mob/player/verb

	Check_Value(obj/O in usr.contents)
		set category = null
		if (O.type == /obj/item/economy/Money)
			usr << "Wealth's value is already fluid, and cannot be traded for wealth"
		else
			if (O.value == null)
				usr << "That item is worthless"
			else
				usr << "That item is worth [O.value] wealth"


mob/var
	wealth
	account
	amount
	rate
	duration
	elapsed

obj/item/economy/Money
	icon = 'Market.dmi'
	icon_state = "Coins"
	density = 0
	var
		worth

obj/market
	icon = 'Market.dmi'
	icon_state = "Crate"
	density = 1

obj/store
	icon = 'Market.dmi'
	icon_state = "stall"
	density = 1

obj/Bank
	icon = 'Market.dmi'
	icon_state = "Bank Window"
	density = 1
	name = "Bank"

turf
	Below_Bank
		icon = 'Market.dmi'
		icon_state = "Below Window"
		density = 0
		name = "Bank"

	Beside_Bank
		icon = 'Market.dmi'
		icon_state = "Beside Window"
		density = 1
		name = "Bank"

	Bank_Roof
		icon = 'Market.dmi'
		icon_state = "Bank Roof"
		density = 1
		name = "Bank"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Item Store~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var/list/basics = new()
obj/store/DblClick()
	..()
	if (get_dist(src,usr) > 1)
		return
	var/choice = alert(usr,"Which store do you want to access?","Store Selection","Basic Goods","Recent Sells","Cancel")
	switch(choice)
		if ("Cancel")
			return
		if ("Basic Goods")
			basics = new()
			basics += new/obj/item/misc/Vine
			basics += new/obj/item/misc/Rock
			basics += new/obj/item/misc/Clay
			basics += new/obj/item/misc/Branch
			basics += new/obj/item/misc/Twig
			winshow(usr,"storewindow")
			winset(usr,"storewindow.grid1","cells=[2]x[basics.len+1]")
			winset(usr,"storewindow.TitleLabel","text= Basic_Goods")
			var/row = 2
			usr << output("<b>Item","grid1:1,1")
			usr << output("<b>Cost","grid1:2,1")
			for(var/k in basics)
				usr << output(k,"grid1:1,[row]")
				usr << output("[k:value *5]","grid1:2,[row]")
				row++

		if ("Recent Sells")
			winshow(usr,"storewindow")
			winset(usr,"storewindow.TitleLabel","text= Recent_Sales")
			while(winget(usr,"storewindow","is-visible"))
				if (winget(usr,"storewindow.TitleLabel","text") == "Recent_Sales")
					winset(usr,"storewindow.grid1","cells=[2]x[recentsales.len+1]")
					winset(usr,"storewindow.TitleLabel","text= Recent_Sales")
					var/row = 2
					usr << output("<b>Item","grid1:1,1")
					usr << output("<b>Cost","grid1:2,1")
					for(var/k in recentsales)
						usr << output(k,"grid1:1,[row]")
						usr << output("[k:value *5]","grid1:2,[row]")
						row++
				sleep(REFRESH_TIME)


obj/DblClick()
	if (src.loc == null)
		if ((src:weight + usr:weight <= 100) && (src.value*5 < usr.wealth))
			var/result = alert(usr,"Do you want to buy this item for [src.value*5]?","Confirmation","Yes","No")
			if (result == "No")
				return
			else
				if (winget(usr,"storewindow.TitleLabel","text") == "Recent_Sales")
					usr.contents += src
					usr:weight += src:weight
					Remove_Wealth(src.value*5)
					usr.lastaction = "purchased [src] in store"
					recentsales -= src
				if (winget(usr,"storewindow.TitleLabel","text") == "Basic_Goods")
					usr.contents += new src:type
					usr:weight += src:weight
					Remove_Wealth(src.value*5)
					usr.lastaction = "purchased [src] in store"

		else
			if (src:weight + usr:weight > 100)
				alert(usr,"You don't have enough room to buy that")
			else
				alert(usr,"You need more cash")
			return
	..()




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Recent Sales~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc
	Add_RecentItem(obj/ite)
		var/list/buffer = recentsales
		recentsales = new()
		var/obj/temp= new ite.type
		temp:icon = ite:icon
		temp:icon_state = ite:icon_state
		temp:name = ite:name
		if (istype(ite,/obj/item/tool))
			temp:material = ite:material
		if (istype(ite,/obj/item/food))
			temp:cooked = ite:cooked
			temp:FoodValue = ite:FoodValue
		temp:value = ite.value
		recentsales += temp
		recentsales += buffer
		if (recentsales.len > 50)
			recentsales -= recentsales[51]


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Market Sales Handler~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


obj/item/tool/MouseDrop(obj/market/store)
	var
		show = src.value
	if (!istype(store,/obj/market))
		return ..()
	if (istype(src,/obj/item/tool))
		switch (bonus)
			if (0)
				show += 5
			if (1)
				show += 10
			if (2)
				show += 20
	usr << "You just sold your [src] for [show] wealth!"
	usr.lastaction = "sold [src] for wealth"
	Add_Wealth(show)
	Add_RecentItem(src)
	//usr.wealth += show
	loc:weight -= src.weight
	usr.contents -= src

obj/item/food/MouseDrop(obj/market/store)
	var
		show = src.value
	if (!istype(store,/obj/market))
		return ..()
	/*
	if (istype(src,/obj/item/food))
		if (src.cooked == 1)
			show += show+round(show*(1/3))
		if (src.cooked == 2)
			show = round(show * (3/10))*/

	usr << "You just sold your [src] for [show] wealth!"
	usr.lastaction = "sold [src] for wealth"
	Add_Wealth(show)
	Add_RecentItem(src)
	//usr.wealth += show
	loc:weight -= src.weight
	usr.contents -= src

obj/item/MouseDrop(obj/market/store)
	if (!istype(store,/obj/market))
		return ..()
	if (src.type == /obj/item/economy/Money)
		usr << "You cannot sell wealth"
		return ..()
	usr << "You just sold your [src] for [src.value] wealth!"
	usr.lastaction = "sold [src] for wealth"
	Add_Wealth(src.value)
	Add_RecentItem(src)
	//usr.wealth += src.value
	loc:weight -= src.weight
	usr.contents -= src




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Banking Interface~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



obj/Bank/DblClick()
	usr.lastaction = "accessed bank"
	var/list/choices = new()
	choices += "Check funds"
	choices += "Make a withdrawal"
	choices += "Make a deposit"
	choices += "Purchase a checkbook"
	var result = input("What do you want to do?") as null|anything in choices
	if (result == null)
		return ..()

	if (result == "Check funds")
		if (usr.account == null)
			usr << "<font color = red>You have nothing banked"
			return ..()
		usr << "<font color = green>You have [usr.account] banked"
		usr.lastaction = "checked bank funds"
		choices = new()
		choices += "Yes"
		choices += "No"
		result = input("Do you want a receipt?") as anything in choices
		if (result == "No")
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		var/obj/item/economy/Receipt/newreceipt = new /obj/item/economy/Receipt(usr)
		newreceipt.name = "Receipt"
		newreceipt.whose = usr.key
		newreceipt.amount = usr.account
		return ..()



	if (result == "Make a withdrawal")
		usr << "<font color = green>You have [usr.account] available"
		result = input("How much do you want to withdraw? (max of [usr.account])") as null|num
		if (result == null)
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		if (result < 0)
			return ..()
		usr.lastaction = "withdrew [result] from account"
		usr.account -= result
		for(var/obj/item/economy/Checkbook/B in usr)
			B.runningtotal -= result
			B.transactions += "Withdrew [result] from account... : Balance = [B.runningtotal]"
		Add_Wealth(result)
		choices = new()
		choices += "Yes"
		choices += "No"
		result = input("Do you want a receipt?") as anything in choices
		if (result == "No")
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		var/obj/item/economy/Receipt/newreceipt = new /obj/item/economy/Receipt(usr)
		newreceipt.name = "Receipt"
		newreceipt.whose = usr.key
		newreceipt.amount = usr.account
		return ..()




	if (result == "Make a deposit")
		usr << "<font color = green>You can deposit up to [usr.wealth]"
		result = input("How much do you want to deposit? (max of [usr.wealth])") as null|num
		if (result == null)
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		if (result < 0)
			return ..()
		if (result > usr.wealth)
			return ..()
		usr.account += result
		usr.lastaction = "deposited [result] to account"
		for(var/obj/item/economy/Checkbook/B in usr)
			B.runningtotal += result
			B.transactions += "Deposited [result] into account... : Balance = [B.runningtotal]"
		Remove_Wealth(result)
		choices = new()
		choices += "Yes"
		choices += "No"
		result = input("Do you want a receipt?") as anything in choices
		if (result == "No")
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		var/obj/item/economy/Receipt/newreceipt = new /obj/item/economy/Receipt(usr)
		newreceipt.name = "Receipt"
		newreceipt.whose = usr.key
		newreceipt.amount = usr.account
		return ..()



	if (result == "Purchase a checkbook")
		var pages
		if (usr.account <= 100)
			usr << "<font color = red>You need at least 100 wealth on account to purchase a checkbook"
			return ..()
		result = input("How many checks do you want your book to contain? (2 checks cost 1 wealth)") as null|num
		if (result == null)
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		if (result < 0)
			return ..()
		pages = result
		choices = new()
		choices += "Wealth from inventory"
		choices += "Taken from account"
		result = input("How do you want to pay for your checkbook?") as null|anything in choices
		if (result == null)
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		if (result == "Wealth from inventory")
			if (round(pages/2) >= usr.wealth)
				pages = round(usr.wealth*2)
				Remove_Wealth(usr.wealth)
			else
				Remove_Wealth(round(pages/2))
		if (result == "Taken from account")
			if (round(pages/2) >= usr.account)
				pages = round(usr.account*2)
				usr.account = 0
			else
				usr.account -= round(pages/2)
		usr.lastaction = "purchased a checkbook"
		var/obj/item/economy/Checkbook/newbook = new /obj/item/economy/Checkbook(usr)
		newbook.remaining = pages
		newbook.whose = usr.key
		newbook.runningtotal = usr.account
		newbook.transactions = new()
		newbook.transactions += "Purchased Checkbook with [newbook.runningtotal] wealth in account"
		newbook.name = "Checkbook ([newbook.remaining] checks left)"

		choices = new()
		choices += "Yes"
		choices += "No"
		result = input("Do you want a receipt?") as anything in choices
		if (result == "No")
			usr << "Thank you for using the Bank of Archipelago!"
			return..()
		var/obj/item/economy/Receipt/newreceipt = new /obj/item/economy/Receipt(usr)
		newreceipt.name = "Receipt"
		newreceipt.whose = usr.key
		newreceipt.amount = usr.account
		return ..()


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Cashing Interface~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



obj/item/economy/Check/MouseDrop(obj/Bank/Bank)
	if (!istype(Bank,/obj/Bank))
		return ..()
	if(src.WhoTo != usr.key)
		usr << src.WhoTo
		usr << usr.key
		usr << "<font color = red>That is not your check to use!"
		return ..()
	var/list/choices = new()
	choices += "Cash it"
	choices += "Deposit it to account"
	var/result = input("What do you want to do with [src.name]?") as anything in choices
	if (result == "Cash it")
		var found = 0
		for(var/mob/M in world)
			if (M.key == src.WhoFrom)
				if (M.account >= src.worth)
					M.account -= src.worth
					Add_Wealth(src.worth)
					usr.lastaction = "Cashed a check"
					found = 1
				else
					usr << "<font color = red><font size = 3>THAT CHECK JUST BOUNCED!!!"
					var obj/item/economy/Bounced_Check/BC = new /obj/item/economy/Bounced_Check(usr)
					BC.worth = src.worth
					BC.WhoFrom = src.WhoFrom
					BC.WhoTo = src.WhoTo
					del(src)
					return ..()


		if (found == 0)
			var savefile/SF = new("saves/[src.WhoFrom]",3)
			var M
			SF >> M
			if (M:account >= src.worth)
				M:account -= src.worth
				Add_Wealth(src.worth)
			else
				usr << "<font color = red><font size = 3>THAT CHECK JUST BOUNCED!!!"
				var obj/item/economy/Bounced_Check/BC = new /obj/item/economy/Bounced_Check(usr)
				BC.worth = src.worth
				BC.WhoFrom = src.WhoFrom
				BC.WhoTo = src.WhoTo
				del(src)
				del(M)
				return ..()
			M:account -= src.worth
			SF << M
			Add_Wealth(src.worth)
			usr.lastaction = "Cashed a check"
			//SF << M
		del(src)
		usr << "Thank you for using the Bank of Archipelago!"
		return ..()


	if (result == "Deposit it to account")
		var found = 0
		for(var/mob/M in world)
			if (M.key == src.WhoFrom)
				if (M.account >= src.worth)
					M.account -= src.worth
					usr.account += src.worth
					usr.lastaction = "Deposited a check"
					for(var/obj/item/economy/Checkbook/B in usr)
						B.runningtotal += src.worth
						B.transactions += "Deposited [result] into account... : Balance = [B.runningtotal]"
					found = 1
					usr << "Thank you for using the Bank of Archipelago!"
					del(src)
					return ..()
				else
					usr << "<font color = red><font size = 3>THAT CHECK JUST BOUNCED!!!"
					var obj/item/economy/Bounced_Check/BC = new /obj/item/economy/Bounced_Check(usr)
					BC.worth = src.worth
					BC.WhoFrom = src.WhoFrom
					BC.WhoTo = src.WhoTo
					del(src)
					return ..()


		if (found == 0)
			var savefile/SF = new("saves/[src.WhoFrom]",3)
			var M
			SF >> M
			if (M:account >= src.worth)
				M:account -= src.worth
				usr.account += src.worth
				usr.lastaction = "Deposited a check"
				for(var/obj/item/economy/Checkbook/B in usr)
					B.runningtotal += src.worth
					B.transactions += "Deposited check called [src.name] worth [src.worth] into account... : Balance = [B.runningtotal]"
				del(src)
			else
				usr << "<font color = red><font size = 3>THAT CHECK JUST BOUNCED!!!"
				var obj/item/economy/Bounced_Check/BC = new /obj/item/economy/Bounced_Check(usr)
				BC.worth = src.worth
				BC.WhoFrom = src.WhoFrom
				BC.WhoTo = src.WhoTo
				del(src)
				del(M)
				return ..()
			M:account -= src.worth
			SF << M
			del(M)
			Add_Wealth(src.worth)
		del(src)
	choices = new()
	choices += "Yes"
	choices += "No"
	result = input("Do you want a receipt?") as anything in choices
	if (result == "No")
		usr << "Thank you for using the Bank of Archipelago!"
		return..()
	var/obj/item/economy/Receipt/newreceipt = new /obj/item/economy/Receipt(usr)
	newreceipt.name = "Receipt"
	newreceipt.whose = usr.key
	newreceipt.amount = usr.account
	return ..()




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~WEALTH TRANSFER PORTION~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



proc/Add_Wealth(amount as num)
	for(var/obj/item/economy/Money/M in usr)
		del(M)
	var/obj/item/economy/Money/noo = new /obj/item/economy/Money(usr)
	usr.wealth += amount
	winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
	noo.worth = usr.wealth
	noo.name = "Wealth x [noo.worth]"
	noo.name = "Wealth x [noo.worth]"

proc/Remove_Wealth(amount as num)
	for(var/obj/item/economy/Money/M in usr)
		del(M)
	if (amount >= usr.wealth)
		usr.wealth = 0
		return ..()
	var/obj/item/economy/Money/noo = new /obj/item/economy/Money(usr)
	usr.wealth -= amount
	winset(usr,"mainwindow.wealthlabel","text = [usr.wealth]")
	noo.worth = usr.wealth
	noo.name = "Wealth x [noo.worth]"
	noo.name = "Wealth x [noo.worth]"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Checkbook Handler~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




obj/item/economy/Checkbook
	icon = 'Market.dmi'
	icon_state = "Checkbook"
	density = 0
	var
		remaining
		whose
		runningtotal
	var/list
		transactions
	verb
		Transaction_History()
			set category = null
			usr.lastaction = "Checked checkbook balance"
			usr << "<font color = blue>----------------------------------------------------------------------------"
			for (var/k=1,k<=transactions.len,k++)
				usr << transactions[k]
				usr << "- - - - - - - - - - - - - - - - - - - - "
			if (runningtotal >= 0)
				usr << "<b>Last known balance is <font color = green>[runningtotal]"
			if (runningtotal < 0)
				usr << "<b>Last known balance is <font color = red>[runningtotal]"
			usr <<  "<font color = blue>----------------------------------------------------------------------------"

		Correct_Balance()
			set category = null
			var/result = input("What is the account's true balance?") as num
			if (result == null)
				return ..()
			runningtotal = result
			usr.lastaction = "Revised checkbook balance"
			transactions += "Manually changed balance to [runningtotal]"

		Examine()
			set category = null
			usr << "That is [whose]'s checkbook."

		Tidy_Transactions()
			set category = null
			transactions = new()
			usr.lastaction = "Organized checkbook"
			transactions += "Shortened transaction list ...:Balance = [runningtotal]"


		Write_Check()
			set category = null
			if (whose != usr.key)
				usr << "<font color = red>You cannot write checks with someone else's checkbook!"
				return ..()
			var
				goingto
				amount
			var/list/choices = new()
			choices += "Choose from list of current players"
			choices += "Manually write name"
			var/result = input("How do you want to choose who the check is for?") as null|anything in choices
			if (result == null)
				return ..()
			if (result == "Choose from list of current players")
				result = input("Who is the check for?") as null|mob in world
				if (result == null)
					return ..()
				goingto = result:key
			if (result == "Manually write name")
				result = input("Who is the check for?") as text|null
				if (result == null)
					return ..()
				goingto = result
			result = input("How much is the check for?") as null|num
			if (result == null)
				return ..()
			amount = result
			result = input("What do you want the check to be called?")
			if (result == null)
				return ..()
			runningtotal -= amount
			transactions += "Check called [result] written to [goingto] for [amount]... : Balance = [runningtotal]"
			var/obj/item/economy/Check/newcheck = new /obj/item/economy/Check(usr)
			newcheck.worth = amount
			newcheck.WhoFrom = usr.key
			newcheck.WhoTo = goingto
			newcheck.name = result
			remaining -= 1
			name = "Checkbook ([remaining] checks left)"
			usr.lastaction = "Wrote a check to [goingto]"
			if (remaining == 0)
				usr << "<font color = red><b>You just used your last check. The book was discarded. Go to a bank to purchase a new book"
				del(src)




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Check Handler~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



obj/item/economy/Check
	icon = 'Market.dmi'
	icon_state = "Check"
	density = 0
	var
		worth
		WhoFrom
		WhoTo
		ToAddress
	verb
		Examine()
			set category = null
			usr << "<font color = blue>This is a check to   : <b>[WhoTo]."
			usr << "<font color = blue>It is from           : <b>[WhoFrom]."
			usr << "<font color = blue>It is filled out for : <b>[worth] <b>wealth."

obj/item/economy/Bounced_Check
	icon = 'Market.dmi'
	name = "BOUNCED CHECK"
	icon_state = "Bounced Check"
	density = 0
	var
		worth
		WhoFrom
		WhoTo
	verb
		Examine()
			set category = null
			usr << "<font color = red>This is a check to   : <b>[WhoTo]."
			usr << "<font color = red>It is from           : <b>[WhoFrom]."
			usr << "<font color = red>It is filled out for : <b>[worth] <b>wealth."



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Misc Handler~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


obj/item/economy/Receipt
	icon = 'Market.dmi'
	icon_state = "Receipt"
	density = 0
	var
		whose
		amount
	verb
		Examine()
			set category = null
			usr << "This is [whose]'s reciept for [amount] wealth"


