overscan:equ 0
; Double Megadistorter by Gunstick   (c) ULM 1990
; we know! it's long, but it works ! And it's from ULM !!!


test		equ	10

parallax	equ	0
parallay	equ	0
bus		equ	10
digitest	equ	10


	pea	start
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

;	dc.w	$c8*4
;	dc.w	138*4
;	dc.w	195*4
;	dc.w	167*4
;	dc.w	197*4
;	dc.w	167*4
	dc.w	255*4
digisound:
;	incbin	"includes\telgraph.dmn"
;	incbin	"includes\jasy75.dmn"
;	incbin	"includes\senn_l1.dmn"
;	incbin	"includes\senn_l2.dmn"
;	incbin	"includes\luna.dmn"
;	incbin	"includes\luna2.dmn"
	incbin	"includes\infinity.dmn"
digiend:
	even

font:
	incbin	"includes\font.bin"
	even
fontend:

kotz:
	dc.l	0
noswreset:
	rts
start:
	move	#$2700,sr
	bsr	waitvbl

	lea	$ffff8240.w,a2
	lea	oldpal,a3

	movem.l (a2),d0-d7
	movem.l d0-d7,(a3)
	movem.l hwpalette,d0-d7
	movem.l d0-d7,(a2)

	lea	$ffff8201.w,a0
	movep.w 0(a0),d0
	lea	screenad1,a2
	move.w	d0,(a2)

	move.l	#screen,d0
	add.l	#255,d0
	and.l	#$ffff00,d0
	lea	screenad2,a2
	move.l	d0,(a2)
	movea.l d0,a2
	ror.l	#8,d0
	movep.w d0,0(a0)

	move.w	#0,-(sp)
	move.l	a2,-(sp)
	move.l	a2,-(sp)
	move.w	#5,-(sp)
;	trap	#14
	lea	12(sp),sp

	move.l	screenad2,d0
	sub.l	#160*6,d0
	move.l	d0,screenadr
;	addi.l	#8*5-64,screenadr

	movea.l screenad2,a0
	move.l	#9999,d0
clear_loop:
	clr.l	(a0)+
	dbra	d0,clear_loop

	movea.l screenad2,a0
;	movem.l graphic,d6-d7
	movem.l black,d6-d7
	move.w	#285,d2
allline:
	ifne overscan
	move.w	#20,d1
	endc
	ifeq overscan
	move.w	#27,d1
	endc

alles:
	move.l	d6,(a0)+
	move.l	d7,(a0)+
	dbra	d1,alles
	ifeq overscan
	addq.l	#6,a0
	endc

	dbra	d2,allline

	pea	message
	move.w	#9,-(sp)
;	trap	#1
	addq.w	#6,sp

	bsr	psginit

	lea	oldres,a0
	move.b	$ffff8260.w,(a0)
	bsr	waitvbl
	move.b	#0,$ffff8260.w

	move.b	#18,$fffffc02.w
	bsr	waitvbl
	move.b	#26,$fffffc02.w

	move.l	usp,a0
	move.l	a0,savusp
	bsr	screen2
	move.l	savusp,a0
	move.l	a0,usp

	move.b	#20,$fffffc02.w
	bsr.s	waitvbl
	move.b	#8,$fffffc02.w

	bsr.s	waitvbl
	move.b	#0,$ffff820a.w
	bsr.s	waitvbl
	move.b	#2,$ffff820a.w
	move.b	oldres,$ffff8260.w
	lea	$ffff8201.w,a0
	moveq	#0,d0
	move.w	screenad1,d0
	movep.w d0,0(a0)
	lsl.l	#8,d0

	move.w	#0,-(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
;	trap	#14
	lea	12(sp),sp

	bsr.s	psginit

	lea	oldpal,a0
	lea	$ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)

	bsr.s	waitvbl
	move	#$2300,sr

	rts
savusp:	ds.l	1

waitvbl:

	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	no_vbl

	rts

psginit:
	lea	psginittab,a0
nextinit:
	move.b	(a0)+,d0
	cmp.b	#$ff,d0
	beq.s	initend
	move.b	(a0)+,d1
	move.b	d0,$ffff8800.w
	move.b	d1,$ffff8802.w
	bra.s	nextinit
initend:
	rts

	;--------------------------------------------------------

calc_mdist	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d3/d4/d5/d6
	ENDM
do_mdist	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d3/d4/d5,$ffff8250.w	;mdist
;	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w	;mdist
;	dcb	$4e71,4
	ENDM
	

calc_mdist2	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d4/d5/d6/a2
	ENDM
do_mdist2	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d4/d5/d6,$ffff8250.w	;mdist
;	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	a2,$ffff825c.w	;mdist
;	dcb	$4e71,4
	ENDM


calc_mdist02	MACRO
	move.w	(a3)+,d6
	sub.w	(a4)+,d6
	movem.l	(a5,d6),d2/d4/d5/d6
	ENDM
do_mdist02	MACRO
	lea	64(a5),a5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d2/d4/d5,$ffff8250.w	;mdist
;	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d6,$ffff825c.w	;mdist
;	dcb	$4e71,4
	ENDM

	
	dcb	$4e71,17-1-11
	moveq	#0,d7
; megadistorter test
;	lea	0(a0,d7),a0
	movem.l	(a0),d4/d5/d6/d7


digi1	MACRO
;	not.w	kotz
;	bne.s	*+4
;	illegal	
	
	ifne	digitest
	moveq	#-1,d6		;~1
	move.b	(a6),d6		;~2
	add.w	d6,d6		;~1
	add.w	(a7,d6),d7	;~4
	endc
	ifeq	digitest
	move.w	#$700,$ffff8240.w
	move.w	#$200,$ffff8240.w
	endc
	andi.w	#$ff*4,d7	;~2
	
	move.l	(a7,d7),d6
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7

	ENDM
	

digi2	MACRO
;	not.w	kotz
;	beq.s	*+4
;	illegal
	
	ifne	digitest
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	endc
	ifeq	digitest
	move.w	#$070,$ffff8240.w
	move.w	#$020,$ffff8240.w
	endc
	andi.w	#$ff*4,d7	;~2
	
	move.l	(a7,d7),d6	;~5
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7

	ENDM
	

screen2:

;free d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 -- -- -- a7    usp
	move	sr,-(sp)
	move	#$2700,sr
	move.l	sp,stack
;	clr.b	lowbyte

	ifeq	bus
	moveq	#57,d0
	lea	endprg,a0
memtest:
	move.l	#-1,(a0)+
	dbf	d0,memtest
	endc
	;prepare digisound
downthere	equ	$600
	move.w	#(256+512/4)-1,d0
	lea	domino,a0
	lea	downthere,a1
prepdigi:
	move.l	(a0),d1
	move.l	(a1),(a0)+
	move.l	d1,(a1)+
	dbf	d0,prepdigi
	lea	downthere+512,a7
	lea	digisound-2,a6
	move.w	(a6)+,d7
	move.l	a6,digiptr		

	;**********************************************************
	;	Distorted scroller by Gunstick
	lea	linebuffbegin,a0
	moveq	#25,d0	;26 lines are scrolled
initdist:
	move.l	#scrolltext,textptr-linebuffbegin(a0)
	move.l	a0,a1
	lea	buffer-linebuffbegin(a1),a1
	move.l	a1,bufptr-linebuffbegin(a0)
	clr.w	bufcnt-linebuffbegin(a0)
	clr.w	shift-linebuffbegin(a0)
	lea	linebuffend-linebuffbegin(a0),a0
	dbf	d0,initdist
	lea	wavetab,a0
	move.l	a0,wavetabptr
	move.l	(a0),a0
	move.l	a0,distwaveptr
	move.l	#disttable,disttableptr
	move.l	#mdistadjust,mdistadjustptr
	move.l	#mdistcurv,mdistcurvptr
	move.l	#mwavetab,mnextcurv
	move.l	mwavetab,mactcurv
	move.l	#scrnadrs,nextscrn
	move.l	#screen-230*20,cpybufdest

;	bra	kaka


lupo:
	move.w	#74,d0
ll2:
	digi1
	dcb	$4e71,512/2-22
	digi2
	dcb	$4e71,512/2-22-3
	dbf	d0,ll2


	cmp.l	#digiend-75,a6
	blo.s	_digiok
	lea	digisound-2,a6
	move.w	(a6)+,d7


_digiok:
	btst	#0,$fffffc00.w
	beq	lupo
	move.l	a6,digiptr
	bra	kaka



	lea	font,a0
	lea	buffer,a1
	moveq	#25,d0		;init all unshiftet linebuffers
testinitbuff:
	move.l	(a0),(a1)+
	move.l	4(a0),(a1)+
	move.l	32*8(a0),(a1)+
	move.l	32*8+4(a0),(a1)+
	move.l	32*8*2(a0),(a1)+
	move.l	32*8*2+4(a0),(a1)+
	move.l	32*8*3(a0),(a1)+
	move.l	32*8*3+4(a0),(a1)+
	move.l	32*8*4(a0),(a1)+
	move.l	32*8*4+4(a0),(a1)+
	move.l	32*8*5(a0),(a1)+
	move.l	32*8*5+4(a0),(a1)+
	move.l	32*8*6(a0),(a1)+
	move.l	32*8*6+4(a0),(a1)+
	move.l	32*8*7(a0),(a1)+
	move.l	32*8*7+4(a0),(a1)+
	move.l	32*8*8(a0),(a1)+
	move.l	32*8*8+4(a0),(a1)+
	move.l	32*8*9(a0),(a1)+
	move.l	32*8*9+4(a0),(a1)+
	move.l	32*8*10(a0),(a1)+
	move.l	32*8*10+4(a0),(a1)+
	move.l	32*8*11(a0),(a1)+
	move.l	32*8*11+4(a0),(a1)+
	move.l	32*8*12(a0),(a1)+
	move.l	32*8*12+4(a0),(a1)+
	move.l	32*8*13(a0),(a1)+
	move.l	32*8*13+4(a0),(a1)+
	move.l	32*8*14(a0),(a1)+
	move.l	32*8*14+4(a0),(a1)+
	move.l	32*8*15(a0),(a1)+
	move.l	32*8*15+4(a0),(a1)+
	move.l	32*8*16(a0),(a1)+
	move.l	32*8*16+4(a0),(a1)+
	move.l	32*8*17(a0),(a1)+
	move.l	32*8*17+4(a0),(a1)+
	move.l	32*8*18(a0),(a1)+
	move.l	32*8*18+4(a0),(a1)+
	move.l	32*8*19(a0),(a1)+
	move.l	32*8*19+4(a0),(a1)+
	move.l	32*8*20(a0),(a1)+
	move.l	32*8*20+4(a0),(a1)+
	move.l	32*8*21(a0),(a1)+
	move.l	32*8*21+4(a0),(a1)+
	move.l	32*8*22(a0),(a1)+
	move.l	32*8*22+4(a0),(a1)+
	move.l	32*8*23(a0),(a1)+
	move.l	32*8*23+4(a0),(a1)+
	move.l	32*8*24(a0),(a1)+
	move.l	32*8*24+4(a0),(a1)+
	move.l	32*8*25(a0),(a1)+
	move.l	32*8*25+4(a0),(a1)+
	addq.l	#8,a0
	lea	linebuffend-linebuffbegin-208(a1),a1
	dbf	d0,testinitbuff
kaka:
	;********************************************************

	lea	screenadr,a2
;	move.b	lowbyte,3(a2)

;	bsr	waitvbl		;lower border

	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
_no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	_no_vbl

	move.w	#4000,d0
firsttopwait:
	dbf	d0,firsttopwait
	;move.b	#0,$ffff820a.w

;ULM Hardware Scrolling PART 1
;THIS PART IS TO BE STARTED BEFORE THE BEGINNING OF THE VBL
;sets screen to adress contained in screenadr+(6 scanlines)

	lea	screenadr,a2	;~12
	moveq	#0,d1		;~4
	move.b	3(a2),d1	;~12
	move.w	d1,d0		;~4
	add.w	d1,d1		;~4
	add.w	d0,d1		;~4
	add.w	d1,d1		;~4
	add.w	d1,d1		;~4    *12 (24 byte per tabentry)
	lea	$ffff8201.w,a1	;~8
	lea	hwscrolldat,a0	;~12
	add.w	d1,a0		;~8
	movep.w 1(a2),d1	;~16
	move.b	2(a2),d1	;~12
	move.b	(a0)+,d0	;~8
	ext.w	d0		;~4
	add.w	d0,d1		;~4
	movep.w d1,0(a1)	;~16
	move.l	a0,tabentry-screenadr(a2)	;~16 save tablepos
;ULM Hardware Scrolling END OF PART 1

	lea	predigi,a6
	lea	mdistgraph,a5
	lea	mdistadjust,a4
	move.l	mdistcurvptr,a3
looop:
;	bsr	waitvbl

	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
__no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	__no_vbl


	movem.l black,d0-d6/a0
	movem.l d0-d6/a0,$ffff8240.w

;blaf	equ	174-55
blaf	equ	174+4
	move.w	#1500-30,d0
opentopwait:
	dbra	d0,opentopwait
	dcb	$4e71,90+122-16-blaf

loop:
	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a6)+,d1				;~3
	movep.l	d1,$ffff8800-512-downthere(a7)		;~7
	endc
	dcb	$4e71,blaf-4-1-20
	move.w	d7,digswitch
	movem.l hwpalette,d2-d7/a1-a2
	move.l	a1,usp
	lea	$ffff8209.w,a1
	moveq	#10,d1
	movea.l tabentry,a0	;get back tablepos
;	move.w	#$007,$ffff8240.w

	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a6)+,d0				;~3
	movep.l	d0,$ffff8800-512-downthere(a7)		;~7
	endc

	move.b	#0,$ffff820a.w	

	not.w	$ffff8240.w

	move.b	#0,$fffffa19.w	;stop timer
	move.b	#244,$fffffa1f.w	;244
asd	equ	7
	move.b	#32,$fffffa07.w
	move.b	#0,$fffffa0b.w	;clr pending
	not.w	$ffff8240.w
	move.b	#2,$ffff820a.w
;ULM Hardware Scrolling PART 2
;THIS PART IS TO BE STARTED BEFORE THE END OF THE VBL
;Sets colors to zero
;Sets screen to screenadr(+6 lines)
;Initializes colors with hwpalette
;Uses : d0-a3


sync:
	move.b	(a1),d0
	beq.s	sync
	sub.w	d0,d1
	lsl.w	d1,d1

	moveq	#5,d0
	nop

	bra	intoall

switchloop: 
;	move.b	#2,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	tst.b	(a0)+
	bne.s	links1
;	move.b	#2,$ffff820a.w
	dcb	$4e71,23		;-4*2
	bra.s	cont1

links1:
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;links1:
;	move.b	#2,$ffff820a.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
cont1:
	dcb	$4e71,28
intoall:
	tst.b	(a0)+
	bne.s	mitte
	dcb	$4e71,6
	bra.s	cont3
mitte:
	move.b	#2,$ffff8260.w
	move.b	#0,$ffff8260.w
cont3:
	move.b	#asd,$fffffa19.w
	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a6)+,d1				;~3
	movep.l	d1,$ffff8800-512-downthere(a7)		;~7
	endc
	dcb	$4e71,28-10
	tst.b	(a0)+
	bne.s	rechts1
	tst.b	(a0)+
	bne.s	rechts2
	dcb	$4e71,6
	bra.s	cont4

rechts1:
	move.b	#0,$ffff820a.w
	addq.w	#1,a0
	dcb	$4e71,3
	bra.s	cont4

rechts2:
	dcb	$4e71,4
	move.b	#0,$ffff820a.w
cont4:
	move.b	#2,$ffff820a.w
	dbra	d0,switchloop
;	move.b	#2,$ffff820a.w
;HERE WE ARE SYNCHRON
;These lines are to be used if the screen uses left border

	move.l	usp,a1	;get back this color
	dcb	$4e71,3
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l d2-d4,$ffff8240.w
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	movem.l d5-d7/a1-a2,12+$ffff8240.w
	;**********************************************************
	;	Distorted scroller by Gunstick
	;INITIALISATIONS
	;***** Calc next screenadress ****

	;free: d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 -- -- -- -- a7    usp
	lea	nextscrn,a2	;~12
	move.l	(a2),a0		;~20
	move.l	(a0)+,d0		;~12
	bne	scrnok			;~12
	lea	scrnadrs-nextscrn(a2),a0		;~12
	move.l	(a0)+,d0		;~12
;	move.l	#screen-(20*230)+160*6,cpybufdest-nextscrn(a2);~24
	dcb	$4e71,6
_scrnok:
	move.l	d0,logbase-nextscrn(a2)		;~20
	move.l	a0,(a2)		;~20


	;do some hardwarebouncing
	move.l	hwbounceptr-nextscrn(a2),a0		;~20
	move.w	(a0)+,d1		;~8
	cmpi.w	#-1,d1
	bne.s	hwbounceok		;~8
	lea	hwbouncetab-nextscrn(a2),a0		;~8
	move.w	(a0)+,d1		;~8
_hwbounceok:
	move.l	a0,hwbounceptr-nextscrn(a2)		;~16
	ext.l	d1			;~4
	add.l	d1,d0			;~8
	ifne	bus
	move.l	d0,screenadr-nextscrn(a2);~16
	endc
	ifeq	bus
 	dcb	$4e71,4
	endc

	;free: d0-a7/usp


	addq.l	#4,a6	;no digi this line
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont6
scrnok:
	dcb	$4e71,3-1+6
	bra 	_scrnok			;~12

hwbounceok:
	dcb	$4e71,0
	bra	_hwbounceok			;~12
cont6:
	dcb	$4e71,5-2
	do_mdist

	;***** Do the 8 following distorter entrys **** 
	;; first copy the wave to the disttable
	
;Registerdefs: take care of the order. Modify also the addx.l !!!!
d_0	equr	d0
d_1	equr	d1
d_2	equr	d2
d_3	equr	d3

a_0	equr	a0
a_1	equr	a1
a_2	equr	a2

distspeed 	equ	5
disthigh	equ	20
;copy (disthigh-distspeed)/2 registers
	movem.l	disttable+distspeed*2,d_0/d_1/d_2/d_3/a_0/a_1/a_2	;copy disttab
	movem.l	d_0/d_1/d_2/d_3/a_0/a_1/a_2,disttable
	

	move.l	disttable+distspeed*2+7*4,disttable+7*4
	dcb	$4e71,25-5-10

	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a6)+,d6			;~3
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	endc
	calc_mdist	

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,6
	do_mdist
	move.w	digswitch,d7
;	digi2
	move.l	a6,usp			;~1
	move.l	digiptr,a6
	dcb	$4e71,27-4-5-1

	lea	disttable+disthigh*2-distspeed*2,a_1	;position to write new
	move.l	distwaveptr,a_0		;position in the actual wave
	moveq	#distspeed-1,d_0	;read 8
	moveq	#0,d_3
	move.w	distcalc,d_2


distwaveread:
	;free: d4-d5/usp

	dcb	$4e71,25-10-2	;digi
;	digi1	
	move.l	usp,a2			;~1

	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a2)+,d6		;~3
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	endc
	move.l	a2,usp			;~1

	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont
notnextwavetab:			;~12 time adjust
	dcb	$4e71,20
	bra.s	_notnextwavetab	;~12
notendwavetab:			;~12
	bra.s	_notendwavetab	;~12
	
cont:
	move.w	(a_0)+,d_1	;~8
	dcb	$4e71,3-2
	do_mdist2
	
	cmp.w	#128,d_1	;~8
	bne.s	notnextwavetab	;~8
	move.l	wavetabptr,a_2	;~20 next wave to be read
	tst.l	(a_2)		;~12
	bne.s	notendwavetab	;~8
	lea	wavetab,a_2	;~12 reset wavetabptr
	nop
_notendwavetab:
	move.l	(a_2)+,a_0	;~12
	move.w	(a_0)+,d_1	;~12
	move.l	a_2,wavetabptr	;~20
_notnextwavetab:
	add.w	d_1,d_3		;~4
	add.w	d_1,d_2		;~4
	sub.w	16(a_1),d_2	;~16
	move.w	d_1,16(a_1)	;~12
	move.w	d_2,(a_1)+	;~8 write new curve

	dbf	d_0,distwaveread	;~12/16

	;free: d1-d2/d4-d7/a0-a7/usp
;	digi2
	dcb	$4e71,24-10-1-1
	move.l	usp,a2			;~1
	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a2)+,d6			;~3
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	endc
	move.l	a2,usp
	calc_mdist2


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	move.l	a_0,distwaveptr	;~20
	dcb	$4e71,3-2
	do_mdist2
	
	move.w	d_3,distcalc	;~16
scrhigh	equ	20
fontpartlen	equ	(fontend-font)/scrhigh
	lea	disttable+0,a_2 ;~12 scroll begins 18 lines before end of screen
	lea	shift,a_0	;~12 pointer to the shifts
	move.w	#-(scrhigh*fontpartlen),count	;~20 -14400
	
distcalcloop:	;(~12)

	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	move.w	(a_2)+,d_1	;~8
	move.l	a_2,usp
	dcb	$4e71,4
	move.w	(a_0),d_2	;~8	;read shift
	add.w	d_1,d_2		;~4
	bmi	rueckwaerts	;~12
	sub.w	#16,d_2		;~8
	bhs	vorwaerts	;~12
	add.w	#16,d_2		;~8	
	move.w	d_2,(a_0)	;~8	;write back new shift
	moveq	#1,d_2
noshift:
	dcb	$4e71,6-2-3
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	lea	back1(pc),a1	;2
	digi1
	jmp	do_all		;3
do_all:
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	dcb	$4e71,41
	dcb	$4e71,25	;digi
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	jmp	(a1)		;2
back1:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back2(pc),a1	;2
	digi2
	jmp	do_all		;3
back2:
	dcb	$4e71,41-4-2-2
	dbf	d_2,noshift

	bra	indistcalcloop+2
	
indistcalcloop:
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25-22	;digi
	digi1	
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	
	dcb	$4e71,3
	move.l	usp,a_2

	lea	linebuffend-linebuffbegin(a_0),a_0	;~8 next line
	add.w	#fontpartlen,count	;~4
	bne	distcalcloop2	;~12
	bra	enddistcalc

distcalcloop2:	;(~12)

	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	move.w	(a_2)+,d_1	;~8
	move.l	a_2,usp
	dcb	$4e71,4
	move.w	(a_0),d_2	;~8	;read shift
	add.w	d_1,d_2		;~4
	bmi	rueckwaerts2	;~12
	sub.w	#16,d_2		;~8
	bhs	vorwaerts2	;~12
	add.w	#16,d_2		;~8	
	move.w	d_2,(a_0)	;~8	;write back new shift
	moveq	#1,d_2
noshift2:
	dcb	$4e71,6+22
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	dcb	$4e71,41-2-3
	dcb	$4e71,25-22	;digi
	lea	back12(pc),a1	;2
	digi2
	jmp	do_all		;3
back12:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back22(pc),a1	;2
	digi1
	jmp	do_all		;3
back22:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back32(pc),a1	;2
	digi2
	jmp	do_all		;3
back32:
	dcb	$4e71,41-2
	dcb	$4e71,25-22	;digi
	digi1
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	dcb	$4e71,41-2
	bra	indistcalcloop2+2
	
indistcalcloop2:
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25	;digi
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	
	dcb	$4e71,3
	move.l	usp,a_2

	lea	linebuffend-linebuffbegin(a_0),a_0	;~8 next line
	add.w	#fontpartlen,count	;~4
	bne	distcalcloop3	;~12
	bra	enddistcalc

	
distcalcloop3:	;(~12)

	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	move.w	(a_2)+,d_1	;~8
	move.l	a_2,usp
	dcb	$4e71,4
	move.w	(a_0),d_2	;~8	;read shift
	add.w	d_1,d_2		;~4
	bmi	rueckwaerts3	;~12
	sub.w	#16,d_2		;~8
	bhs	vorwaerts3	;~12
	add.w	#16,d_2		;~8	
	move.w	d_2,(a_0)	;~8	;write back new shift
	moveq	#1,d_2
noshift3:
	dcb	$4e71,6-2-3
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	lea	back13(pc),a1	;2
	digi2
	jmp	do_all		;3
back13:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back23(pc),a1	;2
	digi1
	jmp	do_all		;3
back23:
	dcb	$4e71,41-4-2-2
	dbf	d_2,noshift3

	bra	indistcalcloop3+2
	
indistcalcloop3:
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25-22	;digi
	digi2	
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	
	dcb	$4e71,3
	move.l	usp,a_2

	lea	linebuffend-linebuffbegin(a_0),a_0	;~8 next line
	add.w	#fontpartlen,count	;~4
	bne	distcalcloop4	;~12
	bra	enddistcalc
	
	
		
distcalcloop4:	;(~12)

	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	move.w	(a_2)+,d_1	;~8
	move.l	a_2,usp
	dcb	$4e71,4
	move.w	(a_0),d_2	;~8	;read shift
	add.w	d_1,d_2		;~4
	bmi	rueckwaerts4	;~12
	sub.w	#16,d_2		;~8
	bhs	vorwaerts4	;~12
	add.w	#16,d_2		;~8	
	move.w	d_2,(a_0)	;~8	;write back new shift
	moveq	#1,d_2
noshift4:
	dcb	$4e71,6+22
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	dcb	$4e71,41-2-3
	dcb	$4e71,25-22	;digi
	lea	back14(pc),a1	;2
	digi1
	jmp	do_all		;3
back14:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back24(pc),a1	;2
	digi2
	jmp	do_all		;3
back24:
	dcb	$4e71,41-2-2-3
	dcb	$4e71,25-22	;digi
	lea	back34(pc),a1	;2
	digi1
	jmp	do_all		;3
back34:
	dcb	$4e71,41-2
	dcb	$4e71,25-22	;digi
	digi2
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	dcb	$4e71,41-2
	bra	indistcalcloop4+2

indistcalcloop4:
	;free: d0/d3-d7/a1-a2/a4-a7/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25	;digi
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	
	dcb	$4e71,3
	move.l	usp,a_2

	lea	linebuffend-linebuffbegin(a_0),a_0	;~8 next line
	add.w	#fontpartlen,count	;~4
	bne	distcalcloop	;~12
	bra	enddistcalc
	
	

	dcb	$4e71,3
enddistcalc:
	dcb	$4e71,41-20+5-3


	;free: d0-a7/usp  
	dcb	$4e71,25-22	;digi
	digi1
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	move.b	#2,$ffff820a.w

;ULM Hardware Scrolling PART 1
;THIS PART IS TO BE STARTED BEFORE THE BEGINNING OF THE VBL
;sets screen to adress contained in screenadr+(6 scanlines)

	lea	screenadr,a_2	;~12
	moveq	#0,d_1		;~4
	move.b	3(a_2),d_1	;~12
	move.w	d_1,d_0		;~4
	add.w	d_1,d_1		;~4
	add.w	d_0,d_1		;~4
	add.w	d_1,d_1		;~4
	add.w	d_1,d_1		;~4    *12 (24 byte per tabentry)
	lea	$ffff8201.w,a_1	;~8
	lea	hwscrolldat-screenadr(a_2),a_0	;~8
	add.w	d_1,a_0		;~8
	movep.w 1(a_2),d_1	;~16
	move.b	2(a_2),d_1	;~12
	move.b	(a_0)+,d_0	;~8
	ext.w	d_0		;~4
	add.w	d_0,d_1		;~4
	movep.w d_1,0(a_1)	;~16
	move.l	a_0,tabentry-screenadr(a_2)	;~16 save tablepos
;ULM Hardware Scrolling END OF PART 1



;	dcb	$4e71,41-4-33
	dcb	$4e71,25	;digi
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
;	move.b	#$7,$ffff8240.w
;	move.b	#0,$ffff8240.w
	dcb	$4e71,8-2
	do_mdist

	bra	copydistscroll



	;=-| read the new distortions and shift the buffers
	;-> advance this line by one word
vorwaerts:
	move.w	d_2,(a_0)	;~8 write back new shift
	move.l	textptr-shift(a_0),a_1	;~16
	dcb	$4e71,2
	dcb	$4e71,25-22	;digi
	digi1
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont2
nottextend:			;~12
	addq.w	#1,a_1		;~8
	bra	_nottextend	;~12
cont2:
	dcb	$4e71,5-2
	do_mdist

	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		textptr
	;		|
	;UNLIMITED MATRICKS	a bit of C appears somewhere
	;now we have to write a bit of K and C
	nop
	moveq	#0,d_1
	moveq	#0,d_2
	move.b	(a_1),d_1	;~8 previous letter : C 
	move.b	1(a_1),d_2	;~12 act letter	 : K
	tst.b	2(a_1)		;~12 test letter after act : S
	bne.s	nottextend	;~8
	lea	scrolltext,a_1	;~12
	nop
	nop
	nop
_nottextend:
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to K
;	clr.b	d_1		;~4 C
	dcb	$4e71,6-2-2-2
	lsl.w	#3,d_1	;~8
;	clr.b	d_2		;~4 K
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 C
	movem.l	(a_1,d_2),d_1/d_3	;~36 K
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 C
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8

	calc_mdist2

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2



	;buffer gestion
	cmpi.w	#25*4,bufcnt-shift(a_0)	;~16
	blo.s	vorbufok		;~8
	clr.w	bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	subi.l	#25*8,bufptr-shift(a_0)	;~20
	bra.s	vorbufnok		;~12
vorbufok:
	addq.w	#4,bufcnt-shift(a_0)	;~16
	addq.l	#8,bufptr-shift(a_0)	;~16
	dcb	$4e71,9-5
vorbufnok:
	dcb	$4e71,5
	dcb	$4e71,2
	

call_shifter:	
	;write first buffer
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~24
	lea	26*8(a_1),a_1	;~8
	dcb	$4e71,5
	dcb	$4e71,25-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8


	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8
	dcb	$4e71,8-3

	dcb	$4e71,25-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8
	dcb	$4e71,8-3

	dcb	$4e71,25-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8

	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8
;	dcb	$4e71,8-3

	dcb	$4e71,2
	bra	indistcalcloop	;~12   26 nops before right borde

rueckwaerts:
	add.w	#16,d_2			;~8
	move.w	d_2,(a_0)		;~8 write back new shift
	dcb	$4e71,2+7
	dcb	$4e71,25-22	;digi
	digi1
	calc_mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont5
rueckbufok:
	subq.l	#8,bufptr-shift(a_0)	;~16
	DCB	$4E71,2
	bra.s	_rueckbufok		;~12
cont5:
	dcb	$4e71,5-2
	do_mdist


	subq.w	#4,bufcnt-shift(a_0)	;~12
	bhs.s	rueckbufok		;~8
	move.w	#25*4,bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)	;~32
_rueckbufok:
	move.l	textptr-shift(a_0),a_1	;~16
	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		             textptr
	;  |			     |
	;YEAH THIS IS UNLIMITED MATRICKS	a bit of C appears somewhere
	;a bit of A appears somewhere
	;now we have to write a bit of E and A 
	moveq	#0,d_1
	moveq	#0,d_2
	move.b	-27(a_1),d_1	;~12 previous letter : E 
	move.b	-26(a_1),d_2	;~12 act letter	 : A
	lea	-1(a_1),a_1	;~8
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to I
;	clr.b	d_1	;~4 E
	lsl.w	#3,d_1	;~8
	dcb	$4e71,7-2-2-2+2
;	clr.b	d_2	;~4 A
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 E
	movem.l	(a_1,d_2),d_1/d_3	;~36 A
	calc_mdist02

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist02


	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 E
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8

	dcb	$4e71,5
	bra	call_shifter	

vorwaerts2:
	move.w	d_2,(a_0)
	move.l	textptr-shift(a_0),a_1
	dcb	$4e71,2
	dcb	$4e71,25-17-3-1-1

	moveq	#0,d_1
	moveq	#0,d_2
	move.b	(a_1),d_1	;~16 previous letter : C
	move.b	1(a_1),d_2	;~16 act letter	 : K
	tst.b	2(a_1)		;~4  test letter after act : S
	bne.s	nottextend2	;~8
	lea	scrolltext,a_1	;~12
	nop
	nop
	nop
_nottextend2:
	lsl.w	#3,d_1	;~8
	nop	
	calc_mdist

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont22
nottextend2:			;~12
	addq.w	#1,a_1		;~8
	bra	_nottextend2	;~12
cont22:
	dcb	$4e71,5-2
	do_mdist

	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to K
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 C
	movem.l	(a_1,d_2),d_1/d_3	;~36 K
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 C
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	dcb	$4e71,23-22-1
	digi2
	calc_mdist2

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2
	cmpi.w	#25*4,bufcnt-shift(a_0)	;~16
	blo.s	vorbufok2		;~8
	clr.w	bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	subi.l	#25*8,bufptr-shift(a_0)	;~20
	bra.s	vorbufnok2		;~12
vorbufok2:
	addq.w	#4,bufcnt-shift(a_0)	;~16
	addq.l	#8,bufptr-shift(a_0)	;~16
	dcb	$4e71,9-5
vorbufnok2:
	dcb	$4e71,5
	dcb	$4e71,2
call_shifter2:	
	;write first buffer
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~24
	lea	26*8(a_1),a_1	;~8

	swap	d_1	
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,5
	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1


	dcb	$4e71,25-13+18-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3
	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13+18-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3

	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13+18-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

;	dcb	$4e71,8-3

	dcb	$4e71,2
	bra	indistcalcloop2	;~12   26 nops before right borde

rueckwaerts2:
	add.w	#16,d_2			;~8
	move.w	d_2,(a_0)		;~8 write back new shift
	dcb	$4e71,2+7
	dcb	$4e71,25-18-4	;digi
	subq.w	#4,bufcnt-shift(a_0)	;~12
	bhs.s	rueckbufok2		;~8
	move.w	#25*4,bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)	;~32
_rueckbufok2:
	move.l	textptr-shift(a_0),a_1	;~16
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont52
rueckbufok2:
	subq.l	#8,bufptr-shift(a_0)	;~16
	DCB	$4E71,2
	bra.s	_rueckbufok2		;~12
cont52:
	dcb	$4e71,5-2
	do_mdist

	moveq	#0,d_1
	moveq	#0,d_2
	move.b	-27(a_1),d_1	;~16 previous letter : E
	move.b	-26(a_1),d_2	;~16 act letter	 : A
	lea	-1(a_1),a_1	;~8
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to I
	lsl.w	#3,d_1	;~8
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 E
	movem.l	(a_1,d_2),d_1/d_3	;~36 A

	dcb	$4e71,7+18-22
	digi2
	calc_mdist02
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist02
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 E
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	dcb	$4e71,5
	bra	call_shifter2	


vorwaerts3:
	move.w	d_2,(a_0)
	move.l	textptr-shift(a_0),a_1
	dcb	$4e71,2
	dcb	$4e71,25-22
	digi2
	calc_mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont23
nottextend3:			;~12
	addq.w	#1,a_1		;~8
	bra	_nottextend3	;~12
cont23:
	dcb	$4e71,5-2
	do_mdist

	moveq	#0,d_1
	moveq	#0,d_2
	move.b	(a_1),d_1	;~16 previous letter : C
	move.b	1(a_1),d_2	;~16 act letter	 : K
	tst.b	2(a_1)		;~4  test letter after act : S
	bne.s	nottextend3	;~8
	lea	scrolltext,a_1	;~12
	nop
	nop
	nop
_nottextend3:
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to K
;	clr.b	d_1		;~4 C
	lsl.w	#3,d_1	;~8
;	clr.b	d_2		;~4 K
	dcb	$4e71,6-2-2-1
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 C
	movem.l	(a_1,d_2),d_1/d_3	;~36 K
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 C
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	calc_mdist2

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2
	cmpi.w	#25*4,bufcnt-shift(a_0)	;~16
	blo.s	vorbufok3		;~8
	clr.w	bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	subi.l	#25*8,bufptr-shift(a_0)	;~20
	bra.s	vorbufnok3		;~12
vorbufok3:
	addq.w	#4,bufcnt-shift(a_0)	;~16
	addq.l	#8,bufptr-shift(a_0)	;~16
	dcb	$4e71,9-5
vorbufnok3:
	dcb	$4e71,5
	dcb	$4e71,2
	

call_shifter3:	
	;write first buffer
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~24
	lea	26*8(a_1),a_1	;~8
	dcb	$4e71,5
	dcb	$4e71,25-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1	
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1


	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3

	dcb	$4e71,25-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3

	dcb	$4e71,25-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
;	dcb	$4e71,8-3

	dcb	$4e71,2
	bra	indistcalcloop3	;~12   26 nops before right borde

rueckwaerts3:
	add.w	#16,d_2			;~8
	move.w	d_2,(a_0)		;~8 write back new shift
	dcb	$4e71,2+7
	dcb	$4e71,25-22	;digi
	digi2
	calc_mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont53
rueckbufok3:
	subq.l	#8,bufptr-shift(a_0)	;~16
	DCB	$4E71,2
	bra.s	_rueckbufok3		;~12
cont53:
	dcb	$4e71,5-2
	do_mdist


	subq.w	#4,bufcnt-shift(a_0)	;~12
	bhs.s	rueckbufok3		;~8
	move.w	#25*4,bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)	;~32
_rueckbufok3:
	move.l	textptr-shift(a_0),a_1	;~16
	moveq	#0,d_1
	moveq	#0,d_2
	move.b	-27(a_1),d_1	;~16 previous letter : E
	move.b	-26(a_1),d_2	;~16 act letter	 : A
	lea	-1(a_1),a_1	;~8
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to I
	lsl.w	#3,d_1	;~8
	dcb	$4e71,7-2-2
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 E
	movem.l	(a_1,d_2),d_1/d_3	;~36 A
	calc_mdist02
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist02
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 E
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	dcb	$4e71,5
	bra	call_shifter3	


vorwaerts4:
	move.w	d_2,(a_0)
	move.l	textptr-shift(a_0),a_1
	dcb	$4e71,2
	dcb	$4e71,25-17-3-1-1

	moveq	#0,d_1
	moveq	#0,d_2
	move.b	(a_1),d_1	;~16 previous letter : C
	move.b	1(a_1),d_2	;~16 act letter	 : K
	tst.b	2(a_1)		;~4  test letter after act : S
	bne.s	nottextend4	;~8
	lea	scrolltext,a_1	;~12
	nop
	nop
	nop
_nottextend4:
	lsl.w	#3,d_1	;~8
	nop
	calc_mdist

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont24
nottextend4:			;~12
	addq.w	#1,a_1		;~8
	bra	_nottextend4	;~12
cont24:
	dcb	$4e71,5-2
	do_mdist

	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to K
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 C
	movem.l	(a_1,d_2),d_1/d_3	;~36 K
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 C
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	dcb	$4e71,23-22-1
	digi1
	calc_mdist2

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2
	cmpi.w	#25*4,bufcnt-shift(a_0)	;~16
	blo.s	vorbufok4		;~8
	clr.w	bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	subi.l	#25*8,bufptr-shift(a_0)	;~20
	bra.s	vorbufnok4		;~12
vorbufok4:
	addq.w	#4,bufcnt-shift(a_0)	;~16
	addq.l	#8,bufptr-shift(a_0)	;~16
	dcb	$4e71,9-5
vorbufnok4:
	dcb	$4e71,5
	dcb	$4e71,2
call_shifter4:	
	;write first buffer

	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~24
	lea	26*8(a_1),a_1	;~8

	swap	d_1	
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,5
	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1


	dcb	$4e71,25-13+18-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3
	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13+18-22
	digi1
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1
	dcb	$4e71,8-3

	dcb	$4e71,25-18
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,25-13+18-22
	digi2
	calc_mdist2
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist2

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	swap	d_1
 	addx.w	d1,d1
	swap	d_1
 	addx.l	d0,d0
 	addx.l	d3,d3
 	addx.l	d2,d2
 	addx.w	d1,d1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1

	dcb	$4e71,2
	bra	indistcalcloop4	;~12   26 nops before right borde
rueckwaerts4:
	add.w	#16,d_2			;~8
	move.w	d_2,(a_0)		;~8 write back new shift
	dcb	$4e71,2+7
	dcb	$4e71,25-18-4	;digi
	subq.w	#4,bufcnt-shift(a_0)	;~12
	bhs.s	rueckbufok4		;~8
	move.w	#25*4,bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)	;~32
_rueckbufok4:
	move.l	textptr-shift(a_0),a_1	;~16
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont54
rueckbufok4:
	subq.l	#8,bufptr-shift(a_0)	;~16
	DCB	$4E71,2
	bra.s	_rueckbufok4		;~12
cont54:
	dcb	$4e71,5-2
	do_mdist

	moveq	#0,d_1
	moveq	#0,d_2
	move.b	-27(a_1),d_1	;~16 previous letter : E
	move.b	-26(a_1),d_2	;~16 act letter	 : A
	lea	-1(a_1),a_1	;~8
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to I
	lsl.w	#3,d_1	;~8
	lsl.w	#3,d_2	;~8
	lea	font-8+(scrhigh*fontpartlen),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 E
	movem.l	(a_1,d_2),d_1/d_3	;~36 A

	dcb	$4e71,7+18-22
	digi1
	calc_mdist02
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist02
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	swap	d_0		;~4
	swap	d_2		;~4
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 E
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	dcb	$4e71,5
	bra	call_shifter4	


copydistscroll:
	;**** Copy all the buffers to the screen ****
	;loop needs : 	d0-d6  : copy
	;		(a7+usp),a2,a1,a0:ptr

	;		d7:0digi	sample
	;		a6:digi sampleptr
	;		a7:digi voltab

	;		a5,a4,a3: megadist
	
	move.l	logbase,a0	;put it there
	add.l	#6*160+230*(280-20),a0	;for hwscroll
	move.w	#13,count		;scrollhigh:18
	
	
	dcb	$4e71,21-1+3-22
	digi2
	dcb	$4e71,22	;digi
;	digi1
	lea	buffer,a7
	move.l	a7,usp
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
;	move.b	#$77,$ffff8240.w
;	move.b	#0,$ffff8240.w
	lea	openlowtab,a1
	dcb	$4e71,8-2-3
	do_mdist
	dcb	$4e71,11
	bra.s	scrollcpy
mul208:
	dc.w	0,208,208*2,208*3,208*4,208*5,208*6,208*7,208*8
	dc.w	208*9,208*10,208*11,208*12,208*13,208*14,208*15
scrollcpy:
	move.w	shift-buffer(a7),d1
	add.w	d1,d1
	move.w	mul208(pc,d1),d1
	lea	(a7,d1),a2
	move.w	bufcnt-buffer(a7),d1
;;	move.l	a0,d0		;;weg!!
	lea	cpyjsr,a7	;;a1
	move.l	(a7,d1),goto	;;a1
;;	move.l	d0,a0		;;weg
;;	nop
	lea	downthere+512,a7
;	dcb	$4e71,22	;digi
	digi1
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	dcb	$4e71,6-1-2
goto	equ	*+2
   	jmp	$00000000		;(a2)+ -> (a0)   uses d1-a1
endcpy:
	move.l	usp,a7
	lea	230(a0),a0
	dcb	$4e71,2-2
	do_mdist
;	move.b	#2,$ffff820a.w	;sicher is sicher: 50Hz
	lea	linebuffend-linebuffbegin(a7),a7
	move.l	a7,usp
	nop
	nop
	nop
	subq.w	#1,count
	bne	o_scrollcpy
	bra	endscrollcpy

o_mul208:
	dc.w	0,208,208*2,208*3,208*4,208*5,208*6,208*7,208*8
	dc.w	208*9,208*10,208*11,208*12,208*13,208*14,208*15
o_scrollcpy:
	move.w	shift-buffer(a7),d1
	add.w	d1,d1
	move.w	o_mul208(pc,d1),d1
	lea	(a7,d1),a2
	move.w	bufcnt-buffer(a7),d1
	lea	o_cpyjsr,a7	;;a1
	move.l	(a7,d1),o_goto	;;a1
	lea	downthere+512,a7
;	dcb	$4e71,22	;digi
	digi2
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	dcb	$4e71,6-1-2
o_goto	equ	*+2
   	jmp	$00000000		;(a2)+ -> (a0)   uses d1-a1
o_endcpy:
	move.l	usp,a7
	lea	230(a0),a0
	dcb	$4e71,2-2
	do_mdist
	lea	linebuffend-linebuffbegin(a7),a7
	move.l	a7,usp
	nop
	nop
	nop
	subq.w	#1,count
	bne	scrollcpy

endscrollcpy:

*****************************************
*	end of the synchron part	*
*****************************************


	move.b	#0,$fffffa19.w	;stop timer
	move.b	#80,$fffffa1f.w	;244
	move.b	#32,$fffffa07.w
	move.b	#0,$fffffa0b.w	;clr pending
	move.b	#2,$fffffa19.w


	


c0	equr	d0
c1	equr	d1
c2	equr	d2
c3	equr	d3
c4	equr	d4
c5	equr	d5
c6	equr	d6
;these ones if no megadist
c7	equr	a3
c8	equr	a4
c9	equr	a5
;this one if no lower border to open
c10	equr	a1

	;let's copy the rest
	clr.w	digswitch
	move.w	#7,count
scrollcpy2:
	move.w	shift-buffer(a7),d1
	add.w	d1,d1
	move.w	_mul208(pc,d1),d1
	lea	(a7,d1),a2
	move.w	bufcnt-buffer(a7),d1
	lea	cpyjsr2(pc),a1
	move.l	(a1,d1),a1
	
	lea	downthere+512.w,a7	;voltab (.w)
	not.w	digswitch
	bne.s	cpy_d2
	digi1
   	jmp	(a1)		;(a2)+ -> (a0)   uses d1-a1
_mul208:
	dc.w	0,208,208*2,208*3,208*4,208*5,208*6,208*7,208*8
	dc.w	208*9,208*10,208*11,208*12,208*13,208*14,208*15

cpy_d2:
	digi2
   	jmp	(a1)		;(a2)+ -> (a0)   uses d1-a1
endcpy2:
	move.l	usp,a7
	lea	230(a0),a0
	lea	linebuffend-linebuffbegin(a7),a7
	move.l	a7,usp
	subq.w	#1,count
	bne	scrollcpy2

	lea	downthere+512.w,a7	;voltab (.w ?)

	;**********************************************************
	;buffercopy


bbb
	move.l	cpybufdest,a0		;write there
	move.l	a0,a2
	add.l	#230*280*4-230*20,a2	;read here	

	digi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,88(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,132(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,176(a0)	;4*11*4+8*4=208:1 line copied
	lea	230(a0),a0		;next line
	lea	22(a2),a2
	digi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,88(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,132(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,176(a0)	;4*11*4+8*4=208:1 line copied
	lea	230(a0),a0		;next line
	lea	22(a2),a2
	digi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,88(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,132(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,176(a0)	;4*11*4+8*4=208:1 line copied
	lea	230(a0),a0		;next line
	lea	22(a2),a2
	digi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,88(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,132(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,176(a0)	;4*11*4+8*4=208:1 line copied
	lea	230(a0),a0		;next line
	lea	22(a2),a2
	digi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,88(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,132(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,176(a0)	;4*11*4+8*4=208:1 line copied
	lea	230(a0),a0		;next line
	lea	22(a2),a2
	digi2

	move.l	a0,cpybufdest	;position to write during next vbl
	cmp.l	#scrnadrs+4,nextscrn
	bne.s	notreset
	move.l	#screen-(15*230)+160*6,cpybufdest
notreset:
	;**********************************************************


	btst	#0,$fffffc00.w
	beq	no_key

	move.b	$fffffc02.w,d0

	cmpi.b	#99,d0
	bne.s	notl
	addi.l	#16,codmod+2
notl:
	cmpi.b	#100,d0
	bne.s	notr
	addi.l	#-16,codmod+2
notr:
	cmpi.b	#107,d0
	bne.s	not5
	move.l	#0,codmod+2
not5:
	cmpi.b	#110,d0
	bne.s	not2
	ifeq overscan
	addi.l	#-230,codmod+2
	endc
	ifne overscan
	addi.l	#-160,codmod+2
	endc
not2:
	cmpi.b	#104,d0
	bne.s	not8
	ifeq overscan
	addi.l	#230,codmod+2
	endc
	ifne overscan
	addi.l	#160,codmod+2
	endc
not8:
	cmpi.b	#108,d0
	bne.s	not6
	addi.l	#-8,codmod+2
not6:
	cmpi.b	#78,d0
	bne.s	notd
;	add.l	#-320,codmod+2
	addi.b	#-2,lowbyte
	lea	screenadr,a3
	move.b	lowbyte,3(a3)

notd:
	cmpi.b	#106,d0
	bne.s	not4
	addi.l	#8,codmod+2
not4:
	cmpi.b	#74,d0
	bne.s	notu
;	add.l	#320,codmod+2
	addi.b	#2,lowbyte
	lea	screenadr,a3
	move.b	lowbyte,3(a3)
notu:
	cmpi.b	#57,d0
	bne.s	no_key

exit:
	;restore digisound
	move.w	#(256+512/4)-1,d0
	lea	domino,a0
	lea	downthere,a1
restdigi:
	move.l	(a0)+,(a1)+
	dbf	d0,restdigi



	movea.l stack,sp
	move	(sp)+,sr
	rts

no_key:
	lea	screenadr,a3
codmod:
	addi.l	#0,(a3)
	moveq	#0,d0
	move.b	3(a3),d0
	lsr.l	#1,d0

;--------------------------------------------------------------
;	bra	looop
	movem.l black,d0-d6/a0
	movem.l d0-d6/a0,$ffff8240.w
	digi1
	move.l	mdistadjustptr,a4
sss	equ	15
	lea	shift+sss*(linebuffend-linebuffbegin),a0
	lea	sss*2(a4),a4
	moveq	#4,d0
adjloop:
	move.w	(a0),d1
	lea	linebuffend-linebuffbegin(a0),a0
	ifeq	parallax
	andi.w	#110,d1
	endc
	ifne	parallax
	andi.w	#111,d1		;mod_16 to mod_8
	add.w	d1,d1		;even
	endc
	move.w	d1,14*20*2(a4)
	move.w	d1,(a4)+
	dbf	d0,adjloop
	sub.w	#sss*2,a4
	cmp.l	#mdistadjust+14*20*2,a4
	blo.s	adjok
	lea	mdistadjust,a4
adjok:
	move.l	a4,mdistadjustptr
	digi2	
 	lea	mdistgraph,a5
	move.l	mdistadjustptr,a4

	move.l	mdistcurvptr,a3
	addq.l	#2,a3
	cmp.l	#mdistcurv+300*2,a3
	blo.s	mcurvok
	lea	mdistcurv,a3
mcurvok:
	move.l	a3,mdistcurvptr

	move.l	mactcurv,a0
	move.w	(a0)+,d0
	cmp.w	#128,d0
	bne.s	mcurvok2
	move.l	mnextcurv,a0
	move.l	(a0)+,d0
	bne.s	mnextok
	lea	mwavetab,a0
	move.l	(a0)+,d0
mnextok:
	move.l	a0,mnextcurv
	move.l	d0,a0
	move.w	(a0)+,d0
mcurvok2:
	move.l	a0,mactcurv
	add.w	d0,mdistcurvval
	move.w	mdistcurvval,d0
	andi.w	#7,d0
	add.w	d0,d0
	move.w	d0,(a3)
	move.w	d0,300*2(a3)
		
	move.l	hwbounceptr,a0
	move.w	-2(a0),d0
	cmpi.w	#-1,d0
	bne.s	bounceok
	move.w	hwbouncetab,d0
bounceok:
	ext.l	d0
	divs	#230/2,d0
	adda.w	d0,a4
	ifeq	parallay
	andi.w	#$ffff,d0
	asl.w	#6,d0
	adda.w	d0,a5
	endc
	ifne	parallay
	move.l	mbounceptr,a0
	move.w	(a0)+,d0
	cmpi.w	#-1,d0
	bne.s	mbounceok
	lea	mbouncetab,a0
	move.w	(a0)+,d0
mbounceok:
	move.l	a0,mbounceptr
	add.w	d0,a3
	lsl.w	#5,d0
	add.w	d0,a5
	endc

	lea	15*2(a4),a4
	calc_mdist
	movem.l	d3/d4/d5/d6,hwpalette+16
	lea	64(a5),a5


	cmp.l	#digiend-75,a6
	blo.s	digiok
	lea	digisound-2,a6
	move.w	(a6)+,d7


digiok:

	digi1
;	ifeq	test
	lea	predigi,a0
	move.l	a0,a1
	moveq	#1,d0	
calcpredigi:
	rept	2
	;digi2
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	andi.w	#$ff*4,d7	;~2
	move.l	(a7,d7),(a0)+
	move.l	(a7,d7),(a0)+

	;digi1
	moveq	#-1,d6
	move.b	(a6),d6
	add.w	d6,d6
	add.w	(a7,d6),d7
	andi.w	#$ff*4,d7
	move.l	(a7,d7),(a0)+
	move.l	(a7,d7),(a0)+
	endr
	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a1)+,d6
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	endc
	dbf	d0,calcpredigi
	;digi2
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	andi.w	#$ff*4,d7	;~2
	move.l	(a7,d7),(a0)+
	move.l	(a7,d7),(a0)+

	;digi1
	moveq	#-1,d6
	move.b	(a6),d6
	add.w	d6,d6
	add.w	(a7,d6),d7
	andi.w	#$ff*4,d7
	move.l	(a7,d7),(a0)+
	move.l	(a7,d7),(a0)+
	;digi2
	moveq	#-1,d6		;~1
	move.b	(a6)+,d6	;~2
	add.w	d6,d6		;~1
	add.w	2(a7,d6),d7	;~4
	andi.w	#$ff*4,d7	;~2
	move.l	(a7,d7),(a0)+
	move.l	(a7,d7),(a0)+

	dcb	$4e71,70

	move.l	a6,digiptr
;	endc
	dcb	$4e71,150
	move.l	a1,a6
	ifeq	digitest
	move.w	#$777,$ffff8240.w
	move.w	#$333,$ffff8240.w
	nop
	nop
	endc
	ifne	digitest
	move.l	(a6)+,d6			;~3
	movep.l	d6,$ffff8800-512-downthere(a7)		;~7
	endc
	
	move.w	#911,$ffff8240.w
	move.b	#0,$fffffa0b.w	;clr pending
no_int:
	tst.b	$fffffa0b.w
	beq.s	no_int



	move.w	#$00,$ffff8240.w

	bra	loop

;--------------------------------------------------------------

	bsr	waitvbl

	movem.l black,d0-d7
	movem.l d0-d7,$ffff8240.w
	movem.l hwpalette,d2-d7/a2-a3
	lea	$ffff8209.w,a1
	moveq	#10,d1
	movea.l tabentry,a0	;get back tablepos


	move.w	#1500,d0
opentopwait2:
	dbra	d0,opentopwait2
	dcb	$4e71,196-72-2
	move.b	#0,$ffff820a.w
	move.w	#$007,$ffff8240.w
	dcb	$4e71,8
	move.b	#2,$ffff820a.w



d0todeza3:
	movem.l d0-d1/a3,-(sp)
	addq.w	#1,a3
	moveq	#3,d1
	divu	#10000,d0
	beq.s	smallone
hexdezinit:
	move.b	#"0",-(a3)
	dbra	d1,hexdezinit
	bsr.s	hextodez
	addq.w	#4,a3
smallone:
	swap	d0
	bsr.s	hextodez
	movem.l (sp)+,d0-d1/a3
	rts
hextodez:
	movem.l d1/a3,-(sp)
	move.w	d0,d1
nexthextodez:
	divu	#10,d1
	swap	d1
	add.b	#"0",d1
	move.b	d1,-(a3)
	clr.w	d1
	swap	d1
	bne.s	nexthextodez
	movem.l (sp)+,d1/a3
	rts

	;**********************************************************
cpyjsr2:
	dc.l	cpy2_00,cpy2_01,cpy2_02,cpy2_03,cpy2_04
	dc.l	cpy2_05,cpy2_06,cpy2_07,cpy2_08,cpy2_09
	dc.l	cpy2_10,cpy2_11,cpy2_12,cpy2_13,cpy2_14
	dc.l	cpy2_15,cpy2_16,cpy2_17,cpy2_18,cpy2_19
	dc.l	cpy2_20,cpy2_21,cpy2_22,cpy2_23,cpy2_24
	dc.l	cpy2_25

cpy2_00:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,4*44(a0)
	bra	endcpy2
cpy2_01:
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,4*50(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)	
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*44(a0)
	bra	endcpy2
cpy2_02:
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,4*48(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)	
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,4*44(a0)
	bra	endcpy2
cpy2_03:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*46(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)	
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,4*44(a0)
	bra	endcpy2
cpy2_04:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,4*44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)	
	bra	endcpy2
cpy2_05:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9,4*42(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*33(a0)	
	bra	endcpy2
cpy2_06:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*40(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a0)	
	bra	endcpy2
cpy2_07:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*38(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*33(a0)	
	bra	endcpy2
cpy2_08:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*33(a0)	
	bra	endcpy2
cpy2_09:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*45(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*33(a0)	
	bra	endcpy2
cpy2_10:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*43(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9,4*22(a0)
	bra	endcpy2
cpy2_11:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*41(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,4*22(a0)
	bra	endcpy2
cpy2_12:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*39(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,4*50(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*22(a0)
	bra	endcpy2
cpy2_13:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*37(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,4*48(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,4*22(a0)
	bra	endcpy2
cpy2_14:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*35(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*46(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,4*22(a0)
	bra	endcpy2
cpy2_15:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*33(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,4*44(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10	
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*11(a0)
	bra	endcpy2
cpy2_16:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*31(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9,4*42(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*11(a0)
	bra	endcpy2
cpy2_17:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*29(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*40(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*11(a0)
	bra	endcpy2
cpy2_18:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*27(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*38(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*11(a0)
	bra	endcpy2
cpy2_19:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*25(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*11(a0)
	bra	endcpy2
cpy2_20:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*23(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*45(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*11(a0)
	bra	endcpy2
cpy2_21:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*21(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*43(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9,(a0)
	bra	endcpy2
cpy2_22:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*19(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*41(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,(a0)
	bra	endcpy2
cpy2_23:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*17(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*39(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,4*50(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a0)
	bra	endcpy2
cpy2_24:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*15(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*37(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,4*48(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	bra	endcpy2
cpy2_25:
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*13(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8/c9/c10,4*35(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*46(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	bra	endcpy2

	;**********************************************************
	;	Distorted scroller by Gunstick
	;The 26 copyroutines
cpyjsr:
	dc.l	cpy00,cpy01,cpy02,cpy03,cpy04
	dc.l	cpy05,cpy06,cpy07,cpy08,cpy09
	dc.l	cpy10,cpy11,cpy12,cpy13,cpy14
	dc.l	cpy15,cpy16,cpy17,cpy18,cpy19
	dc.l	cpy20,cpy21,cpy22,cpy23,cpy24
	dc.l	cpy25
	;copy 208 bytes from (a2) to (a0)  (52 registers)
	;read/write: 24+16*n = 16*(1.5+n)

swnodigi	MACRO
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	ENDM

swdigi1	MACRO
	digi1
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	ENDM
swdigi2	MACRO
	digi2
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	dcb	$4e71,8-2
	do_mdist
	ENDM

cpy00:	;7,9,9,9,9,9
	do_mdist
	move.b	#2,$ffff820a.w
	dcb	$4e71,2
	nop
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*5(a0)
	swnodigi
	move.b	#2,$ffff820a.w
	dcb	$4e71,0
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	move.l	(a2)+,4*19(a0)
	swdigi2
	dcb	$4e71,2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	swnodigi
	move.b	#2,$ffff820a.w
	dcb	$4e71,10-4
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a0)
	swdigi1
	move.b	#2,$ffff820a.w
	dcb	$4e71,6-4
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*40(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy01:	;2+5,7,7,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1
	movem.l	c0/c1,4*50(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	move.l	(a2)+,4*17(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*31(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*38(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*45(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy02:	;4+3,9,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3
	movem.l	c0/c1/c2/c3,4*48(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	move.l	(a2)+,4*15(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*29(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*43(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy03:	;6+1,9,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l	c0/c1/c2/c3/c4/c5,4*46(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	move.l	(a2)+,4*13(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*27(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*41(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy04:	;8,8,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*44(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	move.l	(a2)+,4*11(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*25(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*39(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy05:	;9,1+6,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*42(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	move.l	(a2)+,4*9(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*23(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*37(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy06:	;9,3+4,9,9,9,9
	do_mdist
	move.b	#2,$ffff820a.w

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*40(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	dcb	$4e71,5-4
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	nop
	move.l	(a2)+,4*7(a0)
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*21(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*35(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy07:	;9,5+2,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*38(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*45(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a0)
	dcb	$4e71,5-4
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*33(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy08:	;9,7,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*43(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,5-4
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*17(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*31(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy09:	;9,9,7,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*41(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,5-4
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*15(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*29(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy10:	;9,9,2+5,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*39(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*45(a0)
	dcb	$4e71,10-4
	swdigi2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*0(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*13(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*27(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy11:	;9,9,4+3,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*37(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*43(a0)
	move.l	(a2)+,50*4(a0)
	dcb	$4e71,4-4
	swdigi2
	move.b	#2,$ffff820a.w
	move.l	(a2)+,51*4(a0)
	movem.l	(a2)+,c1/c2/c3/c4
	movem.l		c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	dcb	$4e71,5-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*11(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*25(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy12:	;9,9,6+1,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*35(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*41(a0)
	move.l	(a2)+,48*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,49*4(a0)
	movem.l	(a2)+,c1/c2
	movem.l		c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*9(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*23(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy13:	;9,9,8,8,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*33(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*39(a0)
	move.l	(a2)+,46*4(a0)
	dcb	$4e71,4-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,47*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	dcb	$4e71,1+6-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*7(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*21(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy14:	;9,9,9,1+6,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*31(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*37(a0)
	move.l	(a2)+,44*4(a0)
	dcb	$4e71,4-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,45*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	dcb	$4e71,1+6-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*5(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*19(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy15:	;9,9,9,3+4,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*29(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*35(a0)
	move.l	(a2)+,42*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,43*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*3(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*17(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy16:	;9,9,9,5+2,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*27(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a0)
	move.l	(a2)+,40*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,41*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,48*4(a0)
	movem.l	(a2)+,c0
	movem.l		c0,(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*1(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*15(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy17:	;9,9,9,7,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*25(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*31(a0)
	move.l	(a2)+,38*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,39*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,46*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a0)
	dcb	$4e71,10+5-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*13(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy

cpy18:	;9,9,9,9,7,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*23(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*29(a0)
	move.l	(a2)+,36*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,37*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,44*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,9-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*11(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy19:	;9,9,9,9,2+5,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*21(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*27(a0)
	move.l	(a2)+,34*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,35*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,42*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,48*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,9-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*9(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy20:	;9,9,9,9,4+3,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*19(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*25(a0)
	move.l	(a2)+,32*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,33*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,40*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,46*4(a0)
	dcb	$4e71,1+6+7-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*7(a0)
	dcb	$4e71,6+1-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy




cpy21:
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*17(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*23(a0)
	move.l	(a2)+,30*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,31*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,38*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,44*4(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0
	movem.l		c0,51*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*5(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy22:	;9,9,9,9,8,8
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*15(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*21(a0)
	move.l	(a2)+,28*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,29*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,36*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,42*4(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,49*4(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*3(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy23:	;9,9,9,9,8,8
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*13(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a0)
	move.l	(a2)+,26*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,27*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,34*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,40*4(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,47*4(a0)
	movem.l	(a2)+,c0
	movem.l		c0,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,1*4(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


cpy24:	;9,9,9,9,9,3+4
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*11(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*17(a0)
	move.l	(a2)+,24*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,25*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,32*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,38*4(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,45*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,1+6+4-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy




cpy25:	;9,9,9,9,9,5+2
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*9(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*15(a0)
	move.l	(a2)+,22*4(a0)
	dcb	$4e71,4-4
	swdigi2
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,23*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,30*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,36*4(a0)
	dcb	$4e71,10-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,43*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,1+4-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	endcpy


o_cpyjsr:
	dc.l	o_cpy00,o_cpy01,o_cpy02,o_cpy03,o_cpy04
	dc.l	o_cpy05,o_cpy06,o_cpy07,o_cpy08,o_cpy09
	dc.l	o_cpy10,o_cpy11,o_cpy12,o_cpy13,o_cpy14
	dc.l	o_cpy15,o_cpy16,o_cpy17,o_cpy18,o_cpy19
	dc.l	o_cpy20,o_cpy21,o_cpy22,o_cpy23,o_cpy24
	dc.l	o_cpy25
	;copy 208 bytes from (a2) to (a0)  (52 registers)
	;read/write: 24+16*n = 16*(1.5+n)

o_cpy00:	;7,9,9,9,9,9
	do_mdist
	move.b	#2,$ffff820a.w
	dcb	$4e71,2
	nop
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*5(a0)
	swnodigi
	move.b	#2,$ffff820a.w
	dcb	$4e71,0
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	move.l	(a2)+,4*19(a0)
	swdigi1
	dcb	$4e71,2
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	swnodigi
	move.b	#2,$ffff820a.w
	dcb	$4e71,10-4
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a0)
	swdigi2
	move.b	#2,$ffff820a.w
	dcb	$4e71,6-4
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*40(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy01:	;2+5,7,7,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1
	movem.l	c0/c1,4*50(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	move.l	(a2)+,4*17(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*31(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*38(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*45(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy02:	;4+3,9,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3
	movem.l	c0/c1/c2/c3,4*48(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	move.l	(a2)+,4*15(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*29(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*43(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy03:	;6+1,9,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l	c0/c1/c2/c3/c4/c5,4*46(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*3(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	move.l	(a2)+,4*13(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*27(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*41(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy04:	;8,8,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*44(a0)
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	move.l	(a2)+,4*11(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*25(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*39(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy05:	;9,1+6,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*42(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	move.l	(a2)+,4*9(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*23(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*37(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy06:	;9,3+4,9,9,9,9
	do_mdist
	move.b	#2,$ffff820a.w

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*40(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	dcb	$4e71,5-4
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	nop
	move.l	(a2)+,4*7(a0)
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*21(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*35(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy07:	;9,5+2,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*38(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*45(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0
	movem.l		c0,4*51(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a0)
	dcb	$4e71,5-4
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*33(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy08:	;9,7,9,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*36(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*43(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,5-4
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*17(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*31(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy09:	;9,9,7,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*34(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*41(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,5-4
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*15(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*29(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy10:	;9,9,2+5,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*32(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*39(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*45(a0)
	dcb	$4e71,10-4
	swdigi1
	movem.l	(a2)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*0(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*13(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*27(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy11:	;9,9,4+3,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*30(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*37(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*43(a0)
	move.l	(a2)+,50*4(a0)
	dcb	$4e71,4-4
	swdigi1
	move.b	#2,$ffff820a.w
	move.l	(a2)+,51*4(a0)
	movem.l	(a2)+,c1/c2/c3/c4
	movem.l		c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	dcb	$4e71,5-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*11(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*25(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy12:	;9,9,6+1,9,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*28(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*35(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*41(a0)
	move.l	(a2)+,48*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,49*4(a0)
	movem.l	(a2)+,c1/c2
	movem.l		c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*9(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*23(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy13:	;9,9,8,8,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*26(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*33(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*39(a0)
	move.l	(a2)+,46*4(a0)
	dcb	$4e71,4-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,47*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	dcb	$4e71,1+6-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*7(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*21(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy14:	;9,9,9,1+6,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*24(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*31(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*37(a0)
	move.l	(a2)+,44*4(a0)
	dcb	$4e71,4-4
	swdigi1
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,45*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	dcb	$4e71,1+6-4
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*5(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*19(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy15:	;9,9,9,3+4,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*22(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*29(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*35(a0)
	move.l	(a2)+,42*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,43*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*3(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*17(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy16:	;9,9,9,5+2,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*20(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*27(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a0)
	move.l	(a2)+,40*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,41*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,48*4(a0)
	movem.l	(a2)+,c0
	movem.l		c0,(a0)
	dcb	$4e71,1
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*1(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*15(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy17:	;9,9,9,7,9,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*18(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*25(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*31(a0)
	move.l	(a2)+,38*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,39*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,46*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a0)
	dcb	$4e71,10+5-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*13(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

o_cpy18:	;9,9,9,9,7,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*16(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*23(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*29(a0)
	move.l	(a2)+,36*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,37*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,44*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,9-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*11(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy19:	;9,9,9,9,2+5,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*14(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*21(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*27(a0)
	move.l	(a2)+,34*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,35*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,42*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,48*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,9-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*9(a0)
	dcb	$4e71,6-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy20:	;9,9,9,9,4+3,9
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*12(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*19(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*25(a0)
	move.l	(a2)+,32*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,33*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,40*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,46*4(a0)
	dcb	$4e71,1+6+7-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*7(a0)
	dcb	$4e71,6+1-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy




o_cpy21:
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*10(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*17(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*23(a0)
	move.l	(a2)+,30*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,31*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,38*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,44*4(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0
	movem.l		c0,51*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*5(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy22:	;9,9,9,9,8,8
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*8(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*15(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*21(a0)
	move.l	(a2)+,28*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,29*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,36*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,42*4(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,49*4(a0)
	movem.l	(a2)+,c0/c1/c2
	movem.l		c0/c1/c2,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*3(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy23:	;9,9,9,9,8,8
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*6(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*13(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a0)
	move.l	(a2)+,26*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,27*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,34*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,40*4(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,47*4(a0)
	movem.l	(a2)+,c0
	movem.l		c0,(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,1*4(a0)
	dcb	$4e71,5-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy


o_cpy24:	;9,9,9,9,9,3+4
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*11(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*17(a0)
	move.l	(a2)+,24*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,25*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,32*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,38*4(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,45*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a0)
	dcb	$4e71,1+6+4-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy




o_cpy25:	;9,9,9,9,9,5+2
	do_mdist

	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*2(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*9(a0)
	dcb	$4e71,1
	nop
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*15(a0)
	move.l	(a2)+,22*4(a0)
	dcb	$4e71,4-4
	swdigi1
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,23*4(a0)
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,30*4(a0)
	dcb	$4e71,2
	swnodigi
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,36*4(a0)
	dcb	$4e71,10-4
	swdigi2
	move.b	#2,$ffff820a.w
	movem.l	(a2)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,43*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,50*4(a0)
	movem.l	(a2)+,c0/c1
	movem.l		c0/c1,(a0)
	dcb	$4e71,1+4-4
	calc_mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	(a1)+,$ffff820a.w
	bra	o_endcpy

	;
	;**********************************************************

	section	data


domino:
	;This is the famous domino-table. Try to understand it !
	dc.w	$0000,$0000,$0004,$0000,$0008,$0000,$0010,$0000,$0020,$0000,$0040,$0000,$0080,$0000,$0100,$0000
	dc.w	$0200,$0000,$0300,$0000,$0380,$0000,$03C0,$0000,$03E0,$0000,$03F0,$0000,$03F8,$0000,$03FC,$0004
	dc.w	$0004,$0008,$0004,$0010,$0004,$0020,$0004,$0040,$0004,$0080,$0004,$0100,$0004,$0200,$0004,$0300
	dc.w	$0004,$0380,$0004,$03C0,$0004,$03E0,$0004,$03F0,$0004,$03F8,$0004,$03FC,$0008,$0008,$0010,$0008
	dc.w	$0020,$0008,$0040,$0008,$0080,$0008,$0100,$0008,$0200,$0008,$0300,$0008,$0380,$0008,$03C0,$0008
	dc.w	$03E0,$0008,$03F0,$0008,$03F8,$0008,$03FC,$0010,$0010,$0020,$0010,$0040,$0010,$0080,$0010,$0100
	dc.w	$0010,$0200,$0010,$0300,$0010,$0380,$0010,$03C0,$0010,$03E0,$0010,$03F0,$0010,$03F8,$0010,$03FC
	dc.w	$0020,$0020,$0040,$0020,$0080,$0020,$0100,$0020,$0200,$0020,$0300,$0020,$0380,$0020,$03C0,$0020
	dc.w	$03E0,$0020,$03F0,$0020,$03F8,$0020,$03FC,$0040,$0040,$0080,$0040,$0100,$0040,$0200,$0040,$0300
	dc.w	$0040,$0380,$0040,$03C0,$0040,$03E0,$0040,$03F0,$0040,$03F8,$0040,$03FC,$0080,$0080,$0100,$0080
	dc.w	$0200,$0080,$0300,$0080,$0380,$0080,$03C0,$0080,$03E0,$0080,$03F0,$0080,$03F8,$0080,$03FC,$0100
	dc.w	$0100,$0200,$0100,$0300,$0100,$0380,$0100,$03C0,$0100,$03E0,$0100,$03F0,$0100,$03F8,$0100,$03FC
	dc.w	$0200,$0200,$0300,$0200,$0380,$0200,$03C0,$0200,$03E0,$0200,$03F0,$0200,$03F8,$0200,$03FC,$0300
	dc.w	$0300,$0380,$0300,$03C0,$0300,$03E0,$0300,$03F0,$0300,$03F8,$0300,$03FC,$0380,$0380,$03C0,$0380
	dc.w	$03E0,$0380,$03F0,$0380,$03F8,$0380,$03FC,$03C0,$03C0,$03E0,$03C0,$03F0,$03C0,$03F8,$03C0,$03FC
	dc.w	$03E0,$03E0,$03F0,$03E0,$03F8,$03E0,$03FC,$03F0,$03F0,$03F8,$03F0,$03FC,$03F8,$03F8,$03FC,$03FC
voltab:	
;         Soundtable from 68000 ST-Magazin
 dc.w $0800,$0900
 dc.w $0801,$0900
 dc.w $0802,$0900
 dc.w $0801,$0901
 dc.w $0802,$0901
 dc.w $0801,$0902
 dc.w $0802,$0902
 dc.w $0803,$0903
 dc.w $0804,$0901
 dc.w $0805,$0900
 dc.w $0805,$0901
 dc.w $0805,$0902
 dc.w $0805,$0902
 dc.w $0806,$0900
 dc.w $0806,$0901
 dc.w $0805,$0903
 dc.w $0806,$0902
 dc.w $0807,$0900
 dc.w $0807,$0901
 dc.w $0806,$0904
 dc.w $0806,$0904
 dc.w $0806,$0904
 dc.w $0806,$0905
 dc.w $0806,$0905
 dc.w $0806,$0905
 dc.w $0806,$0906
 dc.w $0806,$0906
 dc.w $0806,$0906
 dc.w $0807,$0905
 dc.w $0807,$0905
 dc.w $0807,$0906
 dc.w $0807,$0906
 dc.w $0807,$0906
 dc.w $0807,$0906
 dc.w $0807,$0907
 dc.w $0807,$0907
 dc.w $0807,$0907
 dc.w $0807,$0907
 dc.w $0808,$0906
 dc.w $0808,$0906
 dc.w $0808,$0906
 dc.w $0808,$0906
 dc.w $0808,$0907
 dc.w $0808,$0907
 dc.w $0808,$0907
 dc.w $0808,$0907
 dc.w $0809,$0906
 dc.w $0809,$0906
 dc.w $0809,$0906
 dc.w $0809,$0906
 dc.w $0809,$0906
 dc.w $0809,$0907
 dc.w $0809,$0907
 dc.w $0809,$0907
 dc.w $0809,$0907
 dc.w $080A,$0902
 dc.w $080A,$0903
 dc.w $080A,$0904
 dc.w $080A,$0904
 dc.w $080A,$0904
 dc.w $080A,$0905
 dc.w $080A,$0905
 dc.w $080A,$0906
 dc.w $080A,$0906
 dc.w $080A,$0906
 dc.w $080A,$0906
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0907
 dc.w $080A,$0908
 dc.w $080A,$0908
 dc.w $080B,$0904
 dc.w $080B,$0904
 dc.w $080B,$0905
 dc.w $080B,$0905
 dc.w $080B,$0905
 dc.w $080B,$0906
 dc.w $080B,$0906
 dc.w $080B,$0906
 dc.w $080B,$0906
 dc.w $080B,$0906
 dc.w $080B,$0906
 dc.w $080B,$0907
 dc.w $080B,$0907
 dc.w $080B,$0907
 dc.w $080B,$0907
 dc.w $080B,$0907
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0908
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080B,$0909
 dc.w $080C,$0900
 dc.w $080C,$0901
 dc.w $080C,$0902
 dc.w $080C,$0903
 dc.w $080C,$0903
 dc.w $080C,$0904
 dc.w $080C,$0904
 dc.w $080C,$0904
 dc.w $080C,$0905
 dc.w $080C,$0905
 dc.w $080C,$0906
 dc.w $080C,$0906
 dc.w $080C,$0906
 dc.w $080C,$0906
 dc.w $080C,$0906
 dc.w $080C,$0907
 dc.w $080C,$0907
 dc.w $080C,$0907
 dc.w $080C,$0907
 dc.w $080C,$0907
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0908
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$0909
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080C,$090A
 dc.w $080D,$0900
 dc.w $080D,$0901
 dc.w $080D,$0901
 dc.w $080D,$0902
 dc.w $080D,$0902
 dc.w $080D,$0903
 dc.w $080D,$0903
 dc.w $080D,$0904
 dc.w $080D,$0904
 dc.w $080D,$0905
 dc.w $080D,$0905
 dc.w $080D,$0906
 dc.w $080D,$0906
 dc.w $080D,$0907
 dc.w $080D,$0907
 dc.w $080D,$0907
 dc.w $080D,$0907
 dc.w $080D,$0907
 dc.w $080D,$0908
 dc.w $080D,$0908
 dc.w $080D,$0908
 dc.w $080D,$0908
 dc.w $080D,$0908
 dc.w $080D,$0908
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$0909
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080D,$090A
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080C,$090C
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090B
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080D,$090C
 dc.w $080E,$0906
 dc.w $080E,$0906
 dc.w $080E,$0907
 dc.w $080E,$0907
 dc.w $080E,$0907
 dc.w $080E,$0908
 dc.w $080E,$0908
 dc.w $080E,$0908
 dc.w $080E,$0908
 dc.w $080E,$0908
 dc.w $080E,$0909
 dc.w $080E,$0909
 dc.w $080E,$0909
 dc.w $080E,$090A
 


	;**********************************************************
	;	Distorted scroller by Gunstick



mdistgraph	equ	*+2*16	;the scroller graphics buffer -> bss
;	rept	300/13
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$114,$007,$007
	dc.w	$113,$114,$225,$447,$447,$114,$007,$007
	dc.w	$113,$114,$225,$447,$447,$114,$007,$007
	dc.w	$113,$114,$225,$447,$447,$114,$007,$007

	dc.w	$113,$114,$225,$447,$114,$007,$113,$007
	dc.w	$113,$114,$225,$447,$114,$007,$113,$007
	dc.w	$113,$114,$225,$447,$114,$007,$113,$007
	dc.w	$113,$114,$225,$447,$114,$007,$113,$007

	dc.w	$113,$114,$225,$114,$007,$113,$114,$007
	dc.w	$113,$114,$225,$114,$007,$113,$114,$007
	dc.w	$113,$114,$225,$114,$007,$113,$114,$007
	dc.w	$113,$114,$225,$114,$007,$113,$114,$007

	dc.w	$113,$114,$114,$007,$113,$225,$114,$007
	dc.w	$113,$114,$114,$007,$113,$225,$114,$007
	dc.w	$113,$114,$114,$007,$113,$225,$114,$007
	dc.w	$113,$114,$114,$007,$113,$225,$114,$007

	dc.w	$113,$114,$007,$113,$225,$447,$114,$007
	dc.w	$113,$114,$007,$113,$225,$447,$114,$007
	dc.w	$113,$114,$007,$113,$225,$447,$114,$007
	dc.w	$113,$114,$007,$113,$225,$447,$114,$007

	dc.w	$113,$007,$113,$225,$447,$447,$114,$007
	dc.w	$113,$007,$113,$225,$447,$447,$114,$007
	dc.w	$113,$007,$113,$225,$447,$447,$114,$007
	dc.w	$113,$007,$113,$225,$447,$447,$114,$007

	dc.w	$003,$113,$225,$447,$447,$447,$114,$007
	dc.w	$003,$113,$225,$447,$447,$447,$114,$007
	dc.w	$003,$113,$225,$447,$447,$447,$114,$007
	dc.w	$003,$113,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007
	dc.w	$113,$114,$225,$447,$447,$447,$114,$007

	dc.w	$300,$400,$600,$700,$700,$700,$600,$300
	dc.w	$300,$400,$600,$700,$700,$700,$600,$300
	dc.w	$300,$400,$600,$700,$700,$700,$600,$300
	dc.w	$300,$400,$600,$700,$700,$700,$600,$300
;	endr
	rept	300/5
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000

	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000

	dc.w	$700,$000,$000,$000,$070,$000,$000,$000
	dc.w	$700,$000,$000,$000,$070,$000,$000,$000
	dc.w	$700,$000,$000,$000,$070,$000,$000,$000
	dc.w	$700,$000,$000,$000,$070,$000,$000,$000
	
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000

	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000
	dc.w	$700,$000,$000,$000,$000,$000,$000,$000

	endr

	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005

	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	dc.w	$005,$006,$007,$337,$337,$007,$006,$005
	
mdistcurv:
	rept	35
	dc.w	0,0,0,0,2,2,2,4,4,6,6,8,8,8,10,10,10,10,10,10,8,8,8,6,6,4,4,2,2,2,2,0
	endr
	dc.w	0,2,4,6,8,10,12,14

mbounceptr:
	dc.l	mbouncetab
mbouncetab:
	dc.w	2*0,2*0,2*1,2*0,2*1,2*1,2*2,2*1,2*2,2*2
	dc.w	2*3,2*3,2*3,2*4,2*4,2*5,2*6,2*5,2*4,2*4
	dc.w	2*3,2*3,2*3,2*2,2*2,2*1,2*2,2*1,2*1,2*1
	dc.w	-1

hwbounceptr:	dc.l	hwbouncetab
hwbouncetab:
;	dc.w	0,0,0,0,0,0,-1
;	dc.w	0,0,230,230,230*2,230,230,0,0,-1
;	dc.w	230*12,230*12
;	dc.w	230*12,230*12
	dc.w	230*12
	dc.w	230*12
	dc.w	230*12
	dc.w	230*12
	dc.w	230*12
	dc.w	230*12
	dc.w	230*12,230*12
	dc.w	230*11,230*11
	dc.w	230*10,230*10
	dc.w	230*9,230*9
	dc.w	230*8,230*8
	dc.w	230*7
	dc.w	230*7
	dc.w	230*6
	dc.w	230*6
	dc.w	230*5
	dc.w	230*4
	dc.w	230*3
	dc.w	230*2
	dc.w	0
	dc.w	230*2
	dc.w	230*3
	dc.w	230*4
	dc.w	230*5
	dc.w	230*6,230*6
	dc.w	230*7,230*7
	dc.w	230*8,230*8
	dc.w	230*9,230*9
	dc.w	230*10,230*10
	dc.w	230*11,230*11
	dc.w	230*12,230*12
	dc.w	230*12,230*12
	dc.w	-1
scrbase	equ	0
scrnadrs:
	dc.l	screen-scrbase*230+64400*0
	dc.l	screen-scrbase*230+64400*1
	dc.l	screen-scrbase*230+64400*2
	dc.l	screen-scrbase*230+64400*3
	dc.l	screen-scrbase*230+64400*0+230*20
	dc.l	screen-scrbase*230+64400*1+230*20
	dc.l	screen-scrbase*230+64400*2+230*20
	dc.l	screen-scrbase*230+64400*3+230*20
	dc.l	screen-scrbase*230+64400*0+230*40
	dc.l	screen-scrbase*230+64400*1+230*40
	dc.l	screen-scrbase*230+64400*2+230*40
	dc.l	screen-scrbase*230+64400*3+230*40
	dc.l	screen-scrbase*230+64400*0+230*60
	dc.l	screen-scrbase*230+64400*1+230*60
	dc.l	screen-scrbase*230+64400*2+230*60
	dc.l	screen-scrbase*230+64400*3+230*60
	dc.l	screen-scrbase*230+64400*0+230*80
	dc.l	screen-scrbase*230+64400*1+230*80
	dc.l	screen-scrbase*230+64400*2+230*80
	dc.l	screen-scrbase*230+64400*3+230*80
	dc.l	screen-scrbase*230+64400*0+230*100
	dc.l	screen-scrbase*230+64400*1+230*100
	dc.l	screen-scrbase*230+64400*2+230*100
	dc.l	screen-scrbase*230+64400*3+230*100
	dc.l	screen-scrbase*230+64400*0+230*120
	dc.l	screen-scrbase*230+64400*1+230*120
	dc.l	screen-scrbase*230+64400*2+230*120
	dc.l	screen-scrbase*230+64400*3+230*120
	dc.l	screen-scrbase*230+64400*0+230*140
	dc.l	screen-scrbase*230+64400*1+230*140
	dc.l	screen-scrbase*230+64400*2+230*140
	dc.l	screen-scrbase*230+64400*3+230*140
	dc.l	screen-scrbase*230+64400*0+230*160
	dc.l	screen-scrbase*230+64400*1+230*160
	dc.l	screen-scrbase*230+64400*2+230*160
	dc.l	screen-scrbase*230+64400*3+230*160
	dc.l	screen-scrbase*230+64400*0+230*180
	dc.l	screen-scrbase*230+64400*1+230*180
	dc.l	screen-scrbase*230+64400*2+230*180
	dc.l	screen-scrbase*230+64400*3+230*180
	dc.l	screen-scrbase*230+64400*0+230*200
	dc.l	screen-scrbase*230+64400*1+230*200
	dc.l	screen-scrbase*230+64400*2+230*200
	dc.l	screen-scrbase*230+64400*3+230*200
	dc.l	screen-scrbase*230+64400*0+230*220
	dc.l	screen-scrbase*230+64400*1+230*220
	dc.l	screen-scrbase*230+64400*2+230*220
	dc.l	screen-scrbase*230+64400*3+230*220
	dc.l	screen-scrbase*230+64400*0+230*240
	dc.l	screen-scrbase*230+64400*1+230*240
	dc.l	screen-scrbase*230+64400*2+230*240
	dc.l	screen-scrbase*230+64400*3+230*240
	dc.l	screen-scrbase*230+64400*0+230*260
	dc.l	screen-scrbase*230+64400*1+230*260
	dc.l	screen-scrbase*230+64400*2+230*260
;	dc.l	screen-scrbase*230+64400*3+230*260
;	dc.l	screen-scrbase*230+64400*0+230*280
	dc.l	0
openlowtab:
;	dc.b	2,2,2,2,2,2
;	dc.b	2,2,2,2,2,2
;	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,0,2,2	;old
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,0,2,2,2,2	;new
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2	;
	dc.b	2,2,2,2,2,2	;nynyyy
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2	;super-full: 222202

	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2
	dc.b	2,2,2,2,2,2

	even
wavetab:
;	dc.l	byteschief,0
	dc.l	wordschief
	dc.l	wordschief
	dc.l	wordschief
	dc.l	byteschief
	dc.l	nix
	dc.l	wordhinher
	dc.l	nix
	dc.l	nix
	dc.l	hacker,hacker,hacker
	dc.l	dreieck
	dc.l	dreieck
	dc.l	slowdist,slowdist,slowdist,slowdist
	dc.l	hacker,hacker,hacker
	dc.l	sinus
	dc.l	sinus
	dc.l	sinschief
	dc.l	sinschief
	dc.l	bigsin
	dc.l	bigsin
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinus
	dc.l	sinus
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	bytezurueck
	dc.l	wordschief
	dc.l	wordschief
	dc.l	wordschief
	dc.l	0	;end

mwavetab:
	dc.l	sinschief
	dc.l	sinschief
	dc.l	bigsin
	dc.l	fuzzy,fuzzy,fuzzy,fuzzy
	dc.l	fuzzy,fuzzy,fuzzy,fuzzy
	dc.l	fuzzy,fuzzy,fuzzy,fuzzy
	dc.l	fuzzy,fuzzy,fuzzy,fuzzy
	dc.l	bigsin
	dc.l	bigsin
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	slowdist
	dc.l	wordschief
	dc.l	0	;end

hacker:
	dc.w	2-1,-2,2,-2,2,-2,2,-2-1
	dc.w	4,-4,4,-4,4,-4,4,-4-1
	dc.w	6,-6,6,-6,6,-6,6,-6-1
	dc.w	8,-8,8,-8,8,-8,8,-8-3
	dc.w	12,-12,12,-12,12,-12,12,-12-1
	dc.w	14,-14,14,-14,14,-14,14,-14-1
	dc.w	16,-16,16,-16,16,-16,16,-16
	dc.w	16,-16,16,-16,16,-16,16,-16+1
	dc.w	14,-14,14,-14,14,-14,14,-14+1
	dc.w	12,-12,12,-12,12,-12,12,-12+3
	dc.w	8,-8,8,-8,8,-8,8,-8+1
	dc.w	6,-6,6,-6,6,-6,6,-6+1
	dc.w	4,-4,4,-4,4,-4,4,-4+1
	dc.w	2,-2,2,-2,2,-2,2,-2+1
	dc.w	128
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,16
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,-16
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,16
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,-16
	dc.w	128
slowdist:
	dc.w	0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
	dc.w	0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2
	dc.w	1,2,1,2,1,2,1,2,2,2,2,2,2,2,2,2
	dc.w	2,2,2,3,2,2,2,3,2,3,2,3,2,3,2,3
	dc.w	3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
	dc.w	2,3,2,3,2,3,2,3,2,2,2,3,2,2,2,3
	dc.w	2,2,2,2,2,2,2,2,1,2,1,2,1,2,1,2
	dc.w	1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2
	dc.w	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.w	0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1
	dc.w	0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
	dc.w	0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,-1,0,0,0,-1
	dc.w	0,0,0,-1,0,0,0,-1
	dc.w	0,-1,0,-1,0,-1,0,-1
	dc.w	0,-1,0,-1,0,-1,0,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-2,-1,-1,-1,-2
	dc.w	-1,-2,-1,-2,-2,-2,-2,-2
	dc.w	-2,-2,-2,-3,-2,-3,-2,-3
	dc.w	-3,-3,-3,-3,-3,-3,-3,-3
	dc.w	-2,-3,-2,-3,-2,-2,-2,-3
	dc.w	-2,-2,-2,-2,-1,-2,-1,-2
	dc.w	-1,-1,-1,-2,-1,-1,-1,-2
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,-1,0,-1,0,-1,0,-1
	dc.w	0,-1,0,-1,0,-1,0,-1
	dc.w	0,0,0,-1,0,0,0,-1
	dc.w	0,0,0,-1,0,0,0,-1
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	128

bytezurueck:
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	128
sinschief:
	dc.w	0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1
	dc.w  0,0,1,0,0,1,0,0,2,0,0,1,0,0,1,0,0,2,0,0,2,0,0,2,0,0,2,0,0,1,0,0,1
	dc.w 0,0,2,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,128

wordhinher:
	dc.w	2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w	-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,-2,128
wordschief:
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,128
	dc.w	0
	dc.w	3,2,2,2,2,2,2,2,128
byteschief:
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1,128
hops1:	dc.w	1
nix:	dc.w	0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.w	0,128
dreieck:
	dc.w	1,0,1,0,1,0,1,0
	dc.w	1,0,1,0,1,0,1,0
	dc.w	1,0,1,0,1,0,1,0
	dc.w	1,0,1,0,1,0,1,0
	dc.w	1,1,1,1,1,1,1,1
	dc.w	-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1
	dc.w	-1,0,0,-1,0,0,-1,0,0,-1,0,0,-1,128
	
	dc.w	2,2,2,2,2,2,2,2
	dc.w	1,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,1,0,0,0,0
	dc.w	0,0,-3,-2,-1,0,1,2
	dc.w	1,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,-1
	dc.w	-1,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,1
	dc.w	2,2,2,2,2,2,2,2
	dc.w	3,3,3,3,3,3,3,3
	dc.w	3,3,3,3,3,3,3,3
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	5,5,5,5,5,5,5,5
	dc.w	5,5,5,5,5,5,5,5
	dc.w	5,5,5,5,5,5,5,5
	dc.w	5,5,5,5,5,5,5,5
	dc.w	5,5,5,5,5,5,5,5
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	3,3,3,3,3,3,3,3
	dc.w	3,3,3,3,3,3,3,3
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-2,-2,-2,-2,-2,-2,-2,-2
	dc.w	-3,-3,-3,-3,-3,-3,-3,-3
	dc.w	-3,-3,-3,-3,-3,-3,-3,-3
	dc.w	-4,-4,-4,-4,-4,-4,-4,-4
	dc.w	-4,-4,-4,-4,-4,-4,-4,-4
	dc.w	-4,-4,-4,-4,-4,-4,-4,-4
	dc.w	-4,-4,-4,-4,-4,-4,-4,-4
	dc.w	-4,-4,-4,-4,-4,-4,-4,-4
	dc.w	-3,-3,-3,-3,-3,-3,-3,-3
	dc.w	-3,-3,-3,-3,-3,-3,-3,-3
	dc.w	-2,-2,-2,-2,-2,-2,-2,-2
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	0,0,0,0,0,0,0,0,128
	dc.w	16,16,16,16,16,16,16,16
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	128	
sinus:
	dc.w	1,0,0,1,0,0,1,0,0,1,0,0,2,0,0,1,0,0,2,0,0,1,0,0,2,0,0,2
	dc.w	0,0,2,0,0,2,0,0,3,0,0,2,0,0,3,0,0,2,0,0,3,0,0,3,0,0,3,0,0,3
	dc.w	2,0,0,3,0,0,2,0,0,3,0,0,2,0,0,2,0,0,2,0,0,2,0,0,1,0,0,2,0,0,1,0,0,1,0,0,1,0,0,1
	dc.w	0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-1,0,0,0,0,0,-1,0,0,0,0,0,-1
	dc.w	-1,0,0,-1,0,0,-1,0,0,-2,0,0,-1,0,0,-2,0,0,-1,0,0,-2,0,0,-2,0,0,-2,0,0,-3,0,0,-2
	dc.w	-3,0,0,-3,0,0,-3,0,0,-2,0,0,-3,0,0,-2,0,0,-2,0,0,-2,0,0,-1,0,0,-2,0,0,-1,0,0,-1,0,0,-1,0,0,-1,0,0,0,0,0,-1,0,0,0,0,0,0
	dc.w	128
bigsin:	dc.w	1,0,0,1,0,0,1,1,1,2,1,1,2,1,1,2,2,2,3,2,2,3,3,3,3,3,3
	dc.w	3,3,3,3,3,3,3,3,2,3,3,2,2,2,1,2,2,1,1,1,0
	dc.w	0,0,0,-1,0,0,-1,-1,-1,-2,-1,-1,-2,-2,-2,-3,-2,-2,-3,-3,-3
	dc.w	-3,-3,-3,-3,-3,-3
	dc.w	-3,-2,-2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,-1,0,0,-1,0,0,0,0,0,128
fuzzy
	dc.w	0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7
	dc.w	8,8,8,8,9,9,9,9,10,10,10,10,11,11,11,11,12,12,12,12,13,13,13,13
	dc.w	14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18
	dc.w	19,19,19,19,20,20,20,20,21,21,21,21,22,22,22,22,23,23,23,23
	dc.w	128
zero	equ	1
one	equ	3
two	equ	5
three	equ	7
four	equ	9
five	equ	11
six	equ	13
seven	equ	15
eight	equ	17
nine	equ	19
dp	equ	21
sp	equ	23
ka	equ	25
mi	equ	27
kz	equ	29
fz	equ	31
az	equ	33
a	equ	35
b	equ	37
c	equ	39
d	equ	41
e	equ	43
f	equ	45
g	equ	47
h	equ	49
i	equ	51
j	equ	53
k	equ	55
l	equ	57
m	equ	59
n	equ	61
o	equ	63
p	equ	65
q	equ	67
r	equ	69
s	equ	71
t	equ	73
u	equ	75
v	equ	77
w	equ	79
x	equ	81
y	equ	83
z	equ	85
space	equ	87
;Panic buffer for scrolltext
	dc.b	01,0,0,0,0,0,0,0,0,01,0,0,01,0,0,01,0,0,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01

	dc.b	r,r+1,e,e+1,s,s+1,p,p+1,e,e+1,c,c+1,t,t+1,a,a+1,b,b+1,l,l+1,e,e+1,s,s+1,space,ka,ka+1,h,h+1,a,a+1,v,v+1,e,e+1,space,i,i+1,space
	dc.b	g,g+1,o,o+1,t,t+1,space,t,t+1,h,h+1,e,e+1,space,n,n+1,a,a+1,m,m+1,e,e+1,space,r,r+1,i,i+1,g,g+1,h,h+1,t,t+1,fz,fz+1,kz,kz+1,space
	dc.b	e,e+1,n,n+1,o,o+1,u,u+1,g,g+1,h,h+1,space,f,f+1,o,o+1,r,r+1,space,n,n+1,o,o+1,w,w+1,space,space,space,space
	dc.b	b,b+1,y,y+1,e,e+1,space,az,az+1
	
	dc.b	space,space,space
scrolltext:
;	dc.b	zero,zero,zero,zero,zero,zero,zero,zero,0
	dc.b	space,space,space,h,h+1,e,e+1,l,l+1,l,l+1,o,o+1,space,space
	dc.b	t,t+1,h,h+1,i,i+1,s,s+1,space,space,i,i+1,s,s+1,space,space
	dc.b	g,g+1,u,u+1,n,n+1,s,s+1,t,t+1,i,i+1,c,c+1,k,k+1,space,s,s+1
	dc.b	space,space,space,r,r+1,e,e+1,v,v+1,o,o+1,l,l+1,u,u+1,t,t+1,i,i+1,o,o+1
	dc.b	n,n+1,a,a+1,r,r+1,y,y+1,space,space,f,f+1,u,u+1,l,l+1,l,l+1,mi,mi+1
	dc.b	s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1,mi,mi+1,s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1
	dc.b	space,az,az+1,az,az+1,space,space,space
	dc.b	n,n+1,o,o+1,b,b+1,o,o+1,d,d+1,y,y+1
	dc.b	space,space,c,c+1,a,a+1,n,n+1,space,space,b,b+1,e,e+1,a,a+1,t,t+1
	dc.b	space,space,u,u+1,space,l,l+1,space,m,m+1,space,az,az+1,az,az+1,az,az+1
	dc.b	t,t+1,h,h+1,i,i+1,s,s+1,space,s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1,space,n,n+1,e,e+1,e,e+1,d,d+1,e,e+1,d,d+1,space
	dc.b	o,o+1,v,v+1,e,e+1,r,r+1,space,one,one+1,space,m,m+1,o,o+1,n,n+1,t,t+1,h,h+1,space
	dc.b	f,f+1,u,u+1,l,l+1,l,l+1,t,t+1,i,i+1,m,m+1,e,e+1,space,c,c+1,o,o+1,d,d+1,i,i+1,n,n+1,g,g+1,az,az+1,space
	dc.b	b,b+1,u,u+1,t,t+1,space,b,b+1,e,e+1,c,c+1,a,a+1,u,u+1,s,s+1,e,e+1,space,o,o+1,f,f+1,space
	dc.b	t,t+1,h,h+1,e,e+1,space,s,s+1,c,c+1,h,h+1,o,o+1,o,o+1,l,l+1,space,i,i+1,t,t+1,space
	dc.b	t,t+1,o,o+1,o,o+1,k,k+1,space,m,m+1,e,e+1,space,h,h+1,a,a+1,l,l+1,f,f+1,space
	dc.b	a,a+1,space,y,y+1,e,e+1,a,a+1,r,r+1,az,az+1,space,i,i+1,space,h,h+1,o,o+1,p,p+1,e,e+1,space
	dc.b	i,i+1,t,t+1,space,w,w+1,i,i+1,l,l+1,l,l+1,space,b,b+1,e,e+1,space,t,t+1,h,h+1,e,e+1,space
	dc.b	b,b+1,e,e+1,s,s+1,t,t+1,space,f,f+1,u,u+1,l,l+1,l,l+1,s,s+1,c,c+1,e,e+1,n,n+1,space
	dc.b	d,d+1,i,i+1,s,s+1,t,t+1,o,o+1,r,r+1,t,t+1,e,e+1,r,r+1,space,e,e+1,v,v+1,e,e+1,r,r+1,space,d,d+1,o,o+1,n,n+1,e,e+1,space,az,az+1,space,space
	dc.b	g,g+1,r,r+1,e,e+1,e,e+1,t,t+1,i,i+1,n,n+1,g,g+1,s,s+1,space,t,t+1,o,o+1,space,m,m+1,y,y+1,space
	dc.b	b,b+1,e,e+1,s,s+1,t,t+1,space,f,f+1,r,r+1,i,i+1,e,e+1,n,n+1,d,d+1,s,s+1,dp,dp+1,space
	dc.b	t,t+1,h,h+1,e,e+1,space,l,l+1,o,o+1,s,s+1,t,t+1,space,b,b+1,o,o+1,y,y+1,s,s+1,space
	dc.b	ka,ka+1,g,g+1,i,i+1,v,v+1,e,e+1,space,m,m+1,e,e+1,space,a,a+1,l,l+1,l,l+1,space
	dc.b	y,y+1,o,o+1,u,u+1,r,r+1,space,s,s+1,l,l+1,o,o+1,w,w+1,space,r,r+1,o,o+1,u,u+1,t,t+1,i,i+1,n,n+1,e,e+1,s,s+1,space
	dc.b	i,i+1,space,w,w+1,i,i+1,l,l+1,l,l+1,space,o,o+1,p,p+1,t,t+1,i,i+1,m,m+1,i,i+1,z,z+1,e,e+1,space,t,t+1,h,h+1,e,e+1,m,m+1,kz,kz+1,space
	dc.b	r,r+1,e,e+1,s,s+1,p,p+1,e,e+1,c,c+1,t,t+1,a,a+1,b,b+1,l,l+1,e,e+1,s,s+1,space,ka,ka+1,h,h+1,a,a+1,v,v+1,e,e+1,space,i,i+1,space
	dc.b	g,g+1,o,o+1,t,t+1,space,t,t+1,h,h+1,e,e+1,space,n,n+1,a,a+1,m,m+1,e,e+1,space,r,r+1,i,i+1,g,g+1,h,h+1,t,t+1,fz,fz+1,kz,kz+1,space
	dc.b	e,e+1,n,n+1,o,o+1,u,u+1,g,g+1,h,h+1,space,f,f+1,o,o+1,r,r+1,space,n,n+1,o,o+1,w,w+1,space,space,space,space
	dc.b	b,b+1,y,y+1,e,e+1,space,az,az+1
	
	dc.b	space,space,space
	dc.b	0
	dc.b	87,87
	dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20
	dc.b	21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
	dc.b	41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60
	dc.b	61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80
	dc.b	81,82,83,84,85,86,87
	dc.b	0
	even
	;**********************************************************


	;**********************************************************

prt:
	dc.b 27,"Y",32+20,32+1,"     000"
str:	dc.b "0    ",0



	even
psginittab:dc.b 0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b 7,$7f,8,7,9,7,10,7,$ff,0
	even
hwpalette:
	dc.w $777,$666,$555,$444,$333,$222,$111,$002 
	dc.w $0700,$0707,$0474,$0777,$0606,$0505,$0404,$303
graphic:
	dc.w $d555,$3333,$0f0f,$ff
message:
	dc.b 0
	even
lowbyte:
	dc.b 0

	
hwscrolldat:			

	incbin	"includes\hwscroll.dat"
	even
black:
	ds.l 8

	section	bss
stack:	ds.l 1
oldpal: ds.w 16
oldres: ds.w 1
screenad1:ds.w 1
screenad2:ds.l 1
screenadr:ds.l 1
digswitch:	ds.w	1	;use digi1 or digi2
logbase:	ds.l	1	;screen where to put scroll
tabentry:
	ds.l	1	;for hwscroll
cpybufdest:
	ds.l	1	;copy from (this+4buffers-1scroll) to (this) 
shiftcnt:
	ds.w	1	;counter for shifter
count:
	ds.l	1	;for some dbf without register
nextscrn:	
	ds.l	1	;points to next screenadress to be used
distcalc:
	ds.w	1
distwaveptr:
	ds.l	1	;pointer in one distwave
wavetabptr:
	ds.l	1	;pointer to the next wave to be played

disttableptr:
	ds.l	1	;pointer to scrolldisttable
disttable:
	ds.w	20*2	;scrolldisttable
digiptr:
	ds.l	1	;ptr to begin digi after vbl
predigi:
	ds.l	40	;40 lines predigitized (20*2 values)
mactcurv:
	ds.l	1	;ptr in active curve
mnextcurv:
	ds.l	1	;next mdist curv
mdistcurvval:
	ds.w	1	;curve
mdistcurvptr:
	ds.l	1
mdistadjustptr:
	ds.l	1	;pointer to the distorter adjust table
mdistadjust:
	ds.w	300*2	;adjusttable for the two distorters

linebuffbegin:
textptr:
	ds.l	1	;letter not completly copied into buffer (forward)
bufptr:
	ds.l	1	;pos where graphic is added in preshift 0
bufcnt:
	ds.w	1	;which one of the 26 routs to be used to copy
shift:
	ds.w	1	;which preshift to copy
buffer:
	ds.l	2*26*16	;16 shifts of the 1st line of the scrolling
linebuffend:
	rept	scrhigh-1	;18 lines scroll
;	ds.l	1
;	ds.l	1
;	ds.w	1
;	ds.w	1
	ds.l	2*26*16+1+1+1
	endr

	ds.w	230*6
screen: 
	rept	5
	ds.l 	15700
	endr
endprg:
	end





