overscan:equ 0
;cpy8: adjust all offsets by -2
; Double Megadistorter by Gunstick   (c) ULM 1990

;free d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6 a7 usp

	pea	start(pc)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1

start:
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
	trap	#14
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
	bsr.s	waitvbl
	move.b	#26,$fffffc02.w

	bsr	screen2

	move.b	#20,$fffffc02.w
	bsr.s	waitvbl
	move.b	#8,$fffffc02.w

	bsr.s	waitvbl
	move.b	#2,$ffff820a.w
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
	trap	#14
	lea	12(sp),sp

	bsr.s	psginit

	lea	oldpal,a0
	lea	$ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)

	bsr.s	waitvbl

	rts

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

screen2:

;free d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6    usp
	move	sr,-(sp)
	move	#$2700,sr
	move.l	sp,stack
;	clr.b	lowbyte
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
	move.l	#scrnadrs,nextscrn
	move.l	#screen-230*20,cpybufdest

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

	lea	screenadr,a3
;	move.b	lowbyte,3(a3)

	bsr	waitvbl		;lower border
	move.w	#4000,d0
firsttopwait:
	dbf	d0,firsttopwait
	;move.b	#0,$ffff820a.w

;ULM Hardware Scrolling PART 1
;THIS PART IS TO BE STARTED BEFORE THE BEGINNING OF THE VBL
;sets screen to adress contained in screenadr+(6 scanlines)

	lea	screenadr,a3	;~12
	moveq	#0,d1		;~4
	move.b	3(a3),d1	;~12
	move.w	d1,d0		;~4
	add.w	d1,d1		;~4
	add.w	d0,d1		;~4
	add.w	d1,d1		;~4
	add.w	d1,d1		;~4    *12 (24 byte per tabentry)
	lea	$ffff8201.w,a1	;~8
	lea	hwscrolldat,a0	;~12
	add.w	d1,a0		;~8
	movep.w 1(a3),d1	;~16
	move.b	2(a3),d1	;~12
	move.b	(a0)+,d0	;~8
	ext.w	d0		;~4
	add.w	d0,d1		;~4
	movep.w d1,0(a1)	;~16
	move.l	a0,tabentry-screenadr(a3)	;~16 save tablepos
;ULM Hardware Scrolling END OF PART 1

loop:

	bsr	waitvbl

	movem.l black,d0-d7
	movem.l d0-d7,$ffff8240.w
	movem.l hwpalette,d2-d7/a2-a3
	lea	$ffff8209.w,a1
	moveq	#10,d1
	movea.l tabentry,a0	;get back tablepos


	move.w	#1500,d0
opentopwait:
	dbra	d0,opentopwait
	dcb	$4e71,196-72-2
	move.b	#0,$ffff820a.w
;	move.w	#$007,$ffff8240.w
	dcb	$4e71,8
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
	dcb	$4e71,3
;	move.b	#2,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	tst.b	(a0)+
	bne.s	links1
	move.b	#2,$ffff820a.w
	dcb	$4e71,19		;-4*2
	bra.s	cont1

links1:
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;links1:
	move.b	#2,$ffff820a.w
	dcb	$4e71,5
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
	dcb	$4e71,33
	tst.b	(a0)+
	bne.s	rechts1
	tst.b	(a0)+
	bne.s	rechts2
	dcb	$4e71,7
	bra.s	cont4

rechts1:
	move.b	#0,$ffff820a.w
	addq.w	#1,a0
	dcb	$4e71,4
	bra.s	cont4

rechts2:
	dcb	$4e71,4
	move.b	#0,$ffff820a.w
	nop
cont4:
	dbra	d0,switchloop
	move.b	#2,$ffff820a.w
;HERE WE ARE SYNCHRON
;These lines are to be used if the screen uses left border

	dcb	$4e71,3
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l d2-d4,$ffff8240.w
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	movem.l d5-d7/a2-a3,12+$ffff8240.w
	;**********************************************************
	;	Distorted scroller by Gunstick
	;INITIALISATIONS
	;***** Calc next screenadress ****

	;free: d0 d1 d2 d3 d4 d5 d6 d7 a0 a1 a2 a3 a4 a5 a6    usp
	lea	nextscrn,a3	;~12
	move.l	(a3),a0		;~20
	move.l	(a0)+,d0		;~12
	bne	scrnok			;~12
	lea	scrnadrs-nextscrn(a3),a0		;~12
	move.l	(a0)+,d0		;~12
;	move.l	#screen-(20*230)+160*6,cpybufdest-nextscrn(a3);~24
	dcb	$4e71,6
_scrnok:
	move.l	d0,logbase-nextscrn(a3)		;~20
	move.l	a0,(a3)		;~20


	;do some hardwarebouncing
	move.l	hwbounceptr-nextscrn(a3),a0		;~20
	move.w	(a0)+,d1		;~8
	bne.s	hwbounceok		;~8
	lea	hwbouncetab-nextscrn(a3),a0		;~8
	move.w	(a0)+,d1		;~8
_hwbounceok:
	move.l	a0,hwbounceptr-nextscrn(a3)		;~16
	ext.l	d1			;~4
	add.l	d1,d0			;~8
	move.l	d0,screenadr-nextscrn(a3);~16
; 	dcb	$4e71,4

	;free: d0-a6/usp


	dcb	$4e71,4+4-6
	dcb	$4e71,25-23
	dcb	$4e71,17

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
	dcb	$4e71,5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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
a_3	equr	a3

distspeed 	equ	5
disthigh	equ	20
;copy (disthigh-distspeed)/2 registers
	movem.l	disttable+distspeed*2,d1-d7/a1	;copy disttab
	movem.l	d1-d7/a1,disttable

	

	dcb	$4e71,25
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	dcb	$4e71,27

	lea	disttable+disthigh*2-distspeed*2,a_3	;position to write new
	move.l	distwaveptr,a_0		;position in the actual wave
	moveq	#distspeed-1,d_0	;read 8
	moveq	#0,d_3
	move.w	distcalc,d_2


distwaveread:
	;free: d4-d7/a2/a4-a6/usp
	dcb	$4e71,17	;mdist
	dcb	$4e71,25	;digi
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
	dcb	$4e71,3
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	cmp.w	#128,d_1	;~8
	bne.s	notnextwavetab	;~8
	move.l	wavetabptr,a_1	;~20 next wave to be read
	tst.l	(a_1)		;~12
	bne.s	notendwavetab	;~8
	lea	wavetab,a_1	;~12 reset wavetabptr
	nop
_notendwavetab:
	move.l	(a_1)+,a_0	;~12
	move.w	(a_0)+,d_1	;~12
	move.l	a_1,wavetabptr	;~20
_notnextwavetab:
	add.w	d_1,d_3		;~4
	add.w	d_1,d_2		;~4
	sub.w	16(a_3),d_2	;~16
	move.w	d_1,16(a_3)	;~12
	move.w	d_2,(a_3)+	;~8 write new curve

	dbf	d_0,distwaveread	;~12/16

	;free: d1-d2/d4-d7/a0-a6/usp
	dcb	$4e71,24	;digi
	dcb	$4e71,17	;mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	move.l	a_0,distwaveptr	;~20
	move.w	d_3,distcalc	;~16

	lea	disttable+4,a_3 ;~12 scroll begins 18 lines before end of screen
	lea	shift,a_0	;~12 pointer to the shifts
	move.w	#-(18*8),count	;~20 scroll has 18 lines
distcalcloop:	;(~12)

	;free: d0/d3-d7/a1-a2/a4-a6/usp  cpy:d0/d3/a1/a2
	move.w	(a_3)+,d_1	;~8
	move.w	(a_0),d_2	;~8	;read shift
	add.w	d_1,d_2		;~4
	bmi	rueckwaerts	;~12
	sub.w	#16,d_2		;~8
	bhs	vorwaerts	;~12
	add.w	#16,d_2		;~8	
	move.w	d_2,(a_0)	;~8	;write back new shift
	dcb	$4e71,4-2
	moveq	#7,d_2
noshift:
	nop
	;free: d0/d3-d7/a1-a2/a4-a6/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	dcb	$4e71,41-4
	dbf	d_2,noshift
	
indistcalcloop:
	;free: d0/d3-d7/a1-a2/a4-a6/usp  cpy:d0/d3/a1/a2
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	dcb	$4e71,10


	lea	linebuffend-linebuffbegin(a_0),a_0	;~8 next line
	addq.w	#8,count	;~4
	bne	distcalcloop	;~12

	dcb	$4e71,41-20


	;free: d0-a6/usp  
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#0,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	move.b	#2,$ffff820a.w

;ULM Hardware Scrolling PART 1
;THIS PART IS TO BE STARTED BEFORE THE BEGINNING OF THE VBL
;sets screen to adress contained in screenadr+(6 scanlines)

	lea	screenadr,a3	;~12
	moveq	#0,d1		;~4
	move.b	3(a3),d1	;~12
	move.w	d1,d0		;~4
	add.w	d1,d1		;~4
	add.w	d0,d1		;~4
	add.w	d1,d1		;~4
	add.w	d1,d1		;~4    *12 (24 byte per tabentry)
	lea	$ffff8201.w,a1	;~8
	lea	hwscrolldat-screenadr(a3),a0	;~8
	add.w	d1,a0		;~8
	movep.w 1(a3),d1	;~16
	move.b	2(a3),d1	;~12
	move.b	(a0)+,d0	;~8
	ext.w	d0		;~4
	add.w	d0,d1		;~4
	movep.w d1,0(a1)	;~16
	move.l	a0,tabentry-screenadr(a3)	;~16 save tablepos
;ULM Hardware Scrolling END OF PART 1



;	dcb	$4e71,41-4-33
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
; 	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	bra	copydistscroll

	rept 34
	dcb	$4e71,41
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	endr

	dcb	$4e71,41
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#0,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	move.b	#2,$ffff820a.w

	dcb	$4e71,41-4
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	rept	7
	dcb	$4e71,41
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
;	move.b	#2,$ffff8260.w
;	move.b	#0,$ffff8260.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	endr

	bra	copydistscroll

	dcb	$4e71,41-9



	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist


;	move.w	#221-16,d7
	move.w	#32,d7		;~8
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
overscanloop:
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	dcb	$4e71,83
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,5
	dbra	d7,overscanloop
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w


asd


	;=-| read the new distortions and shift the buffers
	; letters of font must be 256 bytes !!!!!!!!
	;-> advance this line by one word
vorwaerts:
	move.w	d_2,(a_0)	;~8 write back new shift
	move.l	textptr-shift(a_0),a_1	;~16
	dcb	$4e71,2
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont2
nottextend:			;~12
	addq.w	#1,a_1		;~8
	bra	_nottextend	;~12
cont2:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		textptr
	;		|
	;UNLIMITED MATRICKS	a bit of C appears somewhere
	;now we have to write a bit of K and C
	movep.w	0(a_1),d_1	;~16 previous letter : C
	movep.w	1(a_1),d_2	;~16 act letter	 : K
	tst.b	d_1		;~4  test letter after act : S
	bne.s	nottextend	;~8
	lea	scrolltext,a_1	;~12
	nop
	nop
	nop
_nottextend:
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to K
	clr.b	d_1		;~4 C
	clr.b	d_2		;~4 K
	lea	font+(18*8),a_1	;~8
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 C
;	lea	(a_1),a_2	;C
	movem.l	(a_1,d_2),d_1/d_3	;~36 K
;	movem.w	256(a_1),d_0/d_1/d_2/d_3	;K
	;d0:xxxxxxxxxxxxxxxx
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxxxxxxxxx
	;d3:ccccccccdddddddd
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	;d0:xxxxxxxxdddddddd
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxbbbbbbbb
	;d3:ccccccccdddddddd
	swap	d_0		;~4
	swap	d_2		;~4
	;d0:ddddddddxxxxxxxxx
	;d1:aaaaaaaabbbbbbbbb
	;d2:bbbbbbbbxxxxxxxxx
	;d3:ccccccccddddddddd
	move.l	bufptr-shift(a_0),a_1	;~16
	;prepare shifter
	move.w	(a_2)+,d_0	;~8 C
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8
	;uff one line of the 2 letters is in d0-d3
	;d0	dddddddd|AAAAAAAA
	;d1	aaaaaaaa|BBBBBBBB
	;d2	bbbbbbbb|CCCCCCCC
	;d3	cccccccc|DDDDDDDD

	dcb	$4e71,6
	dcb	$4e71,17	;mdist

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist



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
***************************************************
	dcb	$4e71,25
	dcb	$4e71,17-1-11
	moveq	#0,d7
; megadistorter test
;	lea	0(a0,d7),a0
	movem.l	(a0),d4/d5/d6/d7
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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

	;---------------------------------------

	dcb	$4e71,25-13
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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

	;---------------------------------------
	dcb	$4e71,25
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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

	;---------------------------------------
	dcb	$4e71,25-13
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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

	;---------------------------------------
	dcb	$4e71,25
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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

	;---------------------------------------
	dcb	$4e71,25-13
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

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
	;---------------------------------------

***************************************************

	dcb	$4e71,25
	dcb	$4e71,17
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l	d0/d1/d2,$ffff8250.w	;mdist
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	dcb	$4e71,38
	bra	indistcalcloop	;~12   26 nops before right borde


	;-< back this line by one word





rueckwaerts:
	add.w	#16,d_2			;~8
	move.w	d_2,(a_0)		;~8 write back new shift
	dcb	$4e71,2+7
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist


	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	bra.s	cont5
rueckbufok:
	subq.l	#8,bufptr-shift(a_0)	;~16
	DCB	$4E71,2
	bra.s	_rueckbufok		;~12
cont5:
	dcb	$4e71,5
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist


	subq.w	#4,bufcnt-shift(a_0)	;~12
	bhs.s	rueckbufok		;~8
	move.w	#25*4,bufcnt-shift(a_0)	;~16 screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)	;~32
_rueckbufok:
	move.l	textptr-shift(a_0),a_1	;~16
	dcb	$4e71,7
	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		             textptr
	;  |			     |
	;YEAH THIS IS UNLIMITED MATRICKS	a bit of C appears somewhere
	;a bit of A appears somewhere
	;now we have to write a bit of E and A 
	movep.w	-27(a_1),d_1	;~16 previous letter : E
	movep.w	-26(a_1),d_2	;~16 act letter	 : A
	lea	-1(a_1),a_1	;~8
	move.l	a_1,textptr-shift(a_0)	;~16 textptr points to I
	clr.b	d_1	;~4 E
	clr.b	d_2	;~4 A
	lea	font+(18*8),a_1	;~12
	add.w	count,a_1	;~20
	lea	(a_1,d_1),a_2	;~12 E
	movem.l	(a_1,d_2),d_1/d_3	;~36 A
	;d0:xxxxxxxxxxxxxxxx
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxxxxxxxxx
	;d3:ccccccccdddddddd
	
	dcb	$4e71,17		;mdist

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist


	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	d_1,d_2		;~4
	move.w	d_3,d_0		;~4
	;d0:xxxxxxxxdddddddd
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxbbbbbbbb
	;d3:ccccccccdddddddd
	swap	d_0		;~4
	swap	d_2		;~4
	;d0:ddddddddxxxxxxxxx
	;d1:aaaaaaaabbbbbbbbb
	;d2:bbbbbbbbxxxxxxxxx
	;d3:ccccccccddddddddd

	;prepare shifter
	move.l	bufptr-shift(a_0),a_1	;~16
	move.w	(a_2)+,d_0	;~8 E
	move.w	(a_2)+,d_1	;~8
	move.w	(a_2)+,d_2	;~8
	move.w	(a_2)+,d_3	;~8

	;uff one line of the 2 letters is in d0-d3
	;	   A	    E
	;d0	dddddddd|AAAAAAAA
	;d1	aaaaaaaa|BBBBBBBB
	;d2	bbbbbbbb|CCCCCCCC
	;d3	cccccccc|DDDDDDDD
	;write first buffer
	dcb	$4e71,5
	bra	call_shifter	


copydistscroll:
	;**** Copy all the buffers to the screen ****
	move.l	logbase,a6	;put it there
	add.l	#6*160+230*(280-20),a6	;for hwscroll
	lea	buffer,a4
	moveq	#18-5,d0		;scrollhigh:18

	dcb	$4e71,25
	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
;	move.b	#$77,$ffff8240.w
;	move.b	#0,$ffff8240.w
	dcb	$4e71,8
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	dcb	$4e71,11
scrollcpy:
	move.w	shift-buffer(a4),d1
	mulu	#208,d1
;	lea	208*15(a4),a5
	lea	(a4,d1),a5
;	move.w	#0,d1
	move.w	bufcnt-buffer(a4),d1
	lea	cpyjsr,a0
	move.l	(a0,d1),a0
;	move.l	a5,a6


	dcb	$4e71,25	;digi
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$77,$ffff8240.w
	move.b	#7,$ffff8240.w
	dcb	$4e71,6
;	NOT.W	$FFFF8240.W
   	jmp	(a0)		;(a5)+ -> (a6)   uses d1-a1
endcpy:
;	NOT.W	$FFFF8240.W
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	lea	230(a6),a6
	lea	linebuffend-linebuffbegin(a4),a4
	dbf	d0,scrollcpy
	not	$ffff8240.w


;	lea	bufcnt,a5
;	moveq	#25,d0		;scrollhigh:26
;wordscroll:
;	add.w	#4,(a5)
;	cmp.w	#4*26,(a5)
;	bne.s	notend
;	clr.w	(a5)
;notend:
;	lea	linebuffend-linebuffbegin(a5),a5
;	dbf	d0,wordscroll

;	lea	font,a0
;	move.l	logbase,a1	;put it there
;	add.l	#6*160+40,a1	;for hwscroll
;	moveq	#26,d0		;init all unshiftet linebuffers
;ttestinitbuff:
;	move.l	(a0),(a1)+
;	move.l	4(a0),(a1)+
;	move.l	26*8(a0),(a1)+
;	move.l	26*8+4(a0),(a1)+
;	addq.l	#8,a0
;	lea	230-16(a1),a1
;	dbf	d0,ttestinitbuff


	;**********************************************************
	;buffercopy
bbb
	move.l	cpybufdest,a6		;write there
	move.l	a6,a5
	add.l	#230*280*4-230*20,a5	;read here	
	rept	5
	movem.l	(a5)+,d0-d7/a0-a4	
	movem.l	d0-d7/a0-a4,(a6)
	movem.l	(a5)+,d0-d7/a0-a4	
	movem.l	d0-d7/a0-a4,52(a6)
	movem.l	(a5)+,d0-d7/a0-a4	
	movem.l	d0-d7/a0-a4,104(a6)
	movem.l	(a5)+,d0-d7/a0-a4	
	movem.l	d0-d7/a0-a4,156(a6)	;4*13*4=208:1 line copied
	lea	230(a6),a6		;next line
	lea	22(a5),a5
	endr

	move.l	a6,cpybufdest	;position to write during next vbl
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
	lea	str,a3
	move.l	#"0000",-4(a3)
	bsr	d0todeza3
	pea	prt
	move.w	#9,-(sp)
;	 trap	 #1
	addq.w	#6,sp

	bra	loop


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


exit:
	movea.l stack,sp
	move	(sp)+,sr
	rts

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
	;	Distorted scroller by Gunstick
	;The 26 copyroutines
cpyjsr:
	rept	30
	;dc.l	cpy07
	endr
	dc.l	cpy00,cpy01,cpy02,cpy03,cpy04
	dc.l	cpy05,cpy06,cpy07,cpy08,cpy09
	dc.l	cpy10,cpy11,cpy12,cpy13,cpy14
	dc.l	cpy15,cpy16,cpy17,cpy18,cpy19
	dc.l	cpy20,cpy21,cpy22,cpy23,cpy24
	dc.l	cpy25
	;copy 208 bytes from (a5) to (a6)  (52 registers)
	;6 movems : 9,9,9,9,9,7 regs	(3 scanlines)
	;read/write: 24+16*n = 16*(1.5+n)    (max: 10.5)
c0	equr	a1
c1	equr	d1
c2	equr	d2
c3	equr	d3
c4	equr	d4
c5	equr	d5
c6	equr	d6
c7	equr	d7
c8	equr	a0

swnodigi	MACRO
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#$0,$ffff8240.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	ENDM

swdigi	MACRO
	dcb	$4e71,22	;digi
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#$0,$ffff8240.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist
	ENDM
cpy00:	;7,9,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*5(a6)
	dcb	$4e71,6
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a6)
	;DIGI
	move.l	(a5)+,4*19(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*20(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*33(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*40(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy




;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*7(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*16(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*25(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*34(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*43(a6)
	
	bra	endcpy

cpy01:	;2+5,7,7,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1
	movem.l	c0/c1,4*50(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*3(a6)
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*10(a6)
	;DIGI
	move.l	(a5)+,4*17(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*18(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*24(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*31(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*38(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*45(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy


cpy02:	;4+3,9,9,9,9,9


;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3
	movem.l	c0/c1/c2/c3,4*48(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*3(a6)
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*8(a6)
	;DIGI
	move.l	(a5)+,4*15(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*16(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*22(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*29(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*36(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*43(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

cpy03:	;6+1,9,9,9,9,9



;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l	c0/c1/c2/c3/c4/c5,4*46(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,4*3(a6)
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*6(a6)
	;DIGI
	move.l	(a5)+,4*13(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*14(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*20(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*27(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*34(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*41(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy


cpy04:	;8,8,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*44(a6)
	movem.l	(a5)+,c0
	movem.l		c0,4*51(a6)
	movem.l	(a5)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a6)
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*4(a6)
	;DIGI
	move.l	(a5)+,4*11(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*12(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*18(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*25(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*32(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*39(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

cpy05:	;9,1+6,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*42(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,4*49(a6)
	movem.l	(a5)+,c0/c1
	movem.l		c0/c1,(a6)
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*2(a6)
	;DIGI
	move.l	(a5)+,4*9(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*10(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*16(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*23(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*30(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*37(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

cpy06:	;9,3+4,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*40(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*47(a6)
	dcb	$4e71,5
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a6)
	nop
	;DIGI
	move.l	(a5)+,4*7(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*8(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*14(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*21(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*28(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*35(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

cpy07:	;9,5+2,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*38(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,4*45(a6)
	dcb	$4e71,1
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0
	movem.l		c0,4*51(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a6)
	dcb	$4e71,5
	;DIGI
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*6(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*33(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

cpy08:	;9,7,9,9,9,9
;	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
;	move.b	#0,$ffff8260.w
	move.b	#$70,$ffff8240.w
	move.b	#0,$ffff8240.w
;	movem.l	d0/d1/d2,$ffff8250.w	;mdist
	dcb	$4e71,9
 	move.b	#0,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.l	d3,$ffff824e.w	;mdist

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*38(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*45(a6)
	dcb	$4e71,5
	;NODIGI
	nop
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a6)
	nop
	;DIGI
	move.l	(a5)+,4*5(a6)
	dcb	$4e71,10-6
	swdigi
	movem.l	(a5)+,c1/c2/c3/c4/c5/c6
	movem.l		c1/c2/c3/c4/c5/c6,4*6(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*12(a6)
	;NODIGI
	dcb	$4e71,2
	swnodigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*19(a6)
	;DIGI
	dcb	$4e71,10
	swdigi
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,4*26(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,4*33(a6)
	;NODIGI+RETURN
	dcb	$4e71,6
	dcb	$4e71,17	;mdist
;	move.b	#0,$ffff820a.w	;Open right border
;	move.b	#2,$ffff820a.w
	move.b	#$7,$ffff8240.w
	move.b	#0,$ffff8240.w
;	dcb	$4e71,25	
;	dcb	$4e71,4
	dcb	$4e71,6
	dcb	$4e71,3
	bra	endcpy

	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*36(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*45(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*9(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*18(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*27(a6)

	bra	endcpy

cpy09:	;9,9,7,9,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*34(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*43(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*7(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*16(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*25(a6)

	bra	endcpy

cpy10:	;9,9,2+5,9,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*32(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*41(a6)
	movem.l	(a5)+,c0/c1
	movem.l	c0/c1,4*50(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*5(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*14(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*23(a6)

	bra	endcpy

cpy11:	;9,9,4+3,9,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*30(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*39(a6)
	movem.l	(a5)+,c0/c1/c2/c3
	movem.l	c0/c1/c2/c3,4*48(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*3(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*12(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*21(a6)

	bra	endcpy

cpy12:	;9,9,6+1,9,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*28(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*37(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l	c0/c1/c2/c3/c4/c5,4*46(a6)
	movem.l	(a5)+,c0
	movem.l		c0,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*1(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*10(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*19(a6)

	bra	endcpy

cpy13:	;9,9,8,8,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*26(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*35(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,4*44(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*8(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*17(a6)

	bra	endcpy

cpy14:	;9,9,9,1+6,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*24(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*33(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*42(a6)
	movem.l	(a5)+,c0
	movem.l	c0,4*51(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*6(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*15(a6)

	bra	endcpy

cpy15:	;9,9,9,3+4,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*22(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*31(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*40(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l	c0/c1/c2,4*49(a6)
	movem.l	(a5)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*4(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*13(a6)

	bra	endcpy

cpy16:	;9,9,9,5+2,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*20(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*29(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*38(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l	c0/c1/c2/c3/c4,4*47(a6)
	movem.l	(a5)+,c0/c1
	movem.l		c0/c1,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*2(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*11(a6)

	bra	endcpy

cpy17:	;9,9,9,7,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*18(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*27(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*36(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l	c0/c1/c2/c3/c4/c5/c6,4*45(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*9(a6)

	bra	endcpy

cpy18:	;9,9,9,9,7,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*16(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*25(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*34(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*43(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6
	movem.l		c0/c1/c2/c3/c4/c5/c6,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*7(a6)

	bra	endcpy

cpy19:	;9,9,9,9,2+5,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*14(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*23(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*32(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*41(a6)
	movem.l	(a5)+,c0/c1
	movem.l	c0/c1,4*50(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l		c0/c1/c2/c3/c4,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*5(a6)

	bra	endcpy

cpy20:	;9,9,9,9,4+3,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*12(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*21(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*30(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*39(a6)
	movem.l	(a5)+,c0/c1/c2/c3
	movem.l	c0/c1/c2/c3,4*48(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l		c0/c1/c2,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*3(a6)

	bra	endcpy

cpy21:	;9,9,9,9,6+1,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*10(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*19(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*28(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*37(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l	c0/c1/c2/c3/c4/c5,4*46(a6)
	movem.l	(a5)+,c0
	movem.l		c0,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*1(a6)

	bra	endcpy

cpy22:	;9,9,9,9,8,8
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*8(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*17(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*26(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*35(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,4*44(a6)


	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,(a6)

	bra	endcpy

cpy23:	;9,9,9,9,9,1+6
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*6(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*15(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*24(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*33(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*42(a6)
	movem.l	(a5)+,c0
	movem.l	c0,4*51(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5
	movem.l		c0/c1/c2/c3/c4/c5,(a6)

	bra	endcpy

cpy24:	;9,9,9,9,9,3+4
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*4(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*13(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*22(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*31(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*40(a6)
	movem.l	(a5)+,c0/c1/c2
	movem.l	c0/c1/c2,4*49(a6)
	movem.l	(a5)+,c0/c1/c2/c3
	movem.l		c0/c1/c2/c3,(a6)

	bra	endcpy

cpy25:	;9,9,9,9,9,5+2
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*2(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*11(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*20(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*29(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7/c8,4*38(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4
	movem.l	c0/c1/c2/c3/c4,4*47(a6)
	movem.l	(a5)+,c0/c1
	movem.l		c0/c1,(a6)

	bra	endcpy
	;
	;**********************************************************

	section	data

	;**********************************************************
	;	Distorted scroller by Gunstick


digi:
;	incbin	"telgraph.dmn"

hwbounceptr:	dc.l	hwbouncetab
hwbouncetab:
	dc.w	230*16,230*16
	dc.w	230*16,230*16
	dc.w	230*15,230*15
	dc.w	230*15,230*15
	dc.w	230*14,230*14
	dc.w	230*14,230*14
	dc.w	230*13,230*13
	dc.w	230*12,230*12
	dc.w	230*11,230*10
	dc.w	230*9,230*8
	dc.w	230*7
	dc.w	230*6
	dc.w	230*5,230*3
	dc.w	230*1,230*3
	dc.w	230*5
	dc.w	230*6,230*7
	dc.w	230*8,230*9
	dc.w	230*10,230*11
	dc.w	230*12,230*12
	dc.w	230*13,230*13
	dc.w	230*14,230*14
	dc.w	230*14,230*14
	dc.w	230*15,230*15
	dc.w	230*15,230*15
	dc.w	230*16,230*16
	dc.w	230*16,230*16
	dc.w	0
scrnadrs:
	dc.l	screen+64400*0
	dc.l	screen+64400*1
	dc.l	screen+64400*2
	dc.l	screen+64400*3
	dc.l	screen+64400*0+230*20
	dc.l	screen+64400*1+230*20
	dc.l	screen+64400*2+230*20
	dc.l	screen+64400*3+230*20
	dc.l	screen+64400*0+230*40
	dc.l	screen+64400*1+230*40
	dc.l	screen+64400*2+230*40
	dc.l	screen+64400*3+230*40
	dc.l	screen+64400*0+230*60
	dc.l	screen+64400*1+230*60
	dc.l	screen+64400*2+230*60
	dc.l	screen+64400*3+230*60
	dc.l	screen+64400*0+230*80
	dc.l	screen+64400*1+230*80
	dc.l	screen+64400*2+230*80
	dc.l	screen+64400*3+230*80
	dc.l	screen+64400*0+230*100
	dc.l	screen+64400*1+230*100
	dc.l	screen+64400*2+230*100
	dc.l	screen+64400*3+230*100
	dc.l	screen+64400*0+230*120
	dc.l	screen+64400*1+230*120
	dc.l	screen+64400*2+230*120
	dc.l	screen+64400*3+230*120
	dc.l	screen+64400*0+230*140
	dc.l	screen+64400*1+230*140
	dc.l	screen+64400*2+230*140
	dc.l	screen+64400*3+230*140
	dc.l	screen+64400*0+230*160
	dc.l	screen+64400*1+230*160
	dc.l	screen+64400*2+230*160
	dc.l	screen+64400*3+230*160
	dc.l	screen+64400*0+230*180
	dc.l	screen+64400*1+230*180
	dc.l	screen+64400*2+230*180
	dc.l	screen+64400*3+230*180
	dc.l	screen+64400*0+230*200
	dc.l	screen+64400*1+230*200
	dc.l	screen+64400*2+230*200
	dc.l	screen+64400*3+230*200
	dc.l	screen+64400*0+230*220
	dc.l	screen+64400*1+230*220
	dc.l	screen+64400*2+230*220
	dc.l	screen+64400*3+230*220
	dc.l	screen+64400*0+230*240
	dc.l	screen+64400*1+230*240
	dc.l	screen+64400*2+230*240
	dc.l	screen+64400*3+230*240
	dc.l	screen+64400*0+230*260
	dc.l	screen+64400*1+230*260
	dc.l	screen+64400*2+230*260
;	dc.l	screen+64400*3+230*260
;	dc.l	screen+64400*0+230*280
	dc.l	0
font	equ	*-32*8
	incbin	"font.bin"
	even
wavetab:
;	dc.l	byteschief,0
	dc.l	wordschief
	dc.l	wordschief
	dc.l	byteschief
	dc.l	nix
	dc.l	nix
	dc.l	wordhinher
	dc.l	nix
	dc.l	nix
	dc.l	hacker,hacker,hacker
	dc.l	hacker,hacker,hacker
	dc.l	hacker,hacker,hacker
	dc.l	hacker,hacker,hacker
	dc.l	hacker,hacker,hacker
;	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	dreieck
	dc.l	slowdist,slowdist,slowdist,slowdist
	dc.l	slowdist,slowdist,slowdist,slowdist
	dc.l	slowdist,slowdist,slowdist,slowdist
	dc.l	hacker,hacker,hacker
	dc.l	sinus
	dc.l	sinus
	dc.l	sinus
	dc.l	sinus
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinus
	dc.l	sinus
	dc.l	sinus
	dc.l	sinus
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinschief
	dc.l	bigsin
	dc.l	bigsin
	dc.l	bigsin
	dc.l	sinus
	dc.l	sinus
	dc.l	sinschief
	dc.l	sinschief
	dc.l	sinus
	dc.l	sinus
	dc.l	bigsin
	dc.l	bigsin
	dc.l	bigsin
	dc.l	bigsin
	dc.l	bigsin
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

bytezurueck;
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	128
sinschief;
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
bigsin:	dc.w	1,0,0,1,0,0,1,0,0,2,0,0,2,0,0,2,0,0,3,0,0,3,0,0,3,0,0,4,0,0,4,0,0,4
	dc.w	5,0,0,5,0,0,5,0,0,4,0,0,4,0,0,3,0,0,3,0,0,2,0,0,2,0,0,1,0,0,1,0,0,0
	dc.w	0,0,0,-1,0,0,-1,0,0,-2,0,0,-2,0,0,-3,0,0,-3,0,0,-4
	dc.w	-4,0,0,-5,0,0,-5,0,0,-4,0,0,-4,0,0,-4,0,0,-3,0,0,-3
	dc.w	-3,0,0,-2,0,0,-2,0,0,-2,0,0,-1,0,0,-1,0,0,-1,0,0,0,0,0,0,0,0,0,0,0,128
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
	dc.b	01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01
	dc.b	n,n+1,a,a+1,r,r+1,y,y+1,space,space,f,f+1,u,u+1,l,l+1,l,l+1,mi,mi+1
	dc.b	s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1,mi,mi+1,s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1
	dc.b	space,az,az+1,az,az+1,space,space,space,n,n+1,o,o+1,b,b+1,o,o+1,d,d+1,y,y+1
	dc.b	space,space,c,c+1,a,a+1,n,n+1,space,space,b,b+1,e,e+1,a,a+1,t,t+1
	dc.b	space,space,u,u+1,space,l,l+1,space,m,m+1,space,az,az+1,az,az+1,az,az+1
	dc.b	space,space
scrolltext:
;	dc.b	space,space,space,space,space,space,space
;	dc.b	space,space,space,space,space,space,space
;	dc.b	space,space,space,space,space,space,space,0
	rept 10
	dc.b	space,space,space,space,space,space,space
	endr
	dc.b	space,space,space,h,h+1,e,e+1,l,l+1,l,l+1,o,o+1,space,space
	dc.b	t,t+1,h,h+1,i,i+1,s,s+1,space,space,i,i+1,s,s+1,space,space
	dc.b	g,g+1,u,u+1,n,n+1,s,s+1,t,t+1,i,i+1,c,c+1,k,k+1,space,s,s+1
	dc.b	space,space,space,r,r+1,e,e+1,v,v+1,o,o+1,l,l+1,u,u+1,t,t+1,i,i+1,o,o+1
	dc.b	n,n+1,a,a+1,r,r+1,y,y+1,space,space,f,f+1,u,u+1,l,l+1,l,l+1,mi,mi+1
	dc.b	s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1,mi,mi+1,s,s+1,c,c+1,r,r+1,e,e+1,e,e+1,n,n+1
	dc.b	space,az,az+1,az,az+1,space,space,space,n,n+1,o,o+1,b,b+1,o,o+1,d,d+1,y,y+1
	dc.b	space,space,c,c+1,a,a+1,n,n+1,space,space,b,b+1,e,e+1,a,a+1,t,t+1
	dc.b	space,space,u,u+1,space,l,l+1,space,m,m+1,space,az,az+1,az,az+1,az,az+1
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




prt:
	dc.b 27,"Y",32+20,32+1,"     000"
str:	dc.b "0    ",0



	even
psginittab:dc.b 0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b 7,$7f,8,7,9,7,10,7,$ff,0
	even
hwpalette:
	dc.w $0700,$0707,$0474,$0777,$0606,$0505,$0404,$303
	dc.w $777,$666,$555,$444,$333,$222,$111,$002 
graphic:
	dc.w $d555,$3333,$0f0f,$ff
message:
	dc.b 0
	even
lowbyte:
	dc.b 0

	
hwscrolldat:			

	incbin	"hwscroll.dat"
	even
	section	bss
stack:	ds.l 1
oldpal: ds.w 16
oldres: ds.w 1
screenad1:ds.w 1
screenad2:ds.l 1
screenadr:ds.l 1
logbase:	ds.l	1	;screen where to put scroll
black:	ds.l 8
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
	ds.l	1	;pointer to the distorter adjust table
	ds.w	1600	;panic for table
disttable:
	ds.w	26*2+100	;adjusttable for the two distorters
	ds.w	1600	;panic for table

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
	rept	25	;26 lines scroll
;	ds.l	1
;	ds.l	1
;	ds.w	1
;	ds.w	1
	ds.l	2*26*16+1+1+1
	endr

	ds.l	230*40
screen: 
	rept	5
	ds.l 8000
	ds.l 8000
	endr
	end


screen:
	;************** Digiplayer by GunsticK
	;init
	lea	digi,a3
	lea	voltab,a4
	move.w	(a3)+,d3
	lea	$ffff8800,a5
loop:
	btst	#6,$fffffa0d.w
	bne	exit

	;************** Domino Digiplayer by GunsticK
	moveq	#-1,d0
	move.b	(a3),d0
	add.w	d0,d0
	add.w	(a4,d0),d3
	andi.w	#$ff*4,d3
	
	move.l	(a4,d3),d0
	movep.l	d0,(a5)		;~7

	not.w	$ffff8240.w
	not.w	$ffff8240.w

	dcb	$4e71,128-22-8

	moveq	#-1,d0		;~1
	move.b	(a3)+,d0	;~2
	add.w	d0,d0		;~1
	add.w	2(a4,d0),d3	;~4
	andi.w	#$ff*4,d3	;~2
	
	move.l	(a4,d3),d0	;~5
	movep.l	d0,(a5)		;~7

	not.w	$ffff8240.w
	not.w	$ffff8240.w

	dcb	$4e71,128-22-20-8
	cmp.l	#digiend,a3
	blo.s	contdigi
	lea	digi,a3
	lea	voltab,a4
	move.w	(a3)+,d3
_contdigi:	
	bra	loop

contdigi:
	bra.s	_contdigi
exit:
	movea.l $0600.w,a0
	jmp	(a0)

waitvbl:
	move.b	$ffff8203.w,d0
	lsl.w	#8,d0
	lea	$ffff8207.w,a0
no_vbl:
	movep.w 0(a0),d1
	cmp.w	d0,d1
	bne.s	no_vbl
	rts

;please leave all section indications unchanged...
;here starts the data section

black:
		dc.l	0,0,0,0,0,0,0,0
		dc.l	0,0,0,0,0,0,0,0
graphic:
		dc.l	%01010101010101010011001100110011
		dc.l	%00001111000011111111111111111111
pal:
		dc.w	$000,$0221,$0332,$0443,$0554,$0665,$0110,$20


entrylen = 4
 
	even
digi:
	dc.w	entrylen*$a0
	incbin	"telgraph.dmn"
digiend:
;end of data section

		section	bss
;please leave all section indications unchanged...
bss_start:			;here starts the bss

stack:		ds.l	1
screenad1:	ds.l	1


screenmem:	ds.l	14300
bss_end:			;here ends the bss

