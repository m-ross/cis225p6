TITLE	lab06
; Programmer:	Marcus Ross
; Due:		4 April, 2014
; Description:	

		.MODEL SMALL
		.386
		.STACK 64
;==========================
		.DATA
sum		DW	0					; sum of all inputs
prompt	DB	'Enter a number from -32768 to 32767 (-9999 to exit): ', 36
heading	DB	'Results of Inputs', 10, 13, 36
day		DB	?, ?, ?, 32, 36			; 32 = space
rowHead1	DB	'Greatest number: ', 9, 36	; 9 = tab
rowHead2	DB	'Least number: ', 9, 9, 36
rowHead3	DB	'Sum of all numbers: ', 9, 36
newLine	DB	10, 13, 36
;==========================
		.CODE
		EXTRN	GetDec : NEAR, PutDec : NEAR

Main		PROC	NEAR
		mov	ax, @data	; init data
		mov	ds, ax	; segment register

		call getInput	; get number from keyboard
		cmp	ax, -9999	; input + 9999
		je	finish	; goto end if input = -9999
		call testInput1	; version of proc used in loop, but used only on first pass

begin:	call	getInput	; get number from keyboard
		cmp	ax, -9999	; input + 9999
		je	disp	; goto display if input = -9999
		call	testInput	; check if input is greatest or least
		jmp	begin		; loop

disp:		call	dispRep	; display report
finish:	mov	ax, 4c00h	; return code 0
		int	21h
Main		ENDP
;==========================
dispDate	MACRO
		mov	ah, 2ah	; get date
		int	21h
		dispDay		; macro
		mov	al, dh	; prepare month for display
		xor	ah, ah	; ax = al
		call	PutDec	; display month
		mov	al, dl	; prepare day for display, but don't display yet
		xor	ah, ah	; ax = al
		push	ax		; save value for day
		mov	dl, '/'
		mov	ah, 2h
		int	21h		; display slash
		pop	ax		; load value for day
		xor	ah, ah	; ax = al
		call	PutDec	; display day
		mov	dl, '/'
		mov	ah, 2h
		int	21h		; display slash
		mov	ax, cx	; cx = year
		call	PutDec	; display year
		ENDM
;==========================
dispDay	MACRO			; assumes day of week is in al
		cmp	al, 0		; al - 0
		jne	notSun	; if al != 0, not Sunday, so skip ahead
		mov	day, 'S'	; set day array to 'Sun'
		mov	[day + 1], 'u'
		mov	[day + 2], 'n'
		jmp	finishDay	; finish macro
notSun:	cmp	al, 1		; al - 1
		jne	notMon	; if al != 1, not Monday, so skip ahead
		mov	day, 'M'	; set day array to 'Mon'
		mov	[day + 1], 'o'
		mov	[day + 2], 'n'
		jmp	finishDay	; finish macro
notMon:	cmp	al, 2		; al - 2
		jne	notTue	; if al != 2, not Tuesday, so skip ahead
		mov	day, 'T'	; set day array to 'Tue'
		mov	[day + 1], 'u'
		mov	[day + 2], 'e'
		jmp	finishDay	; finish macro
notTue:	cmp	al, 3		; al - 3
		jne	notWed	; if al != 3, not Wednesday, so skip ahead
		mov	day, 'W'	; set day array to 'Wed'
		mov	[day + 1], 'd'
		mov	[day + 2], 'd'
		jmp	finishDay	; finish macro
notWed:	cmp	al, 4		; al - 4
		jne	notThu	; if al != 4, not Thursday, so skip ahead
		mov	day, 'T'	; set day array to 'Thu'
		mov	[day + 1], 'h'
		mov	[day + 2], 'u'
		jmp	finishDay	; finish macro
notThu:	cmp	al, 5		; al - 5
		jne	notFri	; if al != 5, not Friday, so skip ahead
		mov	day, 'F'	; set day array to 'Fri'
		mov	[day + 1], 'r'
		mov	[day + 2], 'i'
		jmp	finishDay	; finish macro
notFri:	mov	day, 'S'	; set day array to 'Sat'
		mov	[day + 1], 'a'
		mov	[day + 2], 't'
finishDay:	push	dx
		mov	dx, OFFSET day
		mov	ah, 9h
		int	21h		; display day of week
		pop	dx
		ENDM
;==========================
getInput	PROC	NEAR
		mov	dx, OFFSET prompt
		mov	ah, 9h
		int	21h		; display prompt
		call	GetDec	; get input
		ret
		ENDP
;==========================
testInput	PROC	NEAR
		add	sum, ax	; add input to sum
		cmp	ax, bx	; input - greatest
		jle	notGreat	; if input < greatest, skip ahead
		mov	bx, ax	; else input = new greatest
		jmp	notLeast	; finish proc
notGreat:	cmp	ax, cx	; input - least
		jge	notLeast	; if input > least, finish proc
		mov	cx, ax	; else input = new least
notLeast:	ret
		ENDP
;==========================
testInput1	PROC	NEAR		; called before loop so input is never compared to default zero
		add	sum, ax	; add input to sum
		mov	bx, ax	; input = greatest
		mov	cx, ax	; input = least
		ret
		ENDP
;==========================
dispRep	PROC	NEAR
		mov	dx, OFFSET heading
		mov	ah, 9h
		int	21h		; display heading
		push	cx		; macro will use cx
		dispDate		; macro
		pop	cx
		mov	dx, OFFSET newLine
		mov	ah, 9h
		int	21h		; display new line
		int	21h		; display second new line
		mov	dx, OFFSET rowhead1
		int	21h		; display row heading 1
		mov	ax, bx
		call	PutDec	; display greatest number
		mov	dx, OFFSET newLine
		mov	ah, 9h
		int	21h		; display new line
		mov	dx, OFFSET rowHead2
		mov	ah, 9h
		int	21h		; display row heading 2
		mov	ax, cx
		call	PutDec	; display least number
		mov	dx, OFFSET newLine
		mov	ah, 9h
		int	21h		; display new line
		mov	dx, OFFSET rowHead3
		mov	ah, 9h
		int	21h		; display row heading 3
		mov	ax, sum
		call	PutDec	; display least number
		ret
		ENDP
;==========================
	END	Main