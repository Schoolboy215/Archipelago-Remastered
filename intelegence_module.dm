


mob/player/var
	list/IQlist = new()

datum/IQtype
	var
		IQtype
		subtype
	proc
		Match(T,S)
			return ( IQtype == T && subtype == S )
	New(T,S)
		IQtype = T
		subtype = S

mob/player/proc/CheckIQ(IQtype,subtype)

	if ( isobj(subtype) )
		subtype = subtype:type

	for ( var/datum/IQtype/IQ in IQlist )
		if ( IQ.Match(IQtype,subtype) )
			return


	src << "<B><font color = green>You are smarter!"
	usr.lastaction = "got smarter"
	var datum/IQtype/newIQ = new(IQtype,subtype)

	IQlist += newIQ

mob/player/proc/GetIQ()
	return round( IQlist.len / 2 )


mob/player/proc/GetIQName()

	switch ( GetIQ() )
		if ( 0 to 5 )		return	"Vegetable"
		if ( 6 to 10 )		return	"Retard"
		if ( 11 to 15 )		return	"Moron"
		if ( 16 to 20 )		return	"Amusing"
		if ( 21 to 25 )		return	"Almost Useful"
		if ( 26 to 30 )		return	"Toilet Brush"
		if ( 31 to 35 )		return	"Small Rodent"
		if ( 36 to 40 )		return	"Seasoned Vermin"
		if ( 41 to 45 )		return	"Limp Balloon"
		if ( 46 to 50 )		return	"Pencil Sharpener"
		if ( 51 to 55 )		return	"Enlightened Goblin"
		if ( 56 to 60 )		return	"Nearly Self-Sufficient Padawan"
		if ( 61 to 65 )		return	"Al-Queda Member"
		if ( 66 to 70 )		return	"Carnival Worker"
		if ( 71 to 75 )		return	"Rookie Survivalist"
		if ( 76 to 80 )		return	"Boot Licker"
		if ( 81 to 85 )		return	"Bus Driver's Apprentice"
		if ( 86 to 90 )		return	"Candied Apple"
		if ( 91 to 95 )		return	"Almost Helen Keller"
		if ( 96 to 100 )		return	"HELEN KELLLLLLERRRRRR"

mob/player/proc/AnnounceRank()

	switch ( GetIQ() )
		if ( 0 to 5 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Vegetable."
		if ( 6 to 10 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Retard."
		if ( 11 to 15 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Moron."
		if ( 16 to 20 )		world <<"<font color=blue><font size=3>[usr] wants to announce that <b>their behavior is amusing."
		if ( 21 to 25 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are <b>almost useful"
		if ( 26 to 30 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Toilet Brush"
		if ( 31 to 35 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Small Rodent."
		if ( 36 to 40 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they have become a <b>Seasoned Vermin."
		if ( 41 to 45 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Limp Balloon."
		if ( 46 to 50 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Pencil Sharpener."
		if ( 51 to 55 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are an <b>Enlightened Goblin!"
		if ( 56 to 60 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Nearly Self-Sufficient Padawan."
		if ( 61 to 65 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are an <b>Al Queda Member."
		if ( 66 to 70 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are finally a <b>Carnival Worker."
		if ( 71 to 75 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Rookie Survivalist."
		if ( 76 to 80 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they love to <b>Lick Boots."
		if ( 81 to 85 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are a <b>Bus Driver's Apprentice."
		if ( 86 to 90 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are proud to be a <b>Candied Apple."
		if ( 91 to 95 )		world <<"<font color=blue><font size=3>[usr] wants to announce that they are <b>almost as awesome as</b> Helen Keller."
		if ( 96 to 100 )	world <<"<font color=blue><font size=3>[usr] wants to announce that they are <b><font size=7>HELLLLLLLLEN KELLLLLLLLLLLLER"
	world << "<font color=blue><font size=3>(Intelligence of [GetIQ()])"


