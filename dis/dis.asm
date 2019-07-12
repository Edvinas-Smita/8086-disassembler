.model small
.stack 100h

;__________________________________________________________________________________________________
.data
	;								strings
	errorSyntax db 'Neteisingai ivesti parametrai.', 0Ah, 'Sintakse: *.exe ivestiesFailoPavadinimas isvestiesFailoPavadinimas', 0Ah, 024h
	errorOpeningFile db 'Nepavyko atidaryti nurodyto failo. Terminuojama.', 0Ah, 24h
	errorReadingFile db 'Nepavyksta NUSKAITYTI nurodyto failo. Terminuojama.', 0Ah, 24h
	errorCreatingOutputFile db 'Nepavyko sukurti rezultatu failo. Terminuojama.', 0Ah, 024h
	errorOpeningOutputFile db 'Nepavyko atidaryti rezultatu failo. Terminuojama.', 0Ah, 024h
	errorWritingToOutputFile db 'Nepavyko irasyt i rezultatu faila. Terminuojama.', 0Ah, 024h
	strReachedEOF db 26 dup('-'), 'Failas nuskaitytas iki galo!', 26 dup('-'), 024h
	;								strings
	
	;								fileVars
	outFilePtr dw ?
	filePtr dw ?
	;								fileVars
	
	;								fileReading
	extraByteExists db 00		;0- pati failo pradzia ir reikia nuskaityt 2 baitus; 1- vidurys failo ir reikia tik dar vieno baito
	byteAndExtraByte db ?, ?
	unoByte db ?
	dosByte db ?
	tresByte db ?
	cuatroByte db ?
	cincoByte db ?
	
	reachedEOF db 00h
	reuseByte db 00, ?			;+0 ~ ar pernaudot, +1 ~ ka pernaudot
	redirectByte db 00, ?			;+0 ~ ar buvo nukreipta i kita seg., +1 ~ koks nukreipimas (26h, 2Eh, 36h, 3Eh)
	;								fileReading
	
	;								fileWriting
	currentIP dw 0100h
	operationByteCount db 00
	operationBytes db 10 dup(?)
	
	printHowMany db 080h
	printThis db 080h dup(?)
	printHowManyCopy db ?
	printThisCopy db 080h dup(?)
	;								fileWriting
	
	;								komandos
	op_MOV		db '	MOV$'
	op_PUSH		db '	PUSH$'
	op_POP		db '	POP$'
	op_XCHG		db '	XCHG$'
	op_IN		db '	IN$'
	op_OUT		db '	OUT$'
	op_XLAT		db '	XLAT$'
	op_LEA		db '	LEA$'
	op_LDS		db '	LDS$'
	op_LES		db '	LES$'
	op_LAHF		db '	LAHF$'
	op_SAHF		db '	SAHF$'
	op_PUSHF	db '	PUSHF$'
	op_POPF		db '	POPF$'
	
	op_ADD		db '	ADD$'
	op_ADC		db '	ADC$'
	op_INC		db '	INC$'
	op_AAA		db '	AAA$'
	op_BAA		db '	BAA$'	;intel vadina BAA, debugas vadina DAA
	op_SUB		db '	SUB$'
	op_SSB		db '	SSB$'	;intel vadina SSB, debugas vadina SBB
	op_DEC		db '	DEC$'
	op_NEG		db '	NEG$'
	op_CMP		db '	CMP$'
	op_AAS		db '	AAS$'
	op_DAS		db '	DAS$'
	op_MUL		db '	MUL$'
	op_IMUL		db '	IMUL$'
	op_AAM		db '	AAM$'
	op_DIV		db '	DIV$'
	op_IDIV		db '	IDIV$'
	op_AAD		db '	AAD$'
	op_CBW		db '	CBW$'
	op_CWD		db '	CWD$'
	
	op_NOT		db '	NOT$'
	op_SHL		db '	SHL$'
	op_SHR		db '	SHR$'
	op_SAR		db '	SAR$'
	op_ROL		db '	ROL$'
	op_ROR		db '	ROR$'
	op_RCL		db '	RCL$'
	op_RCR		db '	RCR$'
	op_AND		db '	AND$'
	op_TEST		db '	TEST$'
	op_OR		db '	OR$'
	op_XOR		db '	XOR$'
	op_REP		db '	REP$'
	op_MOVS		db '	MOVS$'
	op_CMPS		db '	CMPS$'
	op_SCAS		db '	SCAS$'
	op_LODS		db '	LODS$'
	op_STOS		db '	STOS$'
	op_CALL		db '	CALL$'
	
	op_JMP		db '	JMP$'
	op_RET		db '	RET$'
		op_RETF		db '	RETF$'
	op_JE		db '	JE$'
	op_JL		db '	JL$'
	op_JLE		db '	JLE$'
	op_JB		db '	JB$'
	op_JBE		db '	JBE$'
	op_JP		db '	JP$'
	op_JO		db '	JO$'
	op_JS		db '	JS$'
	op_JNE		db '	JNE$'
	op_JNL		db '	JNL$'
	op_JG		db '	JG$'
	op_JNB		db '	JNB$'
	op_JA		db '	JA$'
	op_JNP		db '	JNP$'
	op_JNO		db '	JNO$'
	op_JNS		db '	JNS$'
	op_LOOP		db '	LOOP$'
	op_LOOPE	db '	LOOPE$'
	op_LOOPNE	db '	LOOPNE$'
	op_JCXZ		db '	JCXZ$'
	op_INT		db '	INT$'
	op_INTO		db '	INTO$'
	op_IRET		db '	IRET$'
	
	op_CLC		db '	CLC$'
	op_CMC		db '	CMC$'
	op_STC		db '	STC$'
	op_CLD		db '	CLD$'
	op_STD		db '	STD$'
	op_CLI		db '	CLI$'
	op_STI		db '	STI$'
	op_HLT		db '	HLT$'
	op_WAIT		db '	WAIT$'
	op_ESC		db '	ESC$'		;neegzituoja????
	op_LOCK		db '	LOCK$'
	
	op_NOP		db '	NOP$'
	op_UNUSED	db ' (unused)$'
	op_unknown	db 09h, 'DB $'
	;								komandos
	
	;								visosFPUKomandos
	op_FADD		db '	FADD$'		;~D8xx
	op_FMUL		db '	FMUL$'
	op_FCOM		db '	FCOM$'
	op_FCOMP	db '	FCOMP$'
	op_FSUB		db '	FSUB$'
	op_FSUBR	db '	FSUBR$'
	op_FDIV		db '	FDIV$'		;~D8xx
	op_FDIVR	db '	FDIVR$'		;~D9xx
	op_FLD		db '	FLD$'
	op_FST		db '	FST$'
	op_FSTP		db '	FSTP$'
	op_FLDENV	db '	FLDENV$'
	op_FLDCW	db '	FLDCW$'
	op_FSTENV	db '	FSTENV$'
	op_FSTCW	db '	FSTCW$'
	op_FXCH		db '	FXCH$'
	op_FCHS		db '	FCHS$'
	op_FABS		db '	FABS$'
	op_FTST		db '	FTST$'
	op_FXAM		db '	FXAM$'
	op_FLD1		db '	FLD1$'
	op_FLDL2T	db '	FLDL2T$'
	op_FLDL2E	db '	FLDL2E$'
	op_FLDPI	db '	FLDPI$'
	op_FLDLG2	db '	FLDLG2$'
	op_FLDLN2	db '	FLDLN2$'
	op_FLDZ		db '	FLDZ$'
	op_F2XM1	db '	F2XM1$'
	op_FYL2X	db '	FYL2X$'
	op_FPTAN	db '	FPTAN$'
	op_FPATAN	db '	FPATAN$'
	op_FXTRAC	db '	FXTRAC$'
	op_FPREM1	db '	FPREM1$'
	op_FDECST	db '	FDECST$'
	op_FINCST	db '	FINCST$'
	op_FPREM	db '	FPREM$'
	op_FYL2XP1	db '	FYL2XP1$'
	op_FSQRT	db '	FSQRT$'
	op_FSINCO	db '	FSINCO$'
	op_FRNDIN	db '	FRNDIN$'
	op_FSCALE	db '	FSCALE$'
	op_FSIN		db '	FSIN$'
	op_FCOS		db '	FCOS$'		;~D9xx
	op_FIADD	db '	FIADD$'		;~DAxx
	op_FIMUL	db '	FIMUL$'
	op_FICOM	db '	FICOM$'
	op_FICOMP	db '	FICOMP$'
	op_FISUB	db '	FISUB$'
	op_FISUBR	db '	FISUBR$'
	op_FIDIV	db '	FIDIV$'
	op_FIDIVR	db '	FIDIVR$'
	op_FCMOVB	db '	FCMOVB$'
	op_FCMOVE	db '	FCMOVE$'
	op_FCMOVU	db '	FCMOVU$'
	op_FUCOMP	db '	FUCOMP$'	;~DAxx
	op_FILD		db '	FILD$'		;~DBxx
	op_FIST		db '	FIST$'
	op_FISTP	db '	FISTP$'
	op_FCMOVN	db '	FCMOVN$'
	op_FENI		db '	FENI$'
	op_FDISI	db '	FDISI$'
	op_FCLEX	db '	FCLEX$'
	op_FINIT	db '	FINIT$'
	op_FSETPM	db '	FSETPM$'
	op_FCOMI	db '	FCOMI$'		;~DBxx
	op_FRSTOR	db '	FRSTOR$'	;~DDxx
	op_FSAVE	db '	FSAVE$'
	op_FSTSW	db '	FSTSW$'
	op_FFREE	db '	FFREE$'		;~DDxx
	op_FADDP	db '	FADDP$'		;~DExx
	op_FMULP	db '	FMULP$'
	op_FCOMPP	db '	FCOMPP$'
	op_FSUBRP	db '	FSUBRP$'
	op_FSUBP	db '	FSUBP$'
	op_FDIVRP	db '	FDIVRP$'
	op_FDIVP	db '	FDIVP$'		;~DExx
	op_FBLD		db '	FBLD$'		;~DFxx
	op_FBSTP	db '	FBSTP$'
	op_FFREEP	db '	FFREEP$'
	op_FCOMIP	db '	FCOMIP$'	;~DFxx
	
	op_FNOP		db '	FNOP$'
	FPU_ST		db ' ST$'
	;								visosFPUKomandos
	
	;								registrai
	regAX db ' AX$'
	regBX db ' BX$'
	regCX db ' CX$'
	regDX db ' DX$'
	regSP db ' SP$'
	regBP db ' BP$'
	regSI db ' SI$'
	regDI db ' DI$'
	
	regAH db ' AH$'
	regBH db ' BH$'
	regCH db ' CH$'
	regDH db ' DH$'
	regAL db ' AL$'
	regBL db ' BL$'
	regCL db ' CL$'
	regDL db ' DL$'
	
	segRegES db ' ES$'
	segRegCS db ' CS$'
	segRegSS db ' SS$'
	segRegDS db ' DS$'
	
	segESUnused db '	SEG ES (unused)$'
	segCSUnused db '	SEG CS (unused)$'
	segSSUnused db '	SEG SS (unused)$'
	segDSUnused db '	SEG DS (unused)$'
	;								registrai
	
	;								EA calc
	WordOrBytePtr db ?			;auto, kai byte ptr[WordOrBytePtr] == 01; neraso, kai == 00
	eaFAR db ' FAR$'			;kai byte ptr[WordOrBytePtr] == 'F'
	
	eaWordPtr db ' WORD PTR$'		;kai byte ptr[WordOrBytePtr] == 'W'
	eaBytePtr db ' BYTE PTR$'		;kai byte ptr[WordOrBytePtr] == 'B'
	eaFloatPtr db ' FLOAT PTR$'		;kai byte ptr[WordOrBytePtr] == '.'
	
	eaBXSI db ' [BX+SI]$'
	eaBXDI db ' [BX+DI]$'
	eaBPSI db ' [BP+SI]$'
	eaBPDI db ' [BP+DI]$'
	eaSI db ' [SI]$'
	eaDI db ' [DI]$'
	eaBX db ' [BX]$'
	
	eaBXSIplus db ' [BX+SI+$'
	eaBXDIplus db ' [BX+DI+$'
	eaBPSIplus db ' [BP+SI+$'
	eaBPDIplus db ' [BP+DI+$'
	eaSIplus db ' [SI+$'
	eaDIplus db ' [DI+$'
	eaBPplus db ' [BP+$'
	eaBXplus db ' [BX+$'
	;								EA calc
	
	programParameter1 db 255 dup(?)
	programParameter2 db 255 dup(?)
	OPKByteBinary db 8 dup (?)
	addressByteBinary db 8 dup (?)
	
	debug db 75 dup ('_'), 'debug', '$'
;__________________________________________________________________________________________________
.code
locals @@
	printStrNoWrite macro kur
		push ax
		push dx
		
		mov ah, 09h
		lea dx, kur
		int 21h
		
		pop dx
		pop ax
	endm
	printStr macro kur
		push dx
		lea dx, kur
		call writeStr
		pop dx
	endm
	
	printCharNoWrite macro char
		push ax
		push dx
		
		mov ah, 02h
		mov dl, char
		int 21h
		
		pop dx
		pop ax
	endm
	printChar macro char
		push dx
		mov dl, char
		call writeChar
		pop dx
	endm
	
	readByte macro which	;I kur skaityti
		push si
		
		lea si, which
		call readByteProc
		
		pop si
	endm
	
	printImmediate macro byWhat			;'W', jei pagal W bita, kuris ne 0-iame OPK bite - BX ~ kur W bitas
		push ax					;'w', jei pagal W bita, kuris 0-iame OPK bite
							;'m', jei pagal adresacijos baito mod
		mov ah, byWhat				;'1', jei overridint i 1 baito spausdinima (default)
		call printImmediateProc			;'2', jei overridint i 2 baitu spausdinima
		
		pop ax
	endm
	
	writeStr proc
		push ax
		push bx
		push cx
		push di
		push si
		
		mov di, dx
		mov cx, 0FFFFh
		mov al, '$'
		repne scasb
		mov cx, di
		sub cx, dx
		dec cx		;kiek tame stringe charu neskaitant $
		
		mov bh, 00
		mov bl, byte ptr[printHowMany]
		add byte ptr[printHowMany], cl
		lea di, printThis
		add di, bx
		mov si, dx
		rep movsb
		
		pop si
		pop di
		pop cx
		pop bx
		pop ax
		ret
	endp
	
	writeChar proc
		push ax
		push bx
		push cx
		push dx
		
		mov bh, 00h
		mov bl, byte ptr[printHowMany]
		inc byte ptr[printHowMany]
		mov byte ptr[printThis+bx], dl
		
		pop dx
		pop cx
		pop bx
		pop ax
		ret
	endp
	
	printHex proc		;(AX)- AL yra spausdinamas hexas
		push bx
		push ax
		
		mov ah, 0
		mov bl, 010h
		div bl
		mov bx, ax
		cmp bl, 09h
		ja @@blAtoF
		add bl, 030h
		printChar bl
		jmp @@doneBL
		@@blAtoF:
		add bl, 037h
		printChar bl
		@@doneBL:
		
		cmp bh, 09h
		ja @@bhAtoF
		add bh, 030h
		printChar bh
		jmp @@doneBH
		@@bhAtoF:
		add bh, 037h
		printChar bh
		@@doneBH:
		
		pop ax
		pop bx
	ret
	endp
	
	printImmediateProc proc
		readByte tresByte
		
		cmp ah, 'W'
		jne @@notCustomBit
			cmp byte ptr[addressbyteBinary+bx], 01h
			je @@print2
			jmp @@print1
		@@notCustomBit:
		
		cmp ah, 'w'
		jne @@not0thBit
			cmp byte ptr[OPKByteBinary+7], 01h
			je @@print2
			jmp @@print1
		@@not0thBit:
		
		cmp ah, 'm'
		jne @@notMod
			cmp byte ptr[addressByteBinary], 01h
			je @@print2
			jmp @@print1
		@@notMod:
		
		cmp ah, '2'
		je @@print2
		
		@@print1:
			mov al, byte ptr[tresByte]
			call printHex
			ret
		@@print2:
			readByte cuatroByte
			mov al, byte ptr[cuatroByte]
			call printHex
			mov al, byte ptr[tresByte]
			call printHex
			ret
	endp
	
	readByteProc proc		;si ateina is macro
		push ax
		push bx
		push cx
		
		mov ah, 03Fh
		mov bx, word ptr[filePtr]
		cmp byte ptr[extraByteExists], 01h
		jne @@readDuo
		mov cx, 1
		lea dx, byteAndExtraByte+1
		jmp @@nowRead
		@@readDuo:
		mov byte ptr[extraByteExists], 01h
		mov cx, 2
		lea dx, byteAndExtraByte
		@@nowRead:
		int 21h
		jnc @@skaitymasVeikia
		printStr errorReadingFile
		.exit
		@@skaitymasVeikia:
		cmp ax, 0000h
		jne @@gotSomething
		mov byte ptr[reachedEOF], 01h
		@@gotSomething:
		mov al, byte ptr[byteAndExtraByte]
		mov byte ptr[si], al
		mov bh, 00h
		mov bl, byte ptr[operationByteCount]
		inc byte ptr[operationByteCount]
		mov byte ptr[operationBytes+bx], al
		
		mov al, byte ptr [byteAndExtraByte+1]
		mov byte ptr[byteAndExtraByte], al
		mov byte ptr[byteAndExtraByte+1], 00h
		
		pop cx
		pop bx
		pop ax
		ret
	endp
	
	makeBinary proc		;AL-baitas, kuri paverst i binary; SI-bufferis i kuri talpint binary
		push bx
		push cx
		push dx
		
		mov ah, 0
		mov dx, 02h
		mov cx, 08h
		@@binaryGavimas:
			mov bx, cx
			div dl
			mov byte ptr[si+bx-1], ah
			mov ah, 0
		loop @@binaryGavimas
		
		pop dx
		pop cx
		pop bx
		ret
	endp
	readByteMakeBinaryUno proc
		push ax
		push dx
		push si
		
		lea si, unoByte
		call readByteProc
		mov al, byte ptr[unoByte]
		lea si, OPKByteBinary
		call MakeBinary
		
		pop ax
		pop si
		pop dx
		ret
	endp
	readByteMakeBinaryDos proc
		push ax
		push dx
		push si
		
		lea si, dosByte
		call readByteProc
		mov al, byte ptr[dosByte]
		lea si, addressByteBinary
		call MakeBinary
		
		pop ax
		pop si
		pop dx
		ret
	endp
	
	printUnknown proc
		printStr op_unknown
		mov al, byte ptr[unoByte]
		call printHex
		
		pop ax
		ret
	endp
	printUnknownReuseDos proc
		printStr op_unknown
		mov al, byte ptr[unoByte]
		call printHex
		
		mov al, byte ptr[dosByte]
		mov byte ptr[reuseByte+1], al
		mov byte ptr[reuseByte], 01h
		dec byte ptr[operationByteCount]
		
		pop ax
		ret
	endp
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	decipher proc
		push ax
		push si
		
		cmp byte ptr[reuseByte], 01h
		je @@reuse
		call readByteMakeBinaryUno
		jmp @@readByte
		@@reuse:
		mov byte ptr[reuseByte], 00h
		inc byte ptr[operationByteCount]
		mov al, byte ptr[reuseByte+1]
		mov byte ptr[unoByte], al
		mov byte ptr[operationBytes], al
		lea si, OPKByteBinary
		call makeBinary
		@@readByte:
		
		mov al, 07h
		call printHex
		mov al, 034h
		call printHex
		printChar ':'
		mov al, byte ptr[currentIP+1]
		call printHex
		mov al, byte ptr[currentIP]
		call printHex
		printChar ' '
		
		cmp byte ptr[unoByte], 026h
		jne @@notRedirectToES
		mov byte ptr[redirectByte+1], 026h
		jmp @@redirection
		@@notRedirectToES:
		cmp byte ptr[unoByte], 02Eh
		jne @@notRedirectToCS
		mov byte ptr[redirectByte+1], 02Eh
		jmp @@redirection
		@@notRedirectToCS:
		cmp byte ptr[unoByte], 036h
		jne @@notRedirectToSS
		mov byte ptr[redirectByte+1], 026h
		jmp @@redirection
		@@notRedirectToSS:
		cmp byte ptr[unoByte], 03Eh
		jne @@notRedirection
		mov byte ptr[redirectByte+1], 03Eh
		jmp @@redirection
		
		jmp @@notRedirection
		@@redirection:
		mov byte ptr[redirectByte], 01h
		call readByteMakeBinaryUno
		@@notRedirection:
		
		pop si
		pop ax
;============================================================================================================================================================================================================
		
		
;vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvSTRMANIP
		cmp byte ptr[unoByte], 0F2h
		jb @@notREP
		cmp byte ptr[unoByte], 0F3h
		ja @@notREP
		printStr op_REP
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@skipN
		printChar 'N'
		@@skipN:
		printChar 'E'
		
		readByte unoByte
		cmp byte ptr[unoByte], 0A4h
		jb @@repUnused
		cmp byte ptr[unoByte], 0A7h
		jbe @@repUsed
		
		cmp byte ptr[unoByte], 0AAh
		jb @@repUnused
		cmp byte ptr[unoByte], 0AFh
		jbe @@repUsed
		
		@@repUnused:
		printStr op_UNUSED
		push ax
		mov al, byte ptr[unoByte]
		mov byte ptr[reuseByte+1], al
		pop ax
		mov byte ptr[reuseByte], 01h
		dec byte ptr[operationByteCount]
		ret
		@@notREP:
		@@repUsed:
		
		cmp byte ptr[unoByte], 0A4h
		jb @@notMOVS
		cmp byte ptr[unoByte], 0A5h
		ja @@notMOVS
		printStr op_MOVS
		call strManipBOrW
		ret
		@@notMOVS:
		
		cmp byte ptr[unoByte], 0A6h
		jb @@notCMPS
		cmp byte ptr[unoByte], 0A7h
		ja @@notCMPS
		printStr op_CMPS
		call strManipBOrW
		ret
		@@notCMPS:
		
		cmp byte ptr[unoByte], 0AAh
		jb @@notSTOS
		cmp byte ptr[unoByte], 0ABh
		ja @@notSTOS
		printStr op_STOS
		call strManipBOrW
		ret
		@@notSTOS:
		
		cmp byte ptr[unoByte], 0ACh
		jb @@notLODS
		cmp byte ptr[unoByte], 0ADh
		ja @@notLODS
		printStr op_LODS
		call strManipBOrW
		ret
		@@notLODS:
		
		cmp byte ptr[unoByte], 0AEh
		jb @@notSCAS
		cmp byte ptr[unoByte], 0AFh
		ja @@notSCAS
		printStr op_SCAS
		call strManipBOrW
		ret
		@@notSCAS:
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^STRMANIP
		
		cmp byte ptr[unoByte], 080h
		jb @@00to7F
		jmp @@FAR80toFF
		@@00to7F:
			cmp byte ptr[unoByte], 040h
			jb @@00to3F
			jmp @@FAR40to7F
			@@00to3F:
				cmp byte ptr[unoByte], 020h
				jb @@00to1F
				jmp @@FAR20to3F
				@@00to1F:
					cmp byte ptr[unoByte], 00h
					jb @@notADDtype1
					cmp byte ptr[unoByte], 03h
					ja @@notADDtype1
					printStr op_ADD
					call addressDW
					ret
					@@notADDtype1:
					
					cmp byte ptr[unoByte], 04h
					jb @@notADDtype3
					cmp byte ptr[unoByte], 05h
					ja @@notADDtype3
					printStr op_ADD
					call immToAccu
					ret
					@@notADDtype3:
					
					cmp byte ptr[unoByte], 08h
					jb @@notORtype1
					cmp byte ptr[unoByte], 0Bh
					ja @@notORtype1
					printStr op_OR
					call addressDW
					ret
					@@notORtype1:
					
					cmp byte ptr[unoByte], 0Ch
					jb @@notORtype3
					cmp byte ptr[unoByte], 0Dh
					ja @@notORtype3
					printStr op_OR
					call immToAccu
					ret
					@@notORtype3:
					
					cmp byte ptr[unoByte], 010h
					jb @@notADCtype1
					cmp byte ptr[unoByte], 013h
					ja @@notADCtype1
					printStr op_ADC
					call addressDW
					ret
					@@notADCtype1:
					
					cmp byte ptr[unoByte], 014h
					jb @@notADCtype3
					cmp byte ptr[unoByte], 015h
					ja @@notADCtype3
					printStr op_ADC
					call immToAccu
					ret
					@@notADCtype3:
					
					cmp byte ptr[unoByte], 018h
					jb @@notSSBtype1
					cmp byte ptr[unoByte], 01Bh
					ja @@notSSBtype1
					printStr op_SSB
					call addressDW
					ret
					@@notSSBtype1:
					
					cmp byte ptr[unoByte], 01Ch
					jb @@notSSBtype3
					cmp byte ptr[unoByte], 01Dh
					ja @@notSSBtype3
					printStr op_SSB
					call immToAccu
					ret
					@@notSSBtype3:
					
					cmp word ptr[OPKByteBinary+5], 0101h
					jne @@notPUSHtype3orPOPype3
					cmp byte ptr[unoByte], 06h
					jb @@notPUSHtype3orPOPype3
					cmp byte ptr[unoByte], 01Fh
					ja @@notPUSHtype3orPOPype3
					cmp byte ptr[unoByte], 0Fh
					je @@notPUSHtype3orPOPype3
					shr byte ptr[unoByte], 1
					jc @@POPtype3
					printStr op_PUSH
					jmp @@nowPrintSegReg
					@@POPtype3:
					printStr op_POP
					@@nowPrintSegReg:
					push cx
					mov cx, 000Ch
					and cl, byte ptr[unoByte]
					cmp cl, 0
					jne @@notES
					printStr segRegES
					jmp @@doneWithThis
					@@notES:
					cmp cl, 04h
					jne @@notCS
					printStr segRegCS
					jmp @@doneWithThis
					@@notCS:
					cmp cl, 08h
					jne @@notSS
					printStr segRegSS
					jmp @@doneWithThis
					@@notSS:
					printStr segRegDS
					@@doneWithThis:
					pop cx
					ret
					@@notPUSHtype3orPOPype3:
					
					call printUnknown
					
				@@FAR20to3F:
					
					cmp byte ptr[unoByte], 020h
					jb @@notANDtype1
					cmp byte ptr[unoByte], 023h
					ja @@notANDtype1
					printStr op_AND
					call addressDW
					ret
					@@notANDtype1:
					
					cmp byte ptr[unoByte], 024h
					jb @@notANDtype3
					cmp byte ptr[unoByte], 025h
					ja @@notANDtype3
					printStr op_AND
					call immToAccu
					ret
					@@notANDtype3:
					
					cmp byte ptr[unoByte], 027h
					jne @@notBAA
					printStr op_BAA
					ret
					@@notBAA:
					
					cmp byte ptr[unoByte], 028h
					jb @@notSUBtype1
					cmp byte ptr[unoByte], 02Bh
					ja @@notSUBtype1
					printStr op_SUB
					call addressDW
					ret
					@@notSUBtype1:
					
					cmp byte ptr[unoByte], 02Ch
					jb @@notSUBtype3
					cmp byte ptr[unoByte], 02Dh
					ja @@notSUBtype3
					printStr op_SUB
					call immToAccu
					ret
					@@notSUBtype3:
					
					cmp byte ptr[unoByte], 02Fh
					jne @@notDAS
					printStr op_DAS
					ret
					@@notDAS:
					
					cmp byte ptr[unoByte], 030h
					jb @@notXORtype1
					cmp byte ptr[unoByte], 033h
					ja @@notXORtype1
					printStr op_XOR
					call addressDW
					ret
					@@notXORtype1:
					
					cmp byte ptr[unoByte], 034h
					jb @@notXORtype3
					cmp byte ptr[unoByte], 035h
					ja @@notXORtype3
					printStr op_XOR
					call immToAccu
					ret
					@@notXORtype3:
					
					cmp byte ptr[unoByte], 037h
					jne @@notAAA
					printStr op_AAA
					ret
					@@notAAA:
					
					cmp byte ptr[unoByte], 038h
					jb @@notCMPtype1
					cmp byte ptr[unoByte], 03Bh
					ja @@notCMPtype1
					printStr op_CMP
					call addressDW
					ret
					@@notCMPtype1:
					
					cmp byte ptr[unoByte], 03Ch
					jb @@notCMPtype2
					cmp byte ptr[unoByte], 03Dh
					ja @@notCMPtype2
					printStr op_CMP
					call immToAccu
					ret
					@@notCMPtype2:
					
					cmp byte ptr[unoByte], 03Fh
					jne @@notAAS
					printStr op_AAS
					ret
					@@notAAS:
					
					call printUnknown
					
			@@FAR40to7F:
				cmp byte ptr[unoByte], 060h
				jb @@40to5F
				jmp @@FAR60to7F
				@@40to5F:
					
					cmp byte ptr[unoByte], 040h
					jb @@notINCtype2
					cmp byte ptr[unoByte], 047h
					ja @@notINCtype2
					printStr op_INC
					push bx
					mov bx, -0005h
					call printRegWord
					pop bx
					ret
					@@notINCtype2:
					
					cmp byte ptr[unoByte], 048h
					jb @@notDECtype2
					cmp byte ptr[unoByte], 04Fh
					ja @@notDECtype2
					printStr op_DEC
					push bx
					mov bx, -0005h
					call printRegWord
					pop bx
					ret
					@@notDECtype2:
					
					cmp byte ptr[unoByte], 050h
					jb @@notPUSHtype2
					cmp byte ptr[unoByte], 057h
					ja @@notPUSHtype2
					printStr op_PUSH
					push bx
					mov bx, -0005h
					call printReg
					pop bx
					ret
					@@notPUSHtype2:
					
					cmp byte ptr[unoByte], 058h
					jb @@notPOPtype2
					cmp byte ptr[unoByte], 05Fh
					ja @@notPOPtype2
					printStr op_POP
					push bx
					mov bx, -0005h
					call printRegWord
					pop bx
					ret
					@@notPOPtype2:
					
					call printUnknown
					
				@@FAR60to7F:
					
					cmp byte ptr[unoByte], 070h
					jb @@not70to7F
					cmp byte ptr[unoByte], 07Fh
					ja @@not70to7F
					call decipher70to7F
					ret
					@@not70to7F:
					
					call printUnknown
		
		@@FAR80toFF:
			cmp byte ptr[unoByte], 0C0h
			jb @@80toBF
			jmp @@FARC0toFF
			@@80toBF:
				cmp byte ptr[unoByte], 0A0h
				jb @@80to9F
				jmp @@FARA0toBF
				@@80to9F:
					cmp byte ptr[unoByte], 080h
					jb @@not80to83
					cmp byte ptr[unoByte], 083h
					ja @@not80to83
					call decipher80to83
					ret
					@@not80to83:
					
					cmp byte ptr[unoByte], 084h
					jb @@notTESTtype1
					cmp byte ptr[unoByte], 085h
					ja @@notTESTtype1
					printStr op_TEST
					call addressDW
					ret
					@@notTESTtype1:
					
					cmp byte ptr[unoByte], 086h
					jb @@notXCHGtype1
					cmp byte ptr[unoByte], 087h
					ja @@notXCHGtype1
					printStr op_XCHG
					mov bx, 0000h
					call printReg
					printChar ','
					call readByteMakeBinaryDos
					mov byte ptr[WordOrBytePtr], 01h
					call printRM
					ret
					@@notXCHGtype1:
					
					cmp byte ptr[unoByte], 088h
					jb @@notMOVtype1
					cmp byte ptr[unoByte], 08Bh
					ja @@notMOVtype1
					printStr op_MOV
					call addressDW
					ret
					@@notMOVtype1:
					
					cmp byte ptr[unoByte], 08Ch
					je @@MOVtype6or7
					cmp byte ptr[unoByte], 08Eh
					je @@MOVtype6or7
					jmp @@notMOVtype6or7
					@@MOVtype6or7:
					printStr op_MOV
					call segmentMOV
					ret
					@@notMOVtype6or7:
					
					cmp byte ptr[unoByte], 08Dh
					jne @@notLEA
					printStr op_LEA
					call address
					ret
					@@notLEA:
					
					cmp byte ptr[unoByte], 08Fh
					jne @@notPOPtype1
					printStr op_POP
					call readByteMakeBinaryDos
					mov byte ptr[WordOrBytePtr], 00h
					call printRM
					ret
					@@notPOPtype1:
					
					cmp byte ptr[unoByte], 090h
					jb @@notXCHGtype2
					cmp byte ptr[unoByte], 097h
					ja @@notXCHGtype2
					printStr op_XCHG
					printStr regAX
					printChar ','
					push bx
					mov bx, -0005h
					call printRegWord
					pop bx
					ret
					@@notXCHGtype2:
					
					cmp byte ptr[unoByte], 098h
					jne @@notCBW
					printStr op_CBW
					ret
					@@notCBW:
					
					cmp byte ptr[unoByte], 099h
					jne @@notCWD
					printStr op_CWD
					ret
					@@notCWD:
					
					cmp byte ptr[unoByte], 09Ah
					jne @@notCALLtype2
					printStr op_CALL
					printChar ' '
					push ax
					readByte dosByte
					readByte tresByte
					readByte cuatroByte
					readByte cincoByte
					mov al, byte ptr[cincoByte]
					call printHex
					mov al, byte ptr[cuatroByte]
					call printHex
					printChar ':'
					mov al, byte ptr[tresByte]
					call printHex
					mov al, byte ptr[dosByte]
					call printHex
					pop ax
					ret
					@@notCALLtype2:
					
					cmp byte ptr[unoByte], 09Bh
					jne @@notWAIT
					printStr op_WAIT
					printStr op_UNUSED
					ret
					@@notWAIT:
					
					cmp byte ptr[unoByte], 09Ch
					jne @@notPUSHF
					printStr op_PUSHF
					ret
					@@notPUSHF:
					
					cmp byte ptr[unoByte], 09Dh
					jne @@notPOPF
					printStr op_POPF
					ret
					@@notPOPF:
					
					cmp byte ptr[unoByte], 09Eh
					jne @@notSAHF
					printStr op_SAHF
					ret
					@@notSAHF:
					
					cmp byte ptr[unoByte], 09Fh
					jne @@notLAHF
					printStr op_LAHF
					ret
					@@notLAHF:
					
					call printUnknown
					
				@@FARA0toBF:
					
					cmp byte ptr[unoByte], 0A0h
					jb @@notMOVtype4or5
					cmp byte ptr[unoByte], 0A3h
					ja @@notMOVtype4or5
					call specialMOV
					ret
					@@notMOVtype4or5:

					cmp byte ptr[unoByte], 0A8h
					jb @@notTESTtype3
					cmp byte ptr[unoByte], 0A9h
					ja @@notTESTtype3
					printStr op_TEST
					call immToAccu
					ret
					@@notTESTtype3:
				
					cmp byte ptr[unoByte], 0B0h
					jb @@notMOVtype3
					cmp byte ptr[unoByte], 0BFh
					ja @@notMOVtype3
					printStr op_MOV
					call OPKByteWREG
					ret
					@@notMOVtype3:
					
					call printUnknown
				
			@@FARC0toFF:
				cmp byte ptr[unoByte], 0E0h
				jb @@C0toDF
				jmp @@FARE0toFF
				@@C0toDF:
				
					cmp byte ptr[unoByte], 0C2h
					jne @@notRETtype2
					printStr op_RET
					printChar ' '
					printImmediate '2'
					ret
					@@notRETtype2:			;C0, C1 irgi pagal pletini???
					
					cmp byte ptr[unoByte], 0C3h
					jne @@notRETtype1
					printStr op_RET
					ret
					@@notRETtype1:
					
					cmp byte ptr[unoByte], 0C4h
					jne @@notLES
					printStr op_LES
					call address
					ret
					@@notLES:
					
					cmp byte ptr[unoByte], 0C5h
					jne @@notLDS
					printStr op_LDS
					call address
					ret
					@@notLDS:
					
					cmp byte ptr[unoByte], 0C6h
					jb @@notMOVtype2
					cmp byte ptr[unoByte], 0C7h
					ja @@notMOVtype2
					printStr op_MOV
					call readByteMakeBinaryDos
					mov byte ptr[WordOrBytePtr], 01h
					call printRM
					printChar ','
					printChar ' '
					printImmediate 'w'
					ret
					@@notMOVtype2:
					
					cmp byte ptr[unoByte], 0CAh
					jne @@notRETtype4
					printStr op_RETF
					printChar ' '
					printImmediate '2'
					ret
					@@notRETtype4:
					
					cmp byte ptr[unoByte], 0CBh
					jne @@notRETtype3
					printStr op_RETF
					ret
					@@notRETtype3:
					
					cmp byte ptr[unoByte], 0CCh
					jne @@notINTtype2
					printStr op_INT
					printChar ' '
					printChar '3'
					ret
					@@notINTtype2:
					
					cmp byte ptr[unoByte], 0CDh
					jne @@notINTtype1
					printStr op_INT
					printChar ' '
					printImmediate '1'
					ret
					@@notINTtype1:
					
					cmp byte ptr[unoByte], 0CEh
					jne @@notINTO
					printStr op_INTO
					ret
					@@notINTO:
					
					cmp byte ptr[unoByte], 0CFh
					jne @@notIRET
					printStr op_IRET
					ret
					@@notIRET:
					
					cmp byte ptr[unoByte], 0D0h
					jb @@notD0toD3
					cmp byte ptr[unoByte], 0D3h
					ja @@notD0toD3
					call decipherD0toD3
					ret
					@@notD0toD3:
					
					cmp byte ptr[unoByte], 0D4h		;?????????
					jne @@notAAM
					printStr op_AAM
					printChar ' '
					printImmediate '1'
					ret
					@@notAAM:
					
					cmp byte ptr[unoByte], 0D5h		;?????????
					jne @@notAAD
					printStr op_AAD
					printChar ' '
					printImmediate '1'
					ret
					@@notAAD:				;D6 ~ N/A
					
					cmp byte ptr[unoByte], 0D7h
					jne @@notXLAT
					printStr op_XLAT
					ret
					@@notXLAT:				;D8, D9, DA, DB, DC, DD, DE, DF ~ FPU su pletiniais
					
					cmp byte ptr[unoByte], 0D9h
					jne @@notTransFPU
					call decipherD9
					ret
					@@notTransFPU:
					
					call printUnknown
					
				@@FARE0toFF:
					
					cmp byte ptr[unoByte], 0E0h
					jne @@notLOOPNE
					printStr op_LOOPNE
					call calcJMP
					ret
					@@notLOOPNE:
					
					cmp byte ptr[unoByte], 0E1h
					jne @@notLOOPE
					printStr op_LOOPE
					call calcJMP
					ret
					@@notLOOPE:
					
					cmp byte ptr[unoByte], 0E2h
					jne @@notLOOP
					printStr op_LOOP
					call calcJMP
					ret
					@@notLOOP:
					
					cmp byte ptr[unoByte], 0E3h
					jne @@notJCXZ
					printStr op_JCXZ
					call calcJMP
					ret
					@@notJCXZ:
					
					cmp byte ptr[unoByte], 0E4h
					jb @@notINtype1
					cmp byte ptr[unoByte], 0E5h
					ja @@notINtype1
					printStr op_IN
					cmp byte ptr[unoByte], 0E4h
					je @@INAL1
					printStr regAX
					jmp @@doneINtype1
					@@INAL1:
					printStr regAL
					@@doneINtype1:
					printChar ','
					printChar ' '
					printImmediate '1'
					ret
					@@notINtype1:
					
					cmp byte ptr[unoByte], 0E6h
					jb @@notOUTtype1
					cmp byte ptr[unoByte], 0E7h
					ja @@notOUTtype1
					printStr op_OUT
					printChar ' '
					printImmediate '1'
					printChar ','
					cmp byte ptr[unoByte], 0E6h
					je @@OUTAL1
					printStr regAX
					ret
					@@OUTAL1:
					printStr regAL
					ret
					@@notOUTtype1:
					
					cmp byte ptr[unoByte], 0E8h
					jne @@notCALLtype1
					printStr op_CALL
					printChar ' '
					push ax
					readByte dosByte
					readByte tresByte
					mov ax, word ptr[currentIP]
					add ax, word ptr[dosByte]
					xchg al, ah
					call printHex
					xchg al, ah
					call printHex
					pop ax
					ret
					@@notCALLtype1:
					
					cmp byte ptr[unoByte], 0E9h
					jne @@notJMPtype1
					printStr op_JMP
					printChar ' '
					push ax
					readByte dosByte
					readByte tresByte
					mov ax, word ptr[currentIP]
					add ax, word ptr[dosByte]
					xchg al, ah
					call printHex
					xchg al, ah
					call printHex
					pop ax
					ret
					@@notJMPtype1:
					
					cmp byte ptr[unoByte], 0EAh
					jne @@notJMPtype4
					printStr op_JMP
					printChar ' '
					push ax
					readByte dosByte
					readByte tresByte
					readByte cuatroByte
					readByte cincoByte
					mov al, byte ptr[cincoByte]
					call printHex
					mov al, byte ptr[cuatroByte]
					call printHex
					printChar ':'
					mov al, byte ptr[tresByte]
					call printHex
					mov al, byte ptr[dosByte]
					call printHex
					pop ax
					ret
					@@notJMPtype4:
					
					cmp byte ptr[unoByte], 0EBh
					jne @@notJMPtype2
					printStr op_JMP
					call calcJMP
					ret
					@@notJMPtype2:
					
					cmp byte ptr[unoByte], 0ECh
					jb @@notINtype2
					cmp byte ptr[unoByte], 0EDh
					ja @@notINtype2
					printStr op_IN
					cmp byte ptr[unoByte], 0ECh
					je @@INAL2
					printStr regAX
					jmp @@doneINtype2
					@@INAL2:
					printStr regAL
					@@doneINtype2:
					printChar ','
					printStr regDX
					ret
					@@notINtype2:
					
					cmp byte ptr[unoByte], 0EEh
					jb @@notOUTtype2
					cmp byte ptr[unoByte], 0EFh
					ja @@notOUTtype2
					printStr op_OUT
					printStr regDX
					printChar ','
					cmp byte ptr[unoByte], 0EEh
					je @@OUTAL2
					printStr regAX
					jmp @@doneOUTtype2
					@@OUTAL2:
					printStr regAL
					@@doneOUTtype2:
					ret
					@@notOUTtype2:
				
					cmp byte ptr[unoByte], 0F0h
					jne @@notLOCK
					printStr op_LOCK
					printStr op_UNUSED
					ret
					@@notLOCK:
					
					cmp byte ptr[unoByte], 0F4h
					jne @@notHLT
					printStr op_HLT
					ret
					@@notHLT:
					
					cmp byte ptr[unoByte], 0F5h
					jne @@notCMC
					printStr op_CMC
					ret
					@@notCMC:
					
					cmp byte ptr[unoByte], 0F6h
					jb @@notF6toF7
					cmp byte ptr[unoByte], 0F7h
					ja @@notF6toF7
					call decipherF6toF7
					ret
					@@notF6toF7:
					
					cmp byte ptr[unoByte], 0F8h
					jne @@notCLC
					printStr op_CLC
					ret
					@@notCLC:
					
					cmp byte ptr[unoByte], 0F9h
					jne @@notSTC
					printStr op_STC
					ret
					@@notSTC:
					
					cmp byte ptr[unoByte], 0FAh
					jne @@notCLI
					printStr op_CLI
					ret
					@@notCLI:
					
					cmp byte ptr[unoByte], 0FBh
					jne @@notSTI
					printStr op_STI
					ret
					@@notSTI:
					
					cmp byte ptr[unoByte], 0FCh
					jne @@notCLD
					printStr op_CLD
					ret
					@@notCLD:
					
					cmp byte ptr[unoByte], 0FDh
					jne @@notSTD
					printStr op_STD
					ret
					@@notSTD:
					
					cmp byte ptr[unoByte], 0FEh
					jb @@notFForFE
					call decipherFForFE
					ret
					@@notFForFE:
					
					call printUnknown
	endp

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	decipherFForFE proc
		call readByteMakeBinaryDos
		
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_INC		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_DEC		;001
				mov byte ptr[WordOrBytePtr], 01h
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_CALL		;010
				mov byte ptr[WordOrBytePtr], 01h
				jmp @@fin
				@@OPKextra011:
				printStr op_CALL		;011
				mov byte ptr[WordOrBytePtr], 'F'
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_JMP		;100
				mov byte ptr[WordOrBytePtr], 01h
				jmp @@fin
				@@OPKextra101:
				printStr op_JMP		;101
				mov byte ptr[WordOrBytePtr], 'F'
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_PUSH	;110
				mov byte ptr[WordOrBytePtr], 01h
				jmp @@fin
				@@OPKextra111:
				call printUnknownReuseDos	;111
		@@fin:
		call printRM
		ret
	endp
	decipherF6toF7 proc
		call readByteMakeBinaryDos
		
		mov byte ptr[WordOrBytePtr], 01h
		
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_TEST		;000
				call printRM
				printChar ','
				printChar ' '
				printImmediate 'w'
				ret
				@@OPKextra001:
				call printUnknownReuseDos	;001
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_NOT		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_NEG		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_MUL		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_IMUL		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_DIV		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_IDIV		;111
		@@fin:
		call printRM
		ret
	endp
	decipherD0toD3 proc
		call readByteMakeBinaryDos
		
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_ROL		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_ROR		;001
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_RCL		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_RCR		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_SHL		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_SHR		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				call printUnknownReuseDos	;110
				@@OPKextra111:
				printStr op_SAR		;111
		@@fin:
		call addressVW
		ret
	endp
	decipher80to83 proc
		cmp byte ptr[unoByte], 082h
		jne @@exists
		call printUnknown
		@@exists:
		
		call readByteMakeBinaryDos
		
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_ADD		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_OR		;001
				call printRM
				printChar ','
				printChar ' '
				printImmediate 'w'
				ret
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_ADC		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_SSB		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_AND		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_SUB		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_XOR		;110
				call printRM
				printChar ','
				printChar ' '
				printImmediate 'w'
				ret
				@@OPKextra111:
				printStr op_CMP		;111
		@@fin:
		call addressSW
		ret
	endp
	decipher70to7F proc
		cmp byte ptr[unoByte], 078h
		jb @@70to77
		jmp @@FAR78to7F
		@@70to77:
			cmp byte ptr[unoByte], 073h
			ja @@74to77
				cmp byte ptr[unoByte], 071h
				ja @@72or73
					cmp byte ptr[unoByte], 070h
					jne @@notJO
						printStr op_JO
						jmp @@fin
						@@notJO:
						
						printStr op_JNO
						jmp @@fin
				@@72or73:
						cmp byte ptr[unoByte], 072h
						jne @@notJB
						printStr op_JB
						jmp @@fin
						@@notJB:
						
						printStr op_JNB
						jmp @@fin
			@@74to77:
				cmp byte ptr[unoByte], 075h
				ja @@76or77
					cmp byte ptr[unoByte], 074h
					jne @@notJE
						printStr op_JE
						jmp @@fin
						@@notJE:
						
						printStr op_JNE
						jmp @@fin
				@@76or77:
						cmp byte ptr[unoByte], 076h
						jne @@notJBE
						printStr op_JBE
						jmp @@fin
						@@notJBE:
						
						printStr op_JA
						jmp @@fin
		@@FAR78to7F:
			cmp byte ptr[unoByte], 07Bh
			ja @@7Cto7F
				cmp byte ptr[unoByte], 079h
				ja @@7Aor7B
					cmp byte ptr[unoByte], 078h
					jne @@notJS
						printStr op_JS
						jmp @@fin
						@@notJS:
						
						printStr op_JNS
						jmp @@fin
				@@7Aor7B:
					cmp byte ptr[unoByte], 07Ah
					jne @@notJP
						printStr op_JP
						jmp @@fin
						@@notJP:
						
						printStr op_JNP
						jmp @@fin
			@@7Cto7F:
				cmp byte ptr[unoByte], 07Dh
				ja @@7Eor7F
					cmp byte ptr[unoByte], 07Ch
					jne @@notJL
						printStr op_JL
						jmp @@fin
						@@notJL:
						
						printStr op_JNL
						jmp @@fin
				@@7Eor7F:
					cmp byte ptr[unoByte], 07Eh
					jne @@notJLE
						printStr op_JLE
						jmp @@fin
						@@notJLE:
						
						printStr op_JG
						
		@@fin:
		call calcJMP
		ret
	endp
	decipherD9 proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherD9xxFPUExpansion
		ret
		@@notExpandedOPK:		;C0toFF
		cmp byte ptr[dosByte], 0E0h
		jb @@C0toDF
		jmp @@FARE0toFF
		@@C0toDF:
			cmp byte ptr[dosByte], 0D0h
			jb @@C0toCF
			jmp @@FARD0toDF
			@@C0toCF:
				cmp byte ptr[dosByte], 0C0h
				jb @@notFLDmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFLDmod11
				printStr op_FLD
				printStr FPU_ST
				printChar '('
				push ax
				mov al, byte ptr[unoByte]
				sub al, 090h
				printChar al
				printChar ')'
				pop ax
				ret
				@@notFLDmod11:
				
				printStr op_FXCH
				printStr FPU_ST
				printChar '('
				push ax
				mov al, byte ptr[unoByte]
				sub al, 098h
				printChar al
				printChar ')'
				pop ax
				ret
			@@FARD0toDF:
				
				cmp byte ptr[dosByte], 0D0h
				jne @@notFNOP
				printStr op_FNOP
				ret
				@@notFNOP:
				
				call printUnknownReuseDos
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				
				cmp byte ptr[dosByte], 0E0h
				jne @@notFCHS
				printStr op_FCHS
				ret
				@@notFCHS:
				
				cmp byte ptr[dosByte], 0E1h
				jne @@notFABS
				printStr op_FABS
				ret
				@@notFABS:
				
				cmp byte ptr[dosByte], 0E4h
				jne @@notFTST
				printStr op_FTST
				ret
				@@notFTST:
				
				cmp byte ptr[dosByte], 0E5h
				jne @@notFXAM
				printStr op_FXAM
				ret
				@@notFXAM:
				
				cmp byte ptr[dosByte], 0E8h	;FPU transcendentine
				jne @@notFLD1
				printStr op_FLD1
				ret
				@@notFLD1:
				
				cmp byte ptr[dosByte], 0E9h	;FPU transcendentine
				jne @@notFLDL2T
				printStr op_FLDL2T
				ret
				@@notFLDL2T:
				
				cmp byte ptr[dosByte], 0EAh	;FPU transcendentine
				jne @@notFLDL2E
				printStr op_FLDL2E
				ret
				@@notFLDL2E:
				
				cmp byte ptr[dosByte], 0EBh	;FPU transcendentine
				jne @@notFLDPI
				printStr op_FLDPI
				ret
				@@notFLDPI:
				
				cmp byte ptr[dosByte], 0ECh	;FPU transcendentine
				jne @@notFLDLG2
				printStr op_FLDLG2
				ret
				@@notFLDLG2:
				
				cmp byte ptr[dosByte], 0EDh
				jne @@notFLDLN2
				printStr op_FLDLN2
				ret
				@@notFLDLN2:
				
				cmp byte ptr[dosByte], 0EEh	;FPU transcendentine
				jne @@notFLDZ
				printStr op_FLDZ
				ret
				@@notFLDZ:
				
				call printUnknownReuseDos
			@@FARF0toFF:
				
				cmp byte ptr[dosByte], 0F0h	;FPU transcendentine
				jne @@notF2XM1
				printStr op_F2XM1
				ret
				@@notF2XM1:
				
				cmp byte ptr[dosByte], 0F1h	;FPU transcendentine
				jne @@notFYL2X
				printStr op_FYL2X
				ret
				@@notFYL2X:
				
				cmp byte ptr[dosByte], 0F2h	;FPU transcendentine
				jne @@notFPTAN
				printStr op_FPTAN
				ret
				@@notFPTAN:
				
				cmp byte ptr[dosByte], 0F3h	;FPU transcendentine
				jne @@notFPATAN
				printStr op_FPATAN
				ret
				@@notFPATAN:
				
				cmp byte ptr[dosByte], 0F4h
				jne @@notFXTRAC
				printStr op_FXTRAC
				ret
				@@notFXTRAC:
				
				cmp byte ptr[dosByte], 0F5h
				jne @@notFPREM1
				printStr op_FPREM1
				ret
				@@notFPREM1:
				
				cmp byte ptr[dosByte], 0F6h
				jne @@notFDECST
				printStr op_FDECST
				ret
				@@notFDECST:
				
				cmp byte ptr[dosByte], 0F7h
				jne @@notFINCST
				printStr op_FINCST
				ret
				@@notFINCST:
				
				cmp byte ptr[dosByte], 0F8h
				jne @@notFPREM
				printStr op_FPREM
				ret
				@@notFPREM:
				
				cmp byte ptr[dosByte], 0F9h	;FPU transcendentine
				jne @@notFYL2XP1
				printStr op_FYL2XP1
				ret
				@@notFYL2XP1:
				
				cmp byte ptr[dosByte], 0FAh
				jne @@notFSQRT
				printStr op_FSQRT
				ret
				@@notFSQRT:
				
				cmp byte ptr[dosByte], 0FBh
				jne @@notFSINCO
				printStr op_FSINCO
				ret
				@@notFSINCO:
				
				cmp byte ptr[dosByte], 0FCh
				jne @@notFRNDIN
				printStr op_FRNDIN
				ret
				@@notFRNDIN:
				
				cmp byte ptr[dosByte], 0FDh
				jne @@notFSCALE
				printStr op_FSCALE
				ret
				@@notFSCALE:
				
				cmp byte ptr[dosByte], 0FEh
				jne @@notFSIN
				printStr op_FSIN
				ret
				@@notFSIN:
				
				printStr op_FCOS
				ret
	endp
	decipherD9xxFPUExpansion proc
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FLD		;000
				mov byte ptr[WordOrBytePtr], '.'
				jmp @@fin
				@@OPKextra001:
				call printUnknownReuseDos	;001
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FST		;010
				mov byte ptr[WordOrBytePtr], '.'
				jmp @@fin
				@@OPKextra011:
				printStr op_FSTP	;011
				mov byte ptr[WordOrBytePtr], '.'
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FLDENV	;100
				mov byte ptr[WordOrBytePtr], 00h
				jmp @@fin
				@@OPKextra101:
				printStr op_FLDCW	;101
				mov byte ptr[WordOrBytePtr], 'W'
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FSTENV	;110
				mov byte ptr[WordOrBytePtr], 00h
				jmp @@fin
				@@OPKextra111:
				printStr op_FSTCW	;111
				mov byte ptr[WordOrBytePtr], 'W'
		@@fin:
		call printRM
		ret
	endp
	
	calcJMP proc
		printChar 09h
		push ax
		push bx
		push cx
		readByte dosByte
		mov bh, 00h
		mov bl, byte ptr[operationByteCount]
		mov cl, byte ptr[dosByte]
		cmp cl, 07Fh
		ja @@signed
		mov ch, 00h
		jmp @@fin
		@@signed:
		mov ch, 0FFh
		@@fin:
		mov ax, word ptr[currentIP]
		add ax, bx
		add ax, cx
		xchg ah, al
		call printHex
		xchg ah, al
		call printHex
		pop cx
		pop bx
		pop ax
		ret
	endp
	strManipBOrW proc
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@printW
		printChar 'B'
		ret
		@@printW:
		printChar 'W'
		ret
	endp
	segmentMov proc
		call readByteMakeBinaryDos
		
		mov byte ptr[WordOrBytePtr], 'W'
		
		cmp byte ptr[OPKByteBinary+6], 00h
		je @@toRM
			cmp word ptr[addressByteBinary+3], 0000h
			jne @@notToES
			printStr segRegES
			jmp @@printedToReg
			@@notToES:
			cmp word ptr[addressByteBinary+3], 0001h
			jne @@notToCS
			printStr segRegCS
			jmp @@printedToReg
			@@notToCS:
			cmp word ptr[addressByteBinary+3], 0100h
			jne @@notToSS
			printStr segRegSS
			jmp @@printedToReg
			@@notToSS:
			printStr segRegDS
			
			@@printedToReg:
			printChar ','
			call printRM
			ret
		@@toRM:
			call printRM
			printChar ','
			cmp word ptr[addressByteBinary+3], 0000h
			jne @@notES
			printStr segRegES
			ret
			@@notES:
			cmp word ptr[addressByteBinary+3], 0001h
			jne @@notCS
			printStr segRegCS
			ret
			@@notCS:
			cmp word ptr[addressByteBinary+3], 0100h
			jne @@notSS
			printStr segRegSS
			ret
			@@notSS:
			printStr segRegDS
			ret
	endp
	specialMOV proc
		printStr op_MOV
		cmp byte ptr[OPKByteBinary+6], 00h
		je @@fromMemory
		call printDirectAddress
		printChar ','
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@TMPrintAX
		printStr regAL
		jmp @@TMPrinted
		@@TMPrintAX:
		printStr regAX
		@@TMPrinted:
		ret
		@@fromMemory:
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@FMPrintAX
		printStr regAL
		jmp @@FMPrinted
		@@FMPrintAX:
		printStr regAX
		@@FMPrinted:
		printChar ','
		call printDirectAddress
		ret
	endp
	
	OPKByteWREG proc
		push bx
		
		mov bx, -0005h
		cmp byte ptr[OPKByteBinary+4], 01h
		je @@wordREG
			call printRegByte
			jmp @@fin
		@@wordREG:
			call printRegWord
		@@fin:
		printChar ','
		printChar ' '
		mov bx, -0004h
		printImmediate 'W'
		
		pop bx
		ret
	endp
	
	address proc
		push bx
		
		call readByteMakeBinaryDos
		
		mov bx, 0000h
		call printRegWord
		printChar ','
		mov byte ptr[WordOrBytePtr], 00h
		call printRM
		
		pop bx
		ret
	endp
	immToAccu proc
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@CMPAX
		printStr regAL
		jmp @@printedCMPt3reg
		@@CMPAX:
		printStr regAX
		@@printedCMPt3reg:
		printChar ','
		printChar ' '
		printImmediate 'w'
		ret
	endp
	addressVW proc
		push bx
		
		mov bx, 0000h
		mov byte ptr[WordOrBytePtr], 01h
		call printRM
		printChar ','
		cmp byte ptr[OPKByteBinary+6], 01h
		je @@byCL
		printChar ' '
		printChar '1'
		jmp @@fin
		@@byCL:
		printStr regCL
		
		@@fin:
		pop bx
		ret
	endp
	addressSW proc
		push ax
		
		mov byte ptr[WordOrBytePtr], 01h
		call printRM
		printChar ','
		printChar ' '
		
		cmp byte ptr[OPKByteBinary+7], 01h
		jne @@noExpand
			cmp byte ptr[OPKByteBinary+6], 00h
			jne @@expand
				printImmediate '2'
				jmp @@fin
			@@expand:
			readByte tresByte
			mov al, byte ptr[tresByte]
			cmp al, 080h
			jb @@possitiveExpand
			neg al
			printChar '-'
			jmp @@expanded
			@@possitiveExpand:
			printChar '+'
			@@expanded:
			call printHex
			jmp @@fin
		@@noExpand:
		printImmediate '1'
		
		@@fin:
		
		pop ax
		ret
	endp
	addressDW proc
		push bx
		
		call readByteMakeBinaryDos
		
		mov bx, 0000h
		mov byte ptr[WordOrBytePtr], 00h
		cmp byte ptr[OPKByteBinary+6], 01h
		je @@toREG
			call printRM
			printChar ','
			call printReg
			jmp @@fin
		@@toREG:
			call printReg
			printChar ','
			call printRM
		@@fin:
		pop bx
		ret
	endp
	
	printRM proc
		push bx
		cmp word ptr[addressByteBinary], 0101h
		jne @@notREG
			mov bx, 0003h
			call printReg
			jmp @@fin
		@@notREG:
		
		cmp byte ptr[WordOrBytePtr], 00h
		je @@printed
		cmp byte ptr[WordOrBytePtr], 01h
		jne @@notPrintAuto
			cmp byte ptr[OPKByteBinary+7], 01h
			je @@notAutoByte
				printStr eaBytePtr
				jmp @@printed
			@@notAutoByte:
			printStr eaWordPtr
			jmp @@printed
		@@notPrintAuto:
		cmp byte ptr[WordOrBytePtr], 'F'
		jne @@notPrintFAR
			printStr eaFAR
			jmp @@printed
		@@notPrintFAR:
		cmp byte ptr[WordOrBytePtr], 'B'
		jne @@notBOverride
			printStr eaBytePtr
			jmp @@printed
		@@notBOverride:
		cmp byte ptr[WordOrBytePtr], 'W'
		jne @@notWOverride
			printStr eaWordPtr
			jmp @@printed
		@@notWOverride:
		cmp byte ptr[WordOrBytePtr], '.'
		jne @@printed
			printStr eaFloatPtr
		@@printed:
		
		cmp byte ptr[redirectByte], 01h
		jne @@noRedirection
		mov byte ptr[redirectByte], 00h
		cmp byte ptr[redirectByte+1], 026h
		jne @@notRedirectToES
		printStr segRegES
		jmp @@redirected
		@@notRedirectToES:
		cmp byte ptr[redirectByte+1], 02Eh
		jne @@notRedirectToCS
		printStr segRegCS
		jmp @@redirected
		@@notRedirectToCS:
		cmp byte ptr[redirectByte+1], 036h
		jne @@notRedirectToSS
		printStr segRegSS
		jmp @@redirected
		@@notRedirectToSS:
		printStr segRegDS
		@@redirected:
		printChar ':'
		@@noRedirection:
		
		cmp word ptr[addressByteBinary], 0000h
		je @@mod00
			call printEAmod01or10
			jmp @@fin
		@@mod00:
			call printEAmod00
		@@fin:
		pop bx
		ret
	endp
	
	printEAmod01or10 proc
		cmp byte ptr[addressByteBinary+5], 01h
		je @@RM1xx
			cmp byte ptr[addressByteBinary+6], 01h
			je @@RM01x
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM001
				printStr eaBXSIplus	;000
				jmp @@fin
				@@RM001:
				printStr eaBXDIplus	;001
				jmp @@fin
			@@RM01x:
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM011
				printStr eaBPSIplus	;010
				jmp @@fin
				@@RM011:
				printStr eaBPDIplus	;011
				jmp @@fin
		@@RM1xx:
			cmp byte ptr[addressByteBinary+6], 01h
			je @@RM11x
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM101
				printStr eaSIplus	;100
				jmp @@fin
				@@RM101:
				printStr eaDIplus	;101
				jmp @@fin
			@@RM11x:
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM111
				printStr eaBPplus	;110
				jmp @@fin
				@@RM111:
				printStr eaBXplus	;111
				jmp @@fin
		@@fin:
		printImmediate 'm'
		printChar ']'
		ret
	endp
	
	printEAmod00 proc
		cmp byte ptr[addressByteBinary+5], 01h
		je @@RM1xx
			cmp byte ptr[addressByteBinary+6], 01h
			je @@RM01x
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM001
				printStr eaBXSI	;000
				jmp @@fin
				@@RM001:
				printStr eaBXDI	;001
				jmp @@fin
			@@RM01x:
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM011
				printStr eaBPSI	;010
				jmp @@fin
				@@RM011:
				printStr eaBPDI	;011
				jmp @@fin
		@@RM1xx:
			cmp byte ptr[addressByteBinary+6], 01h
			je @@RM11x
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM101
				printStr eaSI	;100
				jmp @@fin
				@@RM101:
				printStr eaDI	;101
				jmp @@fin
			@@RM11x:
				cmp byte ptr[addressByteBinary+7], 01h
				je @@RM111
				call printDirectAddress	;110
				jmp @@fin
				@@RM111:
				printStr eaBX	;111
				jmp @@fin
		@@fin:
		ret
	endp
	
	printDirectAddress proc
		printChar ' '
		printChar '['
		printImmediate '2'
		printChar ']'
		ret
	endp
	
	printReg proc									;BX=3, norint imt 'reg' is rm lauko; BX=0, jei imt is reg lauko
		cmp byte ptr[OPKByteBinary+7], 01h
		je @@wordREG
			call printRegByte
			jmp @@fin
		@@wordREG:
			call printRegWord
		@@fin:
		ret
	endp
	printRegByte proc
		cmp byte ptr[addressByteBinary+bx+2], 01h
		je @@REG1xx
			cmp byte ptr[addressByteBinary+bx+3], 01h
			je @@REG01x
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG001
				printStr regAL	;000
				jmp @@fin
				@@REG001:
				printStr regCL	;001
				jmp @@fin
			@@REG01x:
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG011
				printStr regDL	;010
				jmp @@fin
				@@REG011:
				printStr regBL	;011
				jmp @@fin
		@@REG1xx:
			cmp byte ptr[addressByteBinary+bx+3], 01h
			je @@REG11x
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG101
				printStr regAH	;100
				jmp @@fin
				@@REG101:
				printStr regCH	;101
				jmp @@fin
			@@REG11x:
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG111
				printStr regDH	;110
				jmp @@fin
				@@REG111:
				printStr regBH	;111
				jmp @@fin
		@@fin:
		ret
	endp
	printRegWord proc
		cmp byte ptr[addressByteBinary+bx+2], 01h
		je @@REG1xx
			cmp byte ptr[addressByteBinary+bx+3], 01h
			je @@REG01x
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG001
				printStr regAX	;000
				jmp @@fin
				@@REG001:
				printStr regCX	;001
				jmp @@fin
			@@REG01x:
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG011
				printStr regDX	;010
				jmp @@fin
				@@REG011:
				printStr regBX	;011
				jmp @@fin
		@@REG1xx:
			cmp byte ptr[addressByteBinary+bx+3], 01h
			je @@REG11x
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG101
				printStr regSP	;100
				jmp @@fin
				@@REG101:
				printStr regBP	;101
				jmp @@fin
			@@REG11x:
				cmp byte ptr[addressByteBinary+bx+4], 01h
				je @@REG111
				printStr regSI	;110
				jmp @@fin
				@@REG111:
				printStr regDI	;111
		@@fin:
		ret
	endp
	handleRedirect proc
		mov byte ptr[redirectByte], 00h
		lea si, printThis
		lea di, printThisCopy
		mov ch, 00h
		mov cl, byte ptr[printHowMany]
		mov byte ptr[printHowManyCopy], cl
		mov byte ptr[printHowMany], 00h
		rep movsb
		dec byte ptr[operationByteCount]
		mov cl, byte ptr[operationByteCount]
		lea si, operationBytes+1
		lea di, operationBytes
		rep movsb
		printChar ':'
		mov al, byte ptr[currentIP+1]
		call printHex
		mov al, byte ptr[currentIP]
		call printHex
		printChar ' '
		mov al, byte ptr[redirectByte+1]
		call printHex
		cmp al, 'E'
		jne @@notHangingES
		printStr segESUnused
		jmp @@hangingRedirect
		@@notHangingES:
		cmp al, 'C'
		jne @@notHangingCS
		printStr segCSUnused
		jmp @@hangingRedirect
		@@notHangingCS:
		cmp al, 'S'
		jne @@notHangingSS
		printStr segSSUnused
		jmp @@hangingRedirect
		@@notHangingSS:
		printStr segDSUnused
		@@hangingRedirect:
		printChar 0Ah
		lea si, printThisCopy
		lea di, printThis
		mov cl, byte ptr[printHowManyCopy]
		mov byte ptr[printHowMany], cl
		rep movsb
		ret
	endp
;__________________________________________________________________________________________________
main:
	mov ax, @data
	mov ds, ax
	
	cmp ES:byte ptr[80h], 00h
	jne noSyntaxError
	printStrNoWrite errorSyntax
	.exit
	noSyntaxError:
	mov ch, 00h
	mov cl, ES:byte ptr[80h]
	mov si, 0000h
	mov di, -00FFh
	mov bx, 0000h
	mov ah, 00h
	mov al, ES:byte ptr[80h]
	parseParameter:
	cmp ES:byte ptr[si+81h], ' '
	je thatIsASpace
	cmp ah, 01h
	jne charAfterSpace
	mov ah, 00h
	add di, 00FFh
	mov bx, 0000h
	charAfterSpace:
	mov al, ES:byte ptr[si+81h]
	mov byte ptr[programParameter1+bx+di], al
	inc bx
	jmp spaceAfterSpace
	thatIsASpace:
	cmp ah, 00h
	jne spaceAfterSpace
	mov ah, 01h
	cmp bx, 0000h
	je spaceAfterSpace
	mov byte ptr[programParameter1+bx+di], 0
	mov byte ptr[programParameter1+bx+di+1], '$'
	spaceAfterSpace:
	inc si
	loop parseParameter
	mov byte ptr[programParameter1+bx+di], 0
	mov byte ptr[programParameter1+bx+di+1], '$'
	
	mov ax, 03D00h
	lea dx, programParameter1
	int 21h
	jnc pavykoAtidarytFaila
	printStrNoWrite errorOpeningFile
	.exit
	pavykoAtidarytFaila:
	mov word ptr[filePtr], ax
	
	mov cx, 0000h
	mov ax, 03C00h
	lea dx, programParameter2
	int 21h
	jnc @@createSuccess
	printStrNoWrite errorCreatingOutputFile
	.exit
	@@createSuccess:
	mov ax, 03D01h
	lea dx, programParameter2
	int 21h
	jnc @@outFileOpened
	printStrNoWrite errorOpeningOutputFile
	.exit
	@@outFileOpened:
	mov word ptr[outFilePtr], ax
	
	push ds
	pop es
	cld
	
	byteByByte:
	mov ch, 00h
	mov cl, byte ptr[printHowMany]
	mov byte ptr[printHowMany], 00h
	mov al, 00h
	lea di, printThis
	repne stosb
	mov byte ptr[operationByteCount], 00h
	
	call decipher
	
	cmp byte ptr[redirectByte], 01h
	jne @@notHangingRedirect
	call handleRedirect
	@@notHangingRedirect:
	
	mov ah, 00h
	mov al, byte ptr[printHowMany]
	mov cx, ax
	lea si, printThis
	add si, ax
	mov di, si
	mov al, byte ptr[operationByteCount]
	add ax, ax
	add di, ax
	cmp byte ptr[operationByteCount], 02h
	ja lessTabs
	inc di
	lessTabs:
	sub cx, 09h
	std
	rep movsb
	cld
	mov ah, byte ptr[printHowMany]
	mov byte ptr[printHowMany], 0Ah
	mov ch, 00h
	mov cl, byte ptr[operationByteCount]
	mov bx, 0000h
	printAllHexes:
	mov al, byte ptr[operationBytes+bx]
	call printHex
	inc bx
	loop printAllHexes
	
	cmp byte ptr[operationByteCount], 02h
	ja noMoreTabs
	printChar 09h
	noMoreTabs:
	
	sub ah, 0Ah
	add byte ptr[printHowMany], ah
	
	mov cl, byte ptr[operationByteCount]
	add word ptr[currentIP], cx
	
	mov bh, 00h
	mov bl, byte ptr[printHowMany]
	mov byte ptr[printThis+bx+1], '$'
	printStrNoWrite printThis
	printCharNoWrite 0Ah
	
	printChar 0Ah
	
	lea dx, printThis
	mov cl, byte ptr[printHowMany]
	mov bx, word ptr[outFilePtr]
	mov ah, 040h
	int 21h
	jnc @@writeSuccess
	printStr errorWritingToOutputFile
	.exit
	@@writeSuccess:
	cmp byte ptr[reachedEOF], 01h
	je finished
	jmp byteByByte
	
	finished:
	
	mov bx, word ptr[filePtr]
	mov ah, 03Eh
	int 21h
	printStrNoWrite strReachedEOF
	
	mov ax, 04C00h
	int 21h
end main
