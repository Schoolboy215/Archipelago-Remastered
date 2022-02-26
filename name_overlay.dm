obj/nametmp
obj
	Tmp
	letters
		icon='Letters.dmi'
		layer=MOB_LAYER+99
	proc
		BLOCKOVERLAY(needsblock as num,PY as num)
			if(!PY)
				PY=16
			if(needsblock==1)
				var/block=new/obj/Tmp
				block:icon='Letters.dmi'
				block:icon_state="Block"
				block:pixel_y=PY
				src.overlays+=block
		TEXTOVERLAY(text as text, PY as num, color as text)
			if(PY==null)
				PY=16
			var
				CX
				letters=list()
				OOE=(lentext(text))
			if(OOE%2==0)
				CX+=11-((lentext(text))/2*5)
			else
				CX+=12-((lentext(text))/2*5)
			for(var/a=1, a<lentext(text)+1, a++)
				letters+=copytext(text,a,a+1)
			for(var/X in letters)
				var/obj/letters/O=new/obj/letters
				if(color=="Red")
					O.icon=O.icon-rgb(0,255,255)
				if(color=="Green")
					O.icon=O.icon-rgb(255,0,255)
				if(color=="Blue")
					O.icon=O.icon-rgb(255,255,0)
				if(color=="White")
					O.icon=O.icon-rgb(0,0,0)
				O.icon_state=X
				O.pixel_x=CX
				O.pixel_y=PY
				CX+=6
				src.overlays+=O

mob
	proc
		Overlay_name()
			usr.overlays = new()
			var/obj/nametmp/T = new/obj/nametmp
			T.TEXTOVERLAY("[usr.name]",20,"Red")
			usr.overlays += T