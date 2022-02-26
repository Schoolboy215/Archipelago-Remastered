var/list
	NewTribesList
obj/tribe
	var
		leader = ""
		list
			ranks = list("default")
			members = new()
		memo = ""
	member
		var
			rank = ""
	proc
		show_window()
			winshow(usr,"tribewindow")
			winset(usr,"tribewindow.Title","text = [name]")
			winset(usr,"tribewindow.rankgrid","cells=1x[ranks.len +1]")
			usr << output("<b>Ranks","rankgrid:1,1")
			winset(usr,"tribewindow.membergrid","cells=2x[members.len +1]")
			usr << output("<b>Member","membergrid:1,1")
			usr << output("<b>Rank","membergrid:2,1")
			var/row = 2
			for (var/R in ranks)
				usr << output(R,"rankgrid:1,[row]")
				row ++
			row = 2
			for (var/M in members)
				usr << output(M:name,"membergrid:1,[row]")
				usr << output(M:rank,"membergrid:2,[row]")
				row ++

		manageranks(param as num)
			if (param == 1)
				if (ranks.len == 0)
					usr << "There are no ranks"
				var/result = alert("What do you want to do with the ranks?",
				"Managment","Make list from scratch","Add one","Delete one","Cancel")
				switch(result)
					if ("Cancel")
						return
					if ("Make list from scratch")
						var/answer = alert("WARNING! This will erase all current ranks, and all members will be demoted to the lowest level. Is this ok?","Proceed?","Yes","No")
						if (answer == "No")
							return
						var/leave = 0
						ranks = new()
						alert("You will now start entering the names of ranks. Start with the top rank (below leader), and press enter after each one. Enter a blank when done","Enter list")
						while(leave == 0)
							var/next = input("What do you want the next rank to be?") as text
							if (next == "")
								leave = 1
							else
								ranks += next
						for (var/M in members)
							M:rank = ranks[ranks.len]

					if ("Add one")
						var/what = input("What do you want the rank to be called?")
						var/answer = alert("Where do you want to add it?","Where?","Above another","Below another")
						switch(answer)
							if ("Above another")
								var/which = input("Which one is it going to be above?") as anything in ranks
								var/index = 0
								for(var/k=1,k<=ranks.len,k++)
									if (ranks[k] == which)
										index = k
								ranks += what
								for(var/k=ranks.len,k>index,k--)
									ranks[k] = ranks[k-1]
								ranks[index] = what

							if ("Below another")
								var/which = input("Which one is it going to be below?") as anything in ranks
								var/index = 0
								for(var/k=1,k<=ranks.len,k++)
									if (ranks[k] == which)
										index = k+1
								ranks += what
								for(var/k=ranks.len,k>index,k--)
									ranks[k] = ranks[k-1]
								ranks[index] = what

					if ("Delete one")
						var/answer = alert("WARNING! This will erase a ranks, and all members with that rank will be demoted to the lowest level. Is this ok?","Proceed?","Yes","No")
						if (answer == "No")
							return
						ranks -= input("Which rank do you want to delete?") as anything in ranks
						show_window()
				show_window()

		managemembers(param as num)
			if (param == 1)
				var/result = alert("What do you want to do with your members?",
				"Managment","Add one","Remove one","Change a rank","Cancel")
				switch(result)
					if("Cancel")
						return
					if("Add one")
						var/who = input("What is the player's name?") as null|text
						if (who == null)
							return
						var/what = input("What is [who]'s rank?") as anything in ranks
						var/obj/tribe/member/M = new/obj/tribe/member
						M.name = who
						M.rank = what
						for(var/mob/player/P in world)
							if (P.name == who)
								if (P:tribe <> null)
									alert("That player is already in a tribe")
									return
								P.tribe = usr:tribe
								P:verbs += /mob/player/verb/Tribe_Info
								P:verbs += /mob/player/verb/Tribesay
								P:verbs += /mob/player/verb/Leave_Tribe
								P:verbs -= /mob/player/verb/Create_Tribe
								alert(P,"You were just recruited by [usr] to be in their tribe","Tribe [usr:tribe:name]")

						members += M

					if("Remove one")
						if (members.len == 1)
							alert("You cannot remove yourself. Leave the tribe instead","Error")
							return
						var/who = input("Who do you want to remove from your tribe?") as null|anything in members
						if (who == null)
							return
						if (who:name == usr:key)
							alert("You cannot remove yourself. Leave the tribe instead","Error")
							return
						for(var/mob/player/P in world)
							if (P.name == who:name)
								P.tribe = null
						members -= who

					if("Change a rank")
						var/who = input("Whose rank do you wish to change?") as null|anything in members
						if (who == null)
							return
						var/what = input("What shall their new rank be? (currently [who:rank])") as null|anything in ranks
						who:rank = what
				show_window()

		managememo(param as num)
			if (param == 1)
				var/result = input("What do you want the new memo to be?","New Memo",memo) as null|message
				if (result == null)
					return
				memo = result



mob/player
	var
		tribe = new/obj/tribe
	verb
		Create_Tribe()
			set category = "Tribes"
			if (usr:wealth < 100)
				alert("You need 100 wealth in your inventory to start a tribe")
				return
			var/named = input("What do you want the tribe to be called?") as null|text
			if (named == null)
				return
			var/obj/tribe/T = new/obj/tribe
			T.name = named
			T.leader = usr.key
			var/obj/tribe/member/M = new/obj/tribe/member
			M.name = usr.key
			M.rank = "default"
			T.members += M
			NewTribesList += T
			tribe = T
			verbs -= /mob/player/verb/Create_Tribe
			verbs += /mob/player/verb/Manage_Tribe
			verbs += /mob/player/verb/Tribe_Info
			verbs += /mob/player/verb/Tribesay
			verbs += /mob/player/verb/Leave_Tribe
			Remove_Wealth(100)

		Manage_Tribe()
			set category = "Tribes"
			tribe:show_window()
		Manage_Memo()
			set category = null
			tribe:managememo(1)
			/*winshow(usr,"tribewindow")
			winset(usr,"tribewindow.Title","text = [tribe:name]")
			winset(usr,"tribewindow.rankgrid","cells=1x[tribe:ranks.len +1]")
			usr << output("<b>Ranks","rankgrid:1,1")
			winset(usr,"tribewindow.membergrid","cells=2x[tribe:members.len +1]")
			usr << output("<b>Member","membergrid:1,1")
			usr << output("<b>Rank","membergrid:2,1")
			var/row = 2
			for (var/R in tribe:ranks)
				usr << output(R,"rankgrid:1,[row]")
				row ++
			row = 2
			for (var/M in tribe:members)
				usr << output(M:name,"membergrid:1,[row]")
				usr << output(M:rank,"membergrid:2,[row]")
				row ++
			//usr << output("[k:value *5]","grid1:2,[row]")
			*/

		Manage_Ranks()
			set category = null
			tribe:manageranks(1)

		Manage_Members()
			set category = null
			tribe:managemembers(1)



		List_Tribes()
			set category = "Tribes"
			if (NewTribesList.len == 0)
				alert("There are currently no tribes","No Tribes")
				return
			usr << "<font size = 5><b>All Tribes</b>"
			for(var/V in NewTribesList)
				usr << "Name : <b>[V:name]"
				usr << "Leader : <b>[V:leader]"
				usr << "Total Members : <b>[V:members.len]"
				usr << ""
				usr << ""

		Tribe_Info()
			set category = "Tribes"
			usr << "<font size = 5><b>Your Tribe"
			usr << "Name : <b>[tribe:name]"
			usr << "Leader : <b>[tribe:leader]"
			usr << "Memo : <i>[tribe:memo]"
			usr << "Members : <b>[tribe:members:len]"
			usr << "---------------------------------"
			for(var/M in tribe:members)
				usr << "<b>[M:name]</b> : [M:rank]"

		Tribesay(what as text)
			set category = "Tribes"
			if (tribe == null)
				alert("You are not in a tribe","No tribe")
				return
			for(var/mob/player/P in world)
				if (P.tribe == tribe)
					P << "(Tribe)<font color = green>[key]:<font color = black>[what]"

		Leave_Tribe()
			set category = "Tribes"
			if (tribe:leader == usr:key)
				if (alert("Are you sure you want to delete your tribe?","Delete Tribe?","Yes","No") == "No")
					return
				for(var/mob/player/P in world)
					if ((P:tribe == usr:tribe) && (P <> usr))
						P:tribe = null
						P:verbs -= /mob/player/verb/Tribe_Info
						P:verbs -= /mob/player/verb/Tribesay
						P:verbs -= /mob/player/verb/Manage_Tribe
						P:verbs -= /mob/player/verb/Leave_Tribe
						P:verbs += /mob/player/verb/Create_Tribe
						alert(P,"Your tribe was just deleted","Tribe Deleted")
				verbs -= /mob/player/verb/Tribe_Info
				verbs -= /mob/player/verb/Tribesay
				verbs -= /mob/player/verb/Manage_Tribe
				verbs -= /mob/player/verb/Leave_Tribe
				verbs += /mob/player/verb/Create_Tribe
				NewTribesList -= tribe
				tribe = null
			else
				if (alert("Are you sure you want to leave your tribe?","Are you sure?","Yes","No") == "No")
					return
				for(var/M in tribe:members)
					if (M:name == usr:key)
						tribe:members -= M
						tribe = null
						verbs -= /mob/player/verb/Tribe_Info
						verbs -= /mob/player/verb/Tribesay
						verbs -= /mob/player/verb/Manage_Tribe
						verbs -= /mob/player/verb/Leave_Tribe
						verbs += /mob/player/verb/Create_Tribe

admin
	verb
		Clear_All_Tribes()
			set category = "Admin"
			if (usr.admintype < 5)
				alert(usr,"You cannot do that unless you own the game")
				return ..()
			if (alert("Are you sure you want to erase all tribes?","Question","Yes","No") == "Yes")
				usr << "<font color = red> Just deleted [NewTribesList.len] tribes"
				NewTribesList = new()

		Delete_A_Tribe()
			set category = "Admin"
			if (usr.admintype < 5)
				alert(usr,"You cannot do that unless you own the game")
				return ..()
			var/which = input("Which tribe?","Which") as null|anything in NewTribesList
			if (which == null)
				return
			if (alert("Are you sure you want to erase this tribe?","Question","Yes","No") == "Yes")
				for(var/mob/player/P in world)
					if (P:tribe == which)
						alert("You cannot delete that tribe because there is a member online")
						return
				usr << "<font color = red> Just deleted it"
				NewTribesList = new()
