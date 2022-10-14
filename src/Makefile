#
# Cibles :
#	jpc : cible standard : crée le Lex courant (privé ou non)
#	disk : crée jpc et le copie dans le HP-71
#	prive : crée une version protégée de JPC Rom
#	libre : crée une version non protégée de JPC Rom
#
# Exemples :
# - Pour privatiser, assembler et envoyer vers le HP-71, faire :
#	make prive disk
# - Pour déprivatiser et assembler seulement, faire :
#	make libre jpc
# - Pour compiler la version courante et l'envoyer sur le HP-71, faire :
#	make disk
# - Pour compiler la version courante seulement, faire :
#	make
#

SENSIBLES =	ad.as		\
		grmain.as 	\
		ka.as		\
		pol.as		\
		shrink.as	\
		sys.as		\
		xcmd.as		\
		xtext.as	\
		xutil.as	\
		pol.as		\
		jpc.as

jpc: obj/ad.ao obj/attn.ao
jpc: obj/blist.ao obj/combarr.ao
jpc: obj/date.ao obj/decomp.ao obj/def.ao obj/des.ao
jpc: obj/desal.ao obj/dir.ao obj/divi.ao obj/drive.ao
jpc: obj/edit.ao obj/endup.ao obj/exit.ao
jpc: obj/fbas.ao obj/fboucle.ao obj/fcomp.ao obj/file.ao obj/find.ao
jpc: obj/fkey.ao obj/format.ao obj/frac.ao
jpc: obj/gline.ao
jpc: obj/gdef.ao obj/gmbas.ao obj/gmmain.ao obj/gmsg.ao obj/gmutil.ao
jpc: obj/gr1.ao obj/gr2.ao obj/gr3.ao obj/grmain.ao
jpc: obj/grtable.ao obj/grtrace.ao obj/grutil.ao
jpc: obj/hms.ao obj/ilmsg.ao obj/jpc.ao obj/jumper.ao
jpc: obj/ka.ao obj/keywait.ao obj/kris.ao
jpc: obj/map.ao obj/marge.ao obj/menu.ao obj/mm.ao obj/msg.ao
jpc: obj/parse.ao obj/pk.ao obj/pol.ao obj/posi.ao obj/print.ao
jpc: obj/replace.ao obj/roman.ao obj/rplc.ao obj/rw.ao
jpc: obj/scan.ao obj/shrink.ao obj/stack.ao obj/struc.ao obj/swap.ao obj/sys.ao
jpc: obj/xaux.ao obj/xbcl.ao obj/xcmd.ao obj/xdec.ao obj/xdsp.ao obj/xgen.ao
jpc: obj/xtext.ao obj/xutil.ao
	link

disk:	jpc
	acp jpc

prive:
	private on $(SENSIBLES)

libre:
	private off $(SENSIBLES)

msg.as:	msg.am
	amg <msg.am >msg.as

obj/ad.ao:	ad.as
	aas -oobj ad
obj/attn.ao:	attn.as
	aas -oobj attn
obj/blist.ao:	blist.as
	aas -oobj blist
obj/combarr.ao:	combarr.as
	aas -oobj combarr
obj/date.ao:	date.as
	aas -oobj date
obj/decomp.ao:	decomp.as
	aas -oobj decomp
obj/def.ao:	def.as
	aas -oobj def
obj/des.ao:	des.as
	aas -oobj des
obj/desal.ao:	desal.as
	aas -oobj desal
obj/divi.ao:	divi.as
	aas -oobj divi
obj/dir.ao:	dir.as
	aas -oobj dir
obj/drive.ao:	drive.as
	aas -oobj drive
obj/edit.ao:	edit.as
	aas -oobj edit
obj/endup.ao:	endup.as
	aas -oobj endup
obj/exit.ao:	exit.as
	aas -oobj exit
obj/fbas.ao:	fbas.as
	aas -oobj fbas
obj/fboucle.ao:	fboucle.as
	aas -oobj fboucle
obj/fcomp.ao:	fcomp.as
	aas -oobj fcomp
obj/file.ao:	file.as
	aas -oobj file
obj/find.ao:	find.as
	aas -oobj find
obj/fkey.ao:	fkey.as
	aas -oobj fkey
obj/format.ao:	format.as
	aas -oobj format
obj/frac.ao:	frac.as
	aas -oobj frac
obj/gline.ao:	gline.as
	aas -oobj gline
obj/hms.ao:	hms.as
	aas -oobj hms
obj/ilmsg.ao:	ilmsg.as
	aas -oobj ilmsg
obj/jpc.ao:	jpc.as
	aas -oobj jpc
obj/jumper.ao:	jumper.as
	aas -oobj jumper
obj/ka.ao:	ka.as
	aas -oobj ka
obj/keywait.ao:	keywait.as
	aas -oobj keywait
obj/kris.ao:	kris.as
	aas -oobj kris
obj/map.ao:	map.as
	aas -oobj map
obj/marge.ao:	marge.as
	aas -oobj marge
obj/menu.ao:	menu.as
	aas -oobj menu
obj/mm.ao:	mm.as
	aas -oobj mm
obj/msg.ao:	msg.as
	aas -oobj msg
obj/parse.ao:	parse.as
	aas -oobj parse
obj/pk.ao:	pk.as
	aas -oobj pk
obj/pol.ao:	pol.as
	aas -oobj pol
obj/posi.ao:	posi.as
	aas -oobj posi
obj/print.ao:	print.as
	aas -oobj print
obj/replace.ao:	replace.as
	aas -oobj replace
obj/roman.ao:	roman.as
	aas -oobj roman
obj/rplc.ao:	rplc.as
	aas -oobj rplc
obj/rw.ao:	rw.as
	aas -oobj rw
obj/scan.ao:	scan.as
	aas -oobj scan
obj/shrink.ao:	shrink.as
	aas -oobj shrink
obj/stack.ao:	stack.as
	aas -oobj stack
obj/struc.ao:	struc.as
	aas -oobj struc
obj/swap.ao:	swap.as
	aas -oobj swap
obj/sys.ao:	sys.as
	aas -oobj sys

#
# Les éditeurs
#

obj/xaux.ao:	xaux.as
	aas -oobj xaux
obj/xbcl.ao:	xbcl.as
	aas -oobj xbcl
obj/xcmd.ao:	xcmd.as
	aas -oobj xcmd
obj/xdec.ao:	xdec.as
	aas -oobj xdec
obj/xdsp.ao:	xdsp.as
	aas -oobj xdsp
obj/xgen.ao:	xgen.as
	aas -oobj xgen
obj/xtext.ao:	xtext.as
	aas -oobj xtext
obj/xutil.ao:	xutil.as
	aas -oobj xutil

#
# Le "module" graphique
# gmxxx.as : module maitre
# grxxx.as : module raster
#

gmsg.as: gmsg.am
	amg <gmsg.am | sed 's/^=MSGTBL/=GRAMSG/' >gmsg.as

obj/gdef.ao:	gdef.as
	aas -oobj gdef
obj/gmbas.ao:	gmbas.as
	aas -oobj gmbas
obj/gmmain.ao:	gmmain.as
	aas -oobj gmmain
obj/gmsg.ao:	gmsg.as
	aas -oobj gmsg
obj/gmutil.ao:	gmutil.as
	aas -oobj gmutil
obj/gr1.ao:	gr1.as
	aas -oobj gr1
obj/gr2.ao:	gr2.as
	aas -oobj gr2
obj/gr3.ao:	gr3.as
	aas -oobj gr3
obj/grmain.ao:	grmain.as
	aas -oobj grmain
obj/grtable.ao:	grtable.as
	aas -oobj grtable
obj/grtrace.ao:	grtrace.as
	aas -oobj grtrace
obj/grutil.ao:	grutil.as
	aas -oobj grutil
