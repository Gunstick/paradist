overscan:equ 0

; Double Megadistorter by Gunstick   (c) ULM 1990

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
;	addi.l	#8*5-64,screenadr

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
	move.b	#0,$ffff820a.w

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
	move.l	#megadistadjusttable,megadistadjust


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

	;********************************************************

	lea	screenadr,a3
;	move.b	lowbyte,3(a3)

	bsr	waitvbl		;lower border
	move.w	#4000,d0
firsttopwait:
	dbf	d0,firsttopwait
	;move.b	#0,$ffff820a.w

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
;	move.w	#221-16,d0
	move.w	#32,d0
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
	nop

	endc
	;**********************************************************
	;	Distorted scroller by Gunstick


	;***** Calc next screenadress ****
	move.l	screenadr,screenadr	;wow!
	
	;***** Do the 8 following distorter entrys **** 
	;; first copy the wave to the megadistadjusttable
	
;Registerdefs: take care of the order. Modify also the addx.l !!!!
d_0	equr	d0
d_1	equr	d1
d_2	equr	d2
d_3	equr	d3
a_0	equr	a0
a_1	equr	a1
a_2	equr	a2
a_3	equr	a3

	move.l	distwaveptr,a_0		;position in the actual wave
	move.l	megadistadjust,a_3	;position in the adjust table
	add	#274,a_3	;new: behind
	moveq	#7,d_0			;read 8
distwaveread:
	move.w	(a_0)+,d_1
	cmp.w	#128,d_1
	bne.s	notnextwavetab
	move.l	wavetabptr,a_1	;next wave to be read
	bne.s	notendwavetab
	lea	wavetab,a_1	;reset wavetabptr
notendwavetab:
	move.l	(a_1)+,a_0
	move.w	(a_0)+,d_1
	move.l	a_1,wavetabptr
_notnextwavetab:
	move.w	d_1,(-274-8)*2(a_3)	;before
	move.w	d_1,(a_3)+	;behind
	dbf	d_0,distwaveread
	move.l	a_0,distwaveptr
;	add.w	#8*2,a_3
	cmp.l	#megadistadjusttable+276*4,a_3
	bmi.s	ok
;	lea	(-274-8)*2(a_3),a_3
ok:
;	move.l	a_3,megadistadjust

	;=-| read the new distortions and shift the buffers
	; letters of font must be 256 bytes !!!!!!!!
	lea	-12*2(a_3),a_3	;scroll begins 32 lines before end of screen
	lea	shift,a_0	;pointer to the shifts
	move.w	#-(26*8),count	;scroll has 26 lines
distcalcloop:
	move.w	(a_3)+,d_1
	move.w	(a_0),d_2		;read shift
	add.w	d_1,d_2
	bmi	rueckwaerts
	sub.w	#16,d_2
	bhs	vorwaerts
	add.w	#16,d_2			;plenty of time here
	move.w	d_2,(a_0)		;write back new shift
indistcalcloop:
	lea	linebuffend-linebuffbegin(a_0),a_0	;next line
	addq.w	#8,count
	bne.s	distcalcloop
	bra	copydistscroll
notnextwavetab:			;time adjust
	dcb	$4e71,1	
	bra.s	_notnextwavetab

nottextend:
	lea	1(a_1),a_1
	bra.s	_nottextend

	;-> advance this line by one word
vorwaerts:
	move.w	d_2,(a_0)		;write back new shift
	move.l	textptr-shift(a_0),a_1
	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		textptr
	;		|
	;UNLIMITED MATRICKS	a bit of C appears somewhere
	;now we have to write a bit of K and C
	movep.w	0(a_1),d_1	;previous letter : C
	movep.w	1(a_1),d_2	;act letter	 : K
	tst.b	d_1	;test letter after act : S
	bne.s	nottextend
	lea	scrolltext,a_1
_nottextend:
	move.l	a_1,textptr-shift(a_0)	;textptr points to K
	clr.b	d_1	;C
	clr.b	d_2	;K
	lea	font+(26*8),a_1
	add.w	count,a_1
	lea	(a_1,d_1),a_2	;C
;	lea	(a_1),a_2	;C
	movem.l	(a_1,d_2),d_1/d_3	;K
;	movem.w	256(a_1),d_0/d_1/d_2/d_3	;K
	;d0:xxxxxxxxxxxxxxxx
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxxxxxxxxx
	;d3:ccccccccdddddddd
	move.w	d_1,d_2
	move.w	d_3,d_0
	;d0:xxxxxxxxdddddddd
	;d1:aaaaaaaabbbbbbbb
	;d2:xxxxxxxxbbbbbbbb
	;d3:ccccccccdddddddd
	swap	d_0
	swap	d_2
	;d0:ddddddddxxxxxxxxx
	;d1:aaaaaaaabbbbbbbbb
	;d2:bbbbbbbbxxxxxxxxx
	;d3:ccccccccddddddddd
	move.l	bufptr-shift(a_0),a_1
	;prepare shifter
	move.w	(a_2)+,d_0
	move.w	(a_2)+,d_1
	move.w	(a_2)+,d_2
	move.w	(a_2)+,d_3		;C
	;uff one line of the 2 letters is in d0-d3
	;d0	dddddddd|AAAAAAAA
	;d1	aaaaaaaa|BBBBBBBB
	;d2	bbbbbbbb|CCCCCCCC
	;d3	cccccccc|DDDDDDDD
	;write first buffer
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	lea	26*8(a_1),a_1	;~8

	rept	15
	move	#0,ccr
	swap	d_1	;~4
 	addx.w	d1,d1	;~4	;a out
	swap	d_1	;~4
 	addx.l	d0,d0	;~8	;a in and d out
 	addx.l	d3,d3	;~8	;d in and c out
 	addx.l	d2,d2	;~8	;c in and b out
 	addx.w	d1,d1	;~4	;b in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8
	endr
asd:
	cmp.w	#25*4,bufcnt-shift(a_0)
	blo.s	vorbufok
	move.w	#0,bufcnt-shift(a_0)	;screenwidth = 26 words
	sub.l	#25*8,bufptr-shift(a_0)
	bra	indistcalcloop
vorbufok:
	addq.w	#4,bufcnt-shift(a_0)
	add.l	#8,bufptr-shift(a_0)
	bra	indistcalcloop


	;-< back this line by one word
rueckbufok:
	dcb	$4e71,1	
	bra.s	_rueckbufok
rueckwaerts:
	add.w	#16,d_2
	move.w	d_2,(a_0)		;write back new shift
	subq.w	#4,bufcnt-shift(a_0)
	bhs.s	rueckbufok
	move.w	#25*4,bufcnt-shift(a_0)	;screenwidth = 26 words
	add.l	#25*8,bufptr-shift(a_0)
_rueckbufok:
	move.l	textptr-shift(a_0),a_1
	;movep : 5 nops weniger
	;actual = if any bit of the letter appears in one buffer
	;		             textptr
	;  |			     |
	;YEAH THIS IS UNLIMITED MATRICKS	a bit of C appears somewhere
	;a bit of A appears somewhere
	;now we have to write a bit of E and A 
	movep.w	-27(a_1),d_1	;previous letter : E
	movep.w	-26(a_1),d_2	;act letter	 : A
	lea	-1(a_1),a_1
	move.l	a_1,textptr-shift(a_0)	;textptr points to I
	clr.b	d_1	;E
	clr.b	d_2	;A
	lea	font,a_1
	lea	(a_1,d_1),a_2	;E
	movem.w	(a_1,d_2),d_0/d_1/d_2/d_3	;A
	;write first buffer
	move.l	bufptr-shift(a_0),a_1
	movem.w	d_0/d_1/d_2/d_3,(a_1)
	;prepare shifter
	swap	d_0
	swap	d_1
	swap	d_2
	swap	d_3
	move.w	(a_2)+,d_3		;E
	move.w	(a_2)+,d_0
	move.w	(a_2)+,d_1
	move.w	(a_2)+,d_2
	;uff one line of the 2 letters is in d0-d3
	;	   A	    E
	;d0	bbbbbbbb|AAAAAAAA
	;d1	cccccccc|BBBBBBBB
	;d2	dddddddd|CCCCCCCC
	;d3	aaaaaaaa|DDDDDDDD
	rept	15
	swap	d_3	;~4
 	addx.w	d3,d3	;~4	;got a bit for A
	swap	d_3	;~4
 	addx.l	d0,d0	;~8	;a in and b out
 	addx.l	d1,d1	;~8	;b in and c out
 	addx.l	d2,d2	;~8	;c in and d out
 	addx.w	d3,d3	;~4	;d in
	movem.w	d_0/d_1/d_2/d_3,(a_1)	;~28
	lea	26*8(a_1),a_1	;~8
	endr
	bra	indistcalcloop





copydistscroll:
	;**** Copy all the buffers to the screen ****
	move.l	screenadr,a6	;put it there
	add.l	#6*160,a6	;for hwscroll
	lea	buffer,a4
	moveq	#25,d0		;scrollhigh:26
;	not	$ffff8240.w
scrollcpy:
	move.w	shift-buffer(a4),d1
	mulu	#208,d1
;	lea	208*15(a4),a5
	lea	(a4,d1),a5
;	move.w	#0,d1
	move.w	bufcnt-buffer(a4),d1
	lea	cpyjsr,a0
	move.l	(a0,d1),a0
	jsr	(a0)		;(a5)+ -> (a6)
	lea	230(a6),a6
	lea	linebuffend-linebuffbegin(a4),a4
	dbf	d0,scrollcpy
;	not	$ffff8240.w


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
;	move.l	screenadr,a1	;put it there
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
	;copy 208 bytes from (a5) to (a6)  (52 registers)
	;6 movems : 9,9,9,9,9,7 regs	(6 scanlines)
	;read/write: 24+8*n = 16*(1.5+n)    (max: 10.5)
c0	equr	a1
c1	equr	d1
c2	equr	d2
c3	equr	d3
c4	equr	d4
c5	equr	d5
c6	equr	d6
c7	equr	d7
c8	equr	a0

cpy00:	;7,9,9,9,9,9


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
	
	rts

cpy01:	;2+5,9,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*32(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*41(a6)

	rts

cpy02:	;4+3,9,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*30(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*39(a6)

	rts

cpy03:	;6+1,9,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*28(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*37(a6)

	rts

cpy04:	;8,8,9,9,9,9
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l	c0/c1/c2/c3/c4/c5/c6/c7,4*44(a6)
	
	
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7,(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*8(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*17(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*26(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*35(a6)

	rts

cpy05:	;9,1+6,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*24(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*33(a6)

	rts

cpy06:	;9,3+4,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*22(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*31(a6)

	rts

cpy07:	;9,5+2,9,9,9,9
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
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*20(a6)
	movem.l	(a5)+,c0/c1/c2/c3/c4/c5/c6/c7/c8
	movem.l		c0/c1/c2/c3/c4/c5/c6/c7/c8,4*29(a6)

	rts

cpy08:	;9,7,9,9,9,9
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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts

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

	rts
	;
	;**********************************************************

	section	data

	;**********************************************************
	;	Distorted scroller by Gunstick
font	equ	*-32*8
	incbin	"font.bin"
	even
count:
	dc.l	0	;for some dbf without register
distwaveptr:
	dc.l	0	;pointer in one distwave
wavetabptr:
	dc.l	0	;pointer to the next wave to be played
megadistadjust:
	dc.l	0	;pointer to the distorter adjust table
	ds.w	1600	;panic for table
megadistadjusttable:
	dcb	3,274*2+100	;adjusttable for the two distorters
	ds.w	1600	;panic for table
wavetab:
	dc.l	dreieck
	dc.l	0	;end
	;		!!!!!! negativ = normal scroll direction !!!!!!
dreieck:
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	3,3,3,3,3,3,3,3
	dc.w	2,2,2,2,2,2,2,2
	dc.w	2,2,2,2,2,2,2,2
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0,128
	dc.w	16,16,16,16,16,16,16,16
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	1,1,1,1,1,1,1,1
	dc.w	128	
;Panic buffer for scrolltext
	dc.b	01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01
	dc.b	01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01,01
scrolltext:
	dc.b	87,87
	dc.b	01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20
	dc.b	21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
	dc.b	41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60
	dc.b	61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80
	dc.b	81,82,83,84,85,86,87
	dc.b	0
	even
linebuffbegin:
textptr:
	dc.l	0	;letter not completly copied into buffer (forward)
bufptr:
	dc.l	0	;pos where graphic is added in preshift 0
bufcnt:
	dc.w	0	;which one of the 26 routs to be used to copy
shift:
	dc.w	0	;which preshift to copy
buffer:
	ds.l	2*26*16	;16 shifts of the 1st line of the scrolling
linebuffend:
	rept	25	;26 lines scroll
	dc.l	0
	dc.l	0
	dc.w	0
	dc.w	0
	ds.l	2*26*16
	endr
	;**********************************************************




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
