overscan:equ 0

; screen #2 by The Fate of ULM (c) 1989 and for all eternity...

x:
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
	addi.l	#8*5-64,screenadr

	movea.l screenad2,a0
	move.l	#9999,d0
clear_loop:
	clr.l	(a0)+
	dbra	d0,clear_loop

	movea.l screenad2,a0
	movem.l graphic,d6-d7
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
	trap	#1
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
	trap	#14
	lea	12(sp),sp

	bsr.s	psginit

	lea	oldpal,a0
	lea	$ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)

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

	move	sr,-(sp)
	move	#$2700,sr
	move.l	sp,stack
;	clr.b	lowbyte
	lea	screenadr,a3
	move.b	lowbyte,3(a3)
	move.w	#100,d2
testlp:
	bsr.s	waitvbl		;lower border
	move.w	#1500,d0
firsttopwait:
	dbf	d0,firsttopwait
	move.b	#0,$ffff820a.w
	dcb	$4e71,100
	move.b	#2,$ffff820a.w
	dbf	d2,testlp
	



loop:
;ULM Hardware Scrolling PART 1
;THIS PART IS TO BE STARTED BEFORE THE BEGINNING OF THE VBL
;sets screen to adress contained in screenadr+(6 scanlines)

	lea	screenadr,a3
	moveq	#0,d1
	move.b	3(a3),d1
	move.w	d1,d0
	add.w	d1,d1
	add.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1		;*12 (24 byte per tabentry)
	lea	$ffff8201.w,a1
	lea	hwscrolldat,a0
	lea	0(a0,d1.w),a0
	movep.w 1(a3),d1
	move.b	2(a3),d1
	move.b	(a0)+,d0
	ext.w	d0
	add.w	d0,d1
	movep.w d1,0(a1)
	move.l	a0,-(sp)
;ULM Hardware Scrolling END OF PART 1


	bsr	waitvbl

	movem.l black,d0-d7
	movem.l d0-d7,$ffff8240.w
	movem.l hwpalette,d2-d7/a2-a3
	lea	$ffff8209.w,a1
	moveq	#10,d1
	movea.l (sp)+,a0


	move.w	#1500,d0
opentopwait:
	dbra	d0,opentopwait
	dcb	$4e71,196-72
	move.b	#0,$ffff820a.w
	move.w	#$007,$ffff8240.w
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

	ifne overscan
	dcb	$4e71,4
	movem.l d2-d7/a2-a3,$ffff8240.w
	endc
	ifeq overscan
	dcb	$4e71,3
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	movem.l d2-d4,$ffff8240.w
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	movem.l d5-d7/a2-a3,12+$ffff8240.w
	dcb	$4e71,72-3
	move.w	#221-16,d0
;	 rept 5
overscanloop:
	nop
	nop
	nop
	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	dcb	$4e71,84-3
	dbra	d0,overscanloop
;	 endr
	nop








	nop

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#0,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w
	move.b	#2,$ffff820a.w
	dcb	$4e71,84-1


	rept 43+16

	move.b	#0,$ffff820a.w	;Open right border
	move.b	#2,$ffff820a.w
	dcb	$4e71,8
	move.b	#1,$ffff8260.w	;GunsticK's right border end switch
	move.b	#0,$ffff8260.w
	dcb	$4e71,9
	move.b	#2,$ffff8260.w	;Open left border
	move.b	#0,$ffff8260.w

	dcb	$4e71,84
	nop
	nop
	nop
	endr

	endc

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
	bsr.s	d0todeza3
	pea	prt
	move.w	#9,-(sp)
;	 trap	 #1
	addq.w	#6,sp

	bra	loop

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
	section	data
prt:
	dc.b 27,"Y",32+20,32+1,"     000"
str:	dc.b "0    ",0



	even
psginittab:dc.b 0,$ff,1,$ff,2,$ff,3,$ff,4,$ff,5,$ff,6,0
	dc.b 7,$7f,8,7,9,7,10,7,$ff,0
	even
hwpalette:
	dc.w $0700,$07,$0474,$0777,$0606,$0700,$0170,$62
	dc.w $0770,$0707,$50,$0505,$75,$0777,$00,$0711
graphic:
	dc.w $d555,$3333,$0f0f,$ff
message:
	dc.b 27,"c",6,13,10,13,10,10,10,10,10,10,10,10,10,"Hardware scrolling discovery"
	dc.b 13,10,"Scroll !!!!!!",13,10,10
test:	equ 0
	ifeq test
	dc.b 'UUUU	      LLLL MMMMMM	 MMMMMM',13,10
;	 dc.b 'UUUU	       LLLL MMMMMMM	 MMMMMMM',13,10
	dc.b 'UUUU	      LLLL     MMMM    MMMMMMMM',13,10
;	 dc.b 'UUUU	       LLLL	 MMMM  MMMM MMMM',13,10
	dc.b 'UUUU	      LLLL	 MMMMMMMM  MMMM',13,10
;	 dc.b 'UUUU	       LLLL	   MMMMMM   MMMM',13,10
	dc.b 'UUUU	      LLLL	   MMMM    MMMM',13,10
;	 dc.b 'UUUU	       LLLL		    MMMM',13,10
	dc.b 'UUUU	      LLLL		   MMMM',13,10
;	 dc.b 'UUUU	       LLLL		    MMMM',13,10
	dc.b 'UUUU	      LLLL		   MMMM',13,10
;	 dc.b 'UUUU	       LLLL		    MMMM',13,10
	dc.b 'UUUU	      LLLL		   MMMM',13,10
;	 dc.b 'UUUU	       LLLL		    MMMM',13,10
	dc.b 'UUUU	      LLLL		   MMMM',13,10
;	 dc.b 'UUUU	      ULLLL		    MMMM',13,10
	dc.b 'UUUU	   UUUU LLLL		   MMMM',13,10
;	 dc.b 'UUUU	  UUUU	   LLLL 	    MMMM',13,10
	dc.b 'UUUUUUUUUUUUU	    LLLLLLLLLLLLLL MMMM',13,10
;	 dc.b 'UUUUUUUUUUU	       LLLLLLLLLLLL MMMM',13,10
	endc
	ifne test
	dc.b '					       ',13,10
	dc.b '	   TTTTTTTTTTT HH     HH EEEEEEEEE     ',13,10
	dc.b '	       TT      HH     HH EE	       ',13,10
	dc.b '	       TT      HH     HH EE	       ',13,10
	dc.b '	       TT      HHHHHHHHH EEEEE	       ',13,10
	dc.b '	       TT      HH     HH EE	       ',13,10
	dc.b '	       TT      HH     HH EE	       ',13,10
	dc.b '	       TT      HH     HH EEEEEEEEE     ',13,10
	dc.b '					       ',13,10
	dc.b 'FFFFFFFFF AAAAAAAAA TTTTTTTTTT EEEEEEEEEE',13,10
	dc.b 'FF	AA     AA     TT     EE        ',13,10
	dc.b 'FF	AA     AA     TT     EE        ',13,10
	dc.b 'FFFFF	AAAAAAAAA     TT     EEEEE     ',13,10
	dc.b 'FF	AA     AA     TT     EE        ',13,10
	dc.b 'FF	AA     AA     TT     EE        ',13,10
	dc.b 'FF	AA     AA     TT     EEEEEEEEEE',13,10
	dc.b '					       ',13,10
	endc
	dc.b 27,"Y",32+20,32,"|"
	dc.b 13,10,"|"
	dc.b 13,10,"0123456789012345678901234567890123456789"
	dc.b 13,10,"0000000000111111111122222222223333333333"
	dc.b 13,10,"||||||||||||||||||||||||||||||||||||||||",0
	dc.b 13,10,"||||||||||||||||||||||||||||||||||||||||",0
	even
savestart:
hwscrolldat:			; equ	  *+24*24
;	incbin	'hw.dat'
;	dc.b	$00,$00,$00,$00
;	dc.b	$00,$00,$00,$ff ;44
;	dc.b	$00,$00,$ff,$00 ;-2
;	dc.b	$00,$ff,$00,$00 ;-106
;	dc.b	$ff,$00,$00,$00 ;26
;	dc.b	$ff,$00,$00,$ff ;70
;	dc.b	$ff,$00,$ff,$00 ;24
;	dc.b	$ff,$ff,$00,$00 ;-80

;	c = Christian synchronistaion 1
;	C = Christian synchronisation 2
;	P = MMU mit Punkten bei farbumschaltung (franz.)
;	g = Georges sync: bad overscan
;	G = Georges sync: good overscan

as:	equ 2*0
	dc.b $ff		;0	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff		;1	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;2	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;3	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;4	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;5	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;6	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;7	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;8	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00		;9	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;10	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;11	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;12	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;13	cPgG
	dc.b $00,$00,$ff
	dc.b $00,$ff,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;14	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;15	c gG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;16	c gG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;17	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00		;18	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;19	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;20	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;21	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;22	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;23	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;24	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;25	cPgG
	dc.b $ff,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;26	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00		;27	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00		;28	c gG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;29	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;30	c gG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$ff,$00,$00
	dc.b $00		;31	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;32	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;33	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;34	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;35	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;36	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;37	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;38	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;39	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;40	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00		;41	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;42	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;43	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;44	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;45	c gG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;46	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;47	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;48	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $00		;49	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;50	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00		;51	cPgG
	dc.b $ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;52	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$ff,$00,$00
	dc.b $00		;53	cPgG
	dc.b $ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;54	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;55	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;56	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;57	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;58	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;59	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;60	c gG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;61	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;62	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;63	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $00		;64	cPgG
	dc.b $ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;65	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;66	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;67	c gG
	dc.b $00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;68	c gG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;69	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;70	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;71	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;72	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;73	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;74	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;75	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00	;hoffentlich geht dieser immer !
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;76	cPgG
	dc.b $ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;77	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;78	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $01		;79	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00		;80	c gG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;81	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;82	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;83	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;84	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;85	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;86	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;87	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;88	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;89	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00		;90	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00		;91	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $01		;92	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;93	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;94	c gG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;95	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00		;96	c gG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;97	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;98	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;99	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;100	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;101	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00		;102	cPgG
	dc.b $00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00		;103	  gG
	dc.b $00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00		;104	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;105	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;106	c gG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;107	cPgG
	dc.b $ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;108	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;109	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;110	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;111	cPgG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;112	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;113	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;114	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $00		;115	cPgG
	dc.b $00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00		;116	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $00		;117	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $01		;118	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $01		;119	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$00,$ff
	dc.b $00,$00,$00,$ff
	dc.b $01		;120	c gG
	dc.b $00,$ff,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;121	c gG
	dc.b $00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $01		;122	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$ff,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $ff,$00,$ff,$00
	dc.b $01		;123	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$00,$ff
	dc.b $00,$00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $01		;124	cPgG
	dc.b $00,$00,$00
	dc.b $ff,$ff,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $ff,$00,$ff,$00
	dc.b $ff,$00,$ff,$00
	dc.b $01		;125	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;126	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $01		;127	cPgG
	dc.b $00,$00,$00
	dc.b $00,$00,$ff,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	dc.b $00,$00,$00,$00
	even
saveend:
lowbyte:
	dc.b as
	section	bss
stack:	ds.l 1
oldpal: ds.w 16
oldres: ds.w 1
screenad1:ds.w 1
screenad2:ds.l 1
screenadr:ds.l 1
black:	ds.l 8

screen: ds.l 14300
	end
