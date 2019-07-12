;
;		Edvinas Smita - VU MIF PS 1k. 2gr.
;

.model small
.stack 100h

;__________________________________________________________________________________________________
.data
	;								strings
	errorSyntax db 'Neteisingai ivesti parametrai.', 0Ah, 'Sintakse: *.exe ivestiesFailoPavadinimas isvestiesFailoPavadinimas', 0Ah, 024h
	errorOpeningInputFile db 'Nepavyko atidaryti nurodyto failo. Terminuojama.', 0Ah, 24h
	errorReadingFile db 'Nepavyksta NUSKAITYTI nurodyto failo. Terminuojama.', 0Ah, 24h
	errorCreatingOutputFile db 'Nepavyko sukurti rezultatu failo. Terminuojama.', 0Ah, 024h
	errorOpeningOutputFile db 'Nepavyko atidaryti rezultatu failo. Terminuojama.', 0Ah, 024h
	errorWriting db 'Nepavyko irasyt i rezultatu faila. Terminuojama.', 0Ah, 024h
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
	reuseByte db 00, ?, ?			;+0 ~ ar (ir kiek) pernaudot, +1,+2 ~ ka pernaudot
	redirectByte db 00, ?, ?		;+0 ~ ar (ir kiek) buvo nukreipta i kita seg., +1/2 ~ koks nukreipimas (26h, 2Eh, 36h, 3Eh, 64h)
	;								fileReading
	
	;								fileWriting
	currentIP dw 0100h
	operationByteCount db 00
	operationBytes db 10 dup(?)
	
	printHowMany db 080h
	prnThisCS db '0734:'
	prnThisIP db ?, ?, ?, ?, ' '
	printThis db 080h dup(?)
	printHowManyCopy db ?
	printThisCopy db 080h dup(?)
	;								fileWriting
	
	;								komandos
	op_MOV		db 20 dup(' '), 'MOV$'
	op_PUSH		db 20 dup(' '), 'PUSH$'
	op_POP		db 20 dup(' '), 'POP$'
	op_XCHG		db 20 dup(' '), 'XCHG$'
	op_IN		db 20 dup(' '), 'IN$'
	op_OUT		db 20 dup(' '), 'OUT$'
	op_XLAT		db 20 dup(' '), 'XLAT$'
	op_LEA		db 20 dup(' '), 'LEA$'
	op_LDS		db 20 dup(' '), 'LDS$'
	op_LES		db 20 dup(' '), 'LES$'
	op_LAHF		db 20 dup(' '), 'LAHF$'
	op_SAHF		db 20 dup(' '), 'SAHF$'
	op_PUSHF	db 20 dup(' '), 'PUSHF$'
	op_POPF		db 20 dup(' '), 'POPF$'
	
	op_ADD		db 20 dup(' '), 'ADD$'
	op_ADC		db 20 dup(' '), 'ADC$'
	op_INC		db 20 dup(' '), 'INC$'
	op_AAA		db 20 dup(' '), 'AAA$'
	op_BAA		db 20 dup(' '), 'BAA$'	;intel vadina BAA, debugas vadina DAA
	op_SUB		db 20 dup(' '), 'SUB$'
	op_SSB		db 20 dup(' '), 'SSB$'	;intel vadina SSB, debugas vadina SBB
	op_DEC		db 20 dup(' '), 'DEC$'
	op_NEG		db 20 dup(' '), 'NEG$'
	op_CMP		db 20 dup(' '), 'CMP$'
	op_AAS		db 20 dup(' '), 'AAS$'
	op_DAS		db 20 dup(' '), 'DAS$'
	op_MUL		db 20 dup(' '), 'MUL$'
	op_IMUL		db 20 dup(' '), 'IMUL$'
	op_AAM		db 20 dup(' '), 'AAM$'
	op_DIV		db 20 dup(' '), 'DIV$'
	op_IDIV		db 20 dup(' '), 'IDIV$'
	op_AAD		db 20 dup(' '), 'AAD$'
	op_CBW		db 20 dup(' '), 'CBW$'
	op_CWD		db 20 dup(' '), 'CWD$'
	
	op_NOT		db 20 dup(' '), 'NOT$'
	op_SHL		db 20 dup(' '), 'SHL$'
	op_SHR		db 20 dup(' '), 'SHR$'
	op_SAR		db 20 dup(' '), 'SAR$'
	op_ROL		db 20 dup(' '), 'ROL$'
	op_ROR		db 20 dup(' '), 'ROR$'
	op_RCL		db 20 dup(' '), 'RCL$'
	op_RCR		db 20 dup(' '), 'RCR$'
	op_AND		db 20 dup(' '), 'AND$'
	op_TEST		db 20 dup(' '), 'TEST$'
	op_OR		db 20 dup(' '), 'OR$'
	op_XOR		db 20 dup(' '), 'XOR$'
	op_REP		db 20 dup(' '), 'REP$'
	op_MOVS		db 20 dup(' '), 'MOVS$'
	op_CMPS		db 20 dup(' '), 'CMPS$'
	op_SCAS		db 20 dup(' '), 'SCAS$'
	op_LODS		db 20 dup(' '), 'LODS$'
	op_STOS		db 20 dup(' '), 'STOS$'
	op_CALL		db 20 dup(' '), 'CALL$'
	
	op_JMP		db 20 dup(' '), 'JMP$'
	op_RET		db 20 dup(' '), 'RET$'
		op_RETF		db 20 dup(' '), 'RETF$'
	op_JE		db 20 dup(' '), 'JE$'
	op_JL		db 20 dup(' '), 'JL$'
	op_JLE		db 20 dup(' '), 'JLE$'
	op_JB		db 20 dup(' '), 'JB$'
	op_JBE		db 20 dup(' '), 'JBE$'
	op_JP		db 20 dup(' '), 'JP$'
	op_JO		db 20 dup(' '), 'JO$'
	op_JS		db 20 dup(' '), 'JS$'
	op_JNE		db 20 dup(' '), 'JNE$'
	op_JNL		db 20 dup(' '), 'JNL$'
	op_JG		db 20 dup(' '), 'JG$'
	op_JNB		db 20 dup(' '), 'JNB$'
	op_JA		db 20 dup(' '), 'JA$'
	op_JNP		db 20 dup(' '), 'JNP$'
	op_JNO		db 20 dup(' '), 'JNO$'
	op_JNS		db 20 dup(' '), 'JNS$'
	op_LOOP		db 20 dup(' '), 'LOOP$'
	op_LOOPE	db 20 dup(' '), 'LOOPE$'
	op_LOOPNE	db 20 dup(' '), 'LOOPNE$'
	op_JCXZ		db 20 dup(' '), 'JCXZ$'
	op_INT		db 20 dup(' '), 'INT$'
	op_INTO		db 20 dup(' '), 'INTO$'
	op_IRET		db 20 dup(' '), 'IRET$'
	
	op_CLC		db 20 dup(' '), 'CLC$'
	op_CMC		db 20 dup(' '), 'CMC$'
	op_STC		db 20 dup(' '), 'STC$'
	op_CLD		db 20 dup(' '), 'CLD$'
	op_STD		db 20 dup(' '), 'STD$'
	op_CLI		db 20 dup(' '), 'CLI$'
	op_STI		db 20 dup(' '), 'STI$'
	op_HLT		db 20 dup(' '), 'HLT$'
	op_WAIT		db 20 dup(' '), 'WAIT$'
	op_ESC		db 20 dup(' '), 'ESC$'		;neegzituoja????
	op_LOCK		db 20 dup(' '), 'LOCK$'
	
	op_NOP		db 20 dup(' '), 'NOP$'
	op_UNUSED	db ' (unused)$'
	op_unknown	db 20 dup(' '), 'DB $'
	;								komandos
	
	;								visosFPUKomandos
	op_FADD		db 20 dup(' '), 'FADD$'		;~D8xx
	op_FMUL		db 20 dup(' '), 'FMUL$'
	op_FCOM		db 20 dup(' '), 'FCOM$'
	op_FCOMP	db 20 dup(' '), 'FCOMP$'
	op_FSUB		db 20 dup(' '), 'FSUB$'
	op_FSUBR	db 20 dup(' '), 'FSUBR$'
	op_FDIV		db 20 dup(' '), 'FDIV$'		;~D8xx
	op_FDIVR	db 20 dup(' '), 'FDIVR$'	;~D9xx
	op_FLD		db 20 dup(' '), 'FLD$'
	op_FST		db 20 dup(' '), 'FST$'
	op_FSTP		db 20 dup(' '), 'FSTP$'
	op_FLDENV	db 20 dup(' '), 'FLDENV$'
	op_FLDCW	db 20 dup(' '), 'FLDCW$'
	op_FSTENV	db 20 dup(' '), 'FSTENV$'
		op_FNSTENV	db 20 dup(' '), 'FNSTENV$'
	op_FSTCW	db 20 dup(' '), 'FSTCW$'
		op_FNSTCW	db 20 dup(' '), 'FNSTCW$'
	op_FXCH		db 20 dup(' '), 'FXCH$'
	op_FCHS		db 20 dup(' '), 'FCHS$'
	op_FABS		db 20 dup(' '), 'FABS$'
	op_FTST		db 20 dup(' '), 'FTST$'
	op_FXAM		db 20 dup(' '), 'FXAM$'
	op_FLD1		db 20 dup(' '), 'FLD1$'
	op_FLDL2T	db 20 dup(' '), 'FLDL2T$'
	op_FLDL2E	db 20 dup(' '), 'FLDL2E$'
	op_FLDPI	db 20 dup(' '), 'FLDPI$'
	op_FLDLG2	db 20 dup(' '), 'FLDLG2$'
	op_FLDLN2	db 20 dup(' '), 'FLDLN2$'
	op_FLDZ		db 20 dup(' '), 'FLDZ$'
	op_F2XM1	db 20 dup(' '), 'F2XM1$'
	op_FYL2X	db 20 dup(' '), 'FYL2X$'
	op_FPTAN	db 20 dup(' '), 'FPTAN$'
	op_FPATAN	db 20 dup(' '), 'FPATAN$'
	op_FXTRAC	db 20 dup(' '), 'FXTRAC$'
	op_FPREM1	db 20 dup(' '), 'FPREM1$'
	op_FDECST	db 20 dup(' '), 'FDECST$'
	op_FINCST	db 20 dup(' '), 'FINCST$'
	op_FPREM	db 20 dup(' '), 'FPREM$'
	op_FYL2XP1	db 20 dup(' '), 'FYL2XP1$'
	op_FSQRT	db 20 dup(' '), 'FSQRT$'
	op_FSINCO	db 20 dup(' '), 'FSINCO$'
	op_FRNDIN	db 20 dup(' '), 'FRNDIN$'
	op_FSCALE	db 20 dup(' '), 'FSCALE$'
	op_FSIN		db 20 dup(' '), 'FSIN$'
	op_FCOS		db 20 dup(' '), 'FCOS$'		;~D9xx
	op_FIADD	db 20 dup(' '), 'FIADD$'	;~DAxx
	op_FIMUL	db 20 dup(' '), 'FIMUL$'
	op_FICOM	db 20 dup(' '), 'FICOM$'
	op_FICOMP	db 20 dup(' '), 'FICOMP$'
	op_FISUB	db 20 dup(' '), 'FISUB$'
	op_FISUBR	db 20 dup(' '), 'FISUBR$'
	op_FIDIV	db 20 dup(' '), 'FIDIV$'
	op_FIDIVR	db 20 dup(' '), 'FIDIVR$'
	op_FCMOVB	db 20 dup(' '), 'FCMOVB$'
		op_FCMOVBE	db 20 dup(' '), 'FCMOVBE$'
	op_FCMOVE	db 20 dup(' '), 'FCMOVE$'
	op_FCMOVU	db 20 dup(' '), 'FCMOVU$'
	op_FUCOMP	db 20 dup(' '), 'FUCOMP$'
		op_FUCOMPP	db 20 dup(' '), 'FUCOMPP$'	;~DAxx
	op_FILD		db 20 dup(' '), 'FILD$'		;~DBxx
	op_FIST		db 20 dup(' '), 'FIST$'
	op_FISTP	db 20 dup(' '), 'FISTP$'
	op_FCMOVN	db 20 dup(' '), 'FCMOVN$'
		op_FCMOVNB	db 20 dup(' '), 'FCMOVNB$'
		op_FCMOVNE	db 20 dup(' '), 'FCMOVNE$'
		op_FCMOVNBE	db 20 dup(' '), 'FCMOVNBE$'
		op_FCMOVNU	db 20 dup(' '), 'FCMOVNU$'
	op_FENI		db 20 dup(' '), 'FENI$'
		op_FNENI	db 20 dup(' '), 'FNENI$'
	op_FDISI	db 20 dup(' '), 'FDISI$'
		op_FNDISI	db 20 dup(' '), 'FNDISI$'
	op_FCLEX	db 20 dup(' '), 'FCLEX$'
		op_FNCLEX	db 20 dup(' '), 'FNCLEX$'
	op_FINIT	db 20 dup(' '), 'FINIT$'
		op_FNINIT	db 20 dup(' '), 'FNINIT$'
	op_FSETPM	db 20 dup(' '), 'FSETPM$'
		op_FNSETPM	db 20 dup(' '), 'FNSETPM$'
	op_FCOMI	db 20 dup(' '), 'FCOMI$'		;~DBxx
	op_FRSTOR	db 20 dup(' '), 'FRSTOR$'	;~DDxx
	op_FSAVE	db 20 dup(' '), 'FSAVE$'
		op_FNSAVE	db 20 dup(' '), 'FNSAVE$'
	op_FSTSW	db 20 dup(' '), 'FSTSW$'
		op_FNSTSW	db 20 dup(' '), 'FNSTSW$'
	op_FFREE	db 20 dup(' '), 'FFREE$'	;~DDxx
	op_FADDP	db 20 dup(' '), 'FADDP$'	;~DExx
	op_FMULP	db 20 dup(' '), 'FMULP$'
	op_FCOMPP	db 20 dup(' '), 'FCOMPP$'
	op_FSUBRP	db 20 dup(' '), 'FSUBRP$'
	op_FSUBP	db 20 dup(' '), 'FSUBP$'
	op_FDIVRP	db 20 dup(' '), 'FDIVRP$'
	op_FDIVP	db 20 dup(' '), 'FDIVP$'	;~DExx
	op_FBLD		db 20 dup(' '), 'FBLD$'		;~DFxx
	op_FBSTP	db 20 dup(' '), 'FBSTP$'
	op_FFREEP	db 20 dup(' '), 'FFREEP$'
	op_FCOMIP	db 20 dup(' '), 'FCOMIP$'	;~DFxx
	
	op_FNOP		db 20 dup(' '), 'FNOP$'
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
	
	segRegFS db ' FS$'
	
	segESUnused db 18 dup(' '), 'SEG ES (unused)$'
	segCSUnused db 18 dup(' '), 'SEG CS (unused)$'
	segSSUnused db 18 dup(' '), 'SEG SS (unused)$'
	segDSUnused db 18 dup(' '), 'SEG DS (unused)$'
	
	segFSUnused db 18 dup(' '), 'SEG FS (unused)$'
	;								registrai
	
	;								EA calc
	WordOrBytePtr db ?			;auto, kai byte ptr[WordOrBytePtr] == 01; neraso, kai == 00
	eaFAR db ' FAR$'			;kai byte ptr[WordOrBytePtr] == 'F'
	
	eaWordPtr db ' WORD PTR$'		;kai byte ptr[WordOrBytePtr] == 'W'
	eaBytePtr db ' BYTE PTR$'		;kai byte ptr[WordOrBytePtr] == 'B'
	
	eaFloatPtr db ' FLOAT PTR$'		;kai byte ptr[WordOrBytePtr] == '.'
	eaDWordPtr db ' DWORD PTR$'		;kai byte ptr[WordOrBytePtr] == 'D'
	eaTBytePtr db ' TBYTE PTR$'		;kai byte ptr[WordOrBytePtr] == 'T'
	eaQWordPtr db ' QWORD PTR$'		;kai byte ptr[WordOrBytePtr] == 'Q'
	
	eaBXSI db ' [BX+SI]$'
	eaBXDI db ' [BX+DI]$'
	eaBPSI db ' [BP+SI]$'
	eaBPDI db ' [BP+DI]$'
	eaSI db ' [SI]$'
	eaDI db ' [DI]$'
	eaBX db ' [BX]$'
	
	eaBXSIplus db ' [BX+SI$'
	eaBXDIplus db ' [BX+DI$'
	eaBPSIplus db ' [BP+SI$'
	eaBPDIplus db ' [BP+DI$'
	eaSIplus db ' [SI$'
	eaDIplus db ' [DI$'
	eaBPplus db ' [BP$'
	eaBXplus db ' [BX$'
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
			jne @@modImm1
			printChar '+'
			jmp @@print2
			@@modImm1:
			cmp byte ptr[tresByte], 080h
			jb @@plusOneByte
			printChar '-'
			jmp @@print1
			@@plusOneByte:
			printChar '+'
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
		
		cmp byte ptr[reuseByte], 00h
		je @@noReuse
		dec byte ptr[reuseByte]
		inc byte ptr[operationByteCount]
		mov al, byte ptr[reuseByte+1]
		mov byte ptr[si], al
		mov byte ptr[operationBytes], al
		mov al, byte ptr[reuseByte+2]
		mov byte ptr[reuseByte+1], al
		jmp @@reused
		@@noReuse:
		
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
		
		@@reused:
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
	updateCSIP proc
		push ax
		push bx
		mov bl, 010h
		
		mov ah, 00h
		mov al, byte ptr[currentIP+1]
		div bl
		cmp al, 0Ah
		jb @@numberALIP1
		add al, 037h
		jmp @@asciidALIP1
		@@numberALIP1:
		add al, '0'
		@@asciidALIP1:
		cmp ah, 0Ah
		jb @@numberAHIP1
		add ah, 037h
		jmp @@asciidAHIP1
		@@numberAHIP1:
		add ah, '0'
		@@asciidAHIP1:
		mov byte ptr[prnThisIP], al
		mov byte ptr[prnThisIP+1], ah
		
		mov ah, 00h
		mov al, byte ptr[currentIP]
		div bl
		cmp al, 0Ah
		jb @@numberALIP0
		add al, 037h
		jmp @@asciidALIP0
		@@numberALIP0:
		add al, '0'
		@@asciidALIP0:
		cmp ah, 0Ah
		jb @@numberAHIP0
		add ah, 037h
		jmp @@asciidAHIP0
		@@numberAHIP0:
		add ah, '0'
		@@asciidAHIP0:
		mov byte ptr[prnThisIP+2], al
		mov byte ptr[prnThisIP+3], ah
		
		pop bx
		pop ax
		ret
	endp
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	decipher proc
		push ax
		push bx
		
		@@reDecipher:
		call updateCSIP
		call readByteMakeBinaryUno
		
		xor bx, bx
		mov bl, byte ptr[redirectByte]
		cmp byte ptr[unoByte], 026h
		jne @@notRedirectToES
		mov byte ptr[redirectByte+bx+1], 026h
		jmp @@redirection
		@@notRedirectToES:
		cmp byte ptr[unoByte], 02Eh
		jne @@notRedirectToCS
		mov byte ptr[redirectByte+bx+1], 02Eh
		jmp @@redirection
		@@notRedirectToCS:
		cmp byte ptr[unoByte], 036h
		jne @@notRedirectToSS
		mov byte ptr[redirectByte+bx+1], 026h
		jmp @@redirection
		@@notRedirectToSS:
		cmp byte ptr[unoByte], 03Eh
		jne @@notRedirectToDS
		mov byte ptr[redirectByte+bx+1], 03Eh
		jmp @@redirection
		@@notRedirectToDS:
		cmp byte ptr[unoByte], 064h
		jne @@notRedirectToFS
		mov byte ptr[redirectByte+bx+1], 064h
		jmp @@redirection
		@@notRedirectToFS:
		
		jmp @@notRedirection
		@@redirection:
		cmp bl, 01h
		jne @@notStackedRedirect
		call handleRedirect
		@@notStackedRedirect:
		inc byte ptr[redirectByte]
		jmp @@reDecipher
		@@notRedirection:
		
		pop bx
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
					cmp word ptr[OPKByteBinary+3], 0000h
					jne @@notES
					printStr segRegES
					ret
					@@notES:
					cmp word ptr[OPKByteBinary+3], 0001h
					jne @@notCS
					printStr segRegCS
					ret
					@@notCS:
					cmp word ptr[OPKByteBinary+3], 0100h
					jne @@notSS
					printStr segRegSS
					ret
					@@notSS:
					printStr segRegDS
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
					call checkIfFWAIT
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
					
					cmp byte ptr[unoByte], 0D4h
					jne @@notAAM
					printStr op_AAM
					printChar ' '
					printImmediate '1'
					ret
					@@notAAM:
					
					cmp byte ptr[unoByte], 0D5h
					jne @@notAAD
					printStr op_AAD
					printChar ' '
					printImmediate '1'
					ret
					@@notAAD:
					
					cmp byte ptr[unoByte], 0D7h
					jne @@notXLAT
					printStr op_XLAT
					ret
					@@notXLAT:
					
					cmp byte ptr[unoByte], 0D8h
					jb @@notD8toDF
					cmp byte ptr[unoByte], 0DFh
					ja @@notD8toDF
					call decipherD8toDF
					ret
					@@notD8toDF:
					
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
	decipherD8toDF proc
		cmp byte ptr[unoByte], 0DCh
		jb @@D8toDB
		jmp @@DCtoDF
		@@D8toDB:
			cmp byte ptr[unoByte], 0DAh
			jb @@D8toD9
			jmp @@DAtoDB
			@@D8toD9:
				cmp byte ptr[unoByte], 0D8h
				jne @@notD8xxFPU
				call decipherD8
				ret
				@@notD8xxFPU:
				
				call decipherD9
				ret
			@@DAtoDB:
				cmp byte ptr[unoByte], 0DAh
				jne @@notDAxxFPU
				call decipherDA
				ret
				@@notDAxxFPU:
				
				call decipherDB
				ret
		@@DCtoDF:
			cmp byte ptr[unoByte], 0DEh
			jb @@DCtoDD
			jmp @@DEtoDF
			@@DCtoDD:
				cmp byte ptr[unoByte], 0DCh
				jne @@notDCxxFPU
				call decipherDC
				ret
				@@notDCxxFPU:
				
				call decipherDD
				ret
			@@DEtoDF:
				cmp byte ptr[unoByte], 0DEh
				jne @@notDExxFPU
				call decipherDE
				ret
				@@notDExxFPU:
				
				call decipherDF
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
;FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU
	checkIfFWAIT proc
		readByte unoByte
		cmp byte ptr[unoByte], 0D9h
		jne @@notFWAITD9
			call readByteMakeBinaryDos
			mov al, byte ptr[dosByte]
			and al, 038h
			cmp al, 038h
			je @@notD9extra7
			printStr op_FSTCW
			mov byte ptr[WordOrBytePtr], 'W'
			jmp @@finRM
			@@notD9extra7:
			cmp al, 030h
			je @@notD9extra6
			printStr op_FSTENV
			mov byte ptr[WordOrBytePtr], 00h
			jmp @@finRM
			@@notD9extra6:
			
			mov al, byte ptr[dosByte]
			mov byte ptr[reuseByte+2], al
			inc byte ptr[reuseByte]
			dec byte ptr[operationByteCount]
			jmp @@fin
		@@notFWAITD9:
		cmp byte ptr[unoByte], 0DBh
		jne @@notFWAITDB
			readByte dosByte
			
			cmp byte ptr[dosByte], 0E0h
			jne @@notDBE0
			printStr op_FENI
			jmp @@fin
			@@notDBE0:
			
			cmp byte ptr[dosByte], 0E1h
			jne @@notDBE1
			printStr op_FDISI
			jmp @@fin
			@@notDBE1:
			
			cmp byte ptr[dosByte], 0E2h
			jne @@notDBE2
			printStr op_FCLEX
			jmp @@fin
			@@notDBE2:
			
			cmp byte ptr[dosByte], 0E3h
			jne @@notDBE3
			printStr op_FINIT
			jmp @@fin
			@@notDBE3:
			
			cmp byte ptr[dosByte], 0E4h
			jne @@notDBE4
			printStr op_FSETPM
			jmp @@fin
			@@notDBE4:
			
			mov al, byte ptr[dosByte]
			mov byte ptr[reuseByte+2], al
			inc byte ptr[reuseByte]
			dec byte ptr[operationByteCount]
			jmp @@fin
		@@notFWAITDB:
		cmp byte ptr[unoByte], 0DDh
		jne @@notFWAITDD
			call readByteMakeBinaryDos
			mov al, byte ptr[dosByte]
			and al, 038h
			cmp al, 038h
			je @@notDDextra7
			printStr op_FSTSW
			mov byte ptr[WordOrBytePtr], 'W'
			jmp @@finRM
			@@notDDextra7:
			cmp al, 030h
			je @@notDDextra6
			printStr op_FSAVE
			mov byte ptr[WordOrBytePtr], 00h
			jmp @@finRM
			@@notDDextra6:
			
			mov al, byte ptr[dosByte]
			mov byte ptr[reuseByte+2], al
			inc byte ptr[reuseByte]
			dec byte ptr[operationByteCount]
			jmp @@fin
		@@notFWAITDD:
		cmp byte ptr[unoByte], 0DFh
		jne @@notFWAITDF
			readByte dosByte
			cmp byte ptr[dosByte], 0E0h
			jne @@notDFE0
			printStr op_FSTSW
			printStr regAX
			jmp @@fin
			@@notDFE0:
			
			mov al, byte ptr[dosByte]
			mov byte ptr[reuseByte+2], al
			inc byte ptr[reuseByte]
			dec byte ptr[operationByteCount]
			jmp @@fin
		@@notFWAITDF:
		
		mov al, byte ptr[unoByte]
		mov byte ptr[reuseByte+1], al
		inc byte ptr[reuseByte]
		dec byte ptr[operationByteCount]
		printStr op_WAIT
		printStr op_UNUSED
		jmp @@fin
		
		@@finRM:
		call printRM
		@@fin:
		pop ax
		ret
	endp
	decipherD8 proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherD8xxFPUExpansion
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
				jb @@notFADDmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFADDmod11
				printStr op_FADD
				jmp @@partTwoFADD
				@@notFADDmod11:
				
				printStr op_FMUL
				@@partTwoFADD:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
			@@FARD0toDF:
				cmp byte ptr[dosByte], 0D0h
				jb @@notFCOMmod11
				cmp byte ptr[dosByte], 0D7h
				ja @@notFCOMmod11
				printStr op_FCOM
				call printFPUSTi
				ret
				@@notFCOMmod11:
				
				printStr op_FCOMP
				call printFPUSTi
				ret
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				cmp byte ptr[dosByte], 0E0h
				jb @@notFSUBmod11
				cmp byte ptr[dosByte], 0E7h
				ja @@notFSUBmod11
				printStr op_FSUB
				jmp @@partTwoFSUB
				@@notFSUBmod11:
				
				printStr op_FSUBR
				@@partTwoFSUB:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
			@@FARF0toFF:
				cmp byte ptr[dosByte], 0F0h
				jb @@notFDIVmod11
				cmp byte ptr[dosByte], 0F7h
				ja @@notFDIVmod11
				printStr op_FDIV
				jmp @@partTwoFDIV
				@@notFDIVmod11:
				
				printStr op_FDIVR
				@@partTwoFDIV:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
	endp
	decipherD8xxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], '.'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FADD		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_FMUL		;001
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FCOM		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FCOMP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FSUB		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_FSUBR		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FDIV		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_FDIVR		;111
		@@fin:
		call printRM
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
				call printFPUSTi
				ret
				@@notFLDmod11:
				
				printStr op_FXCH
				call printFPUSTi
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
				
				cmp byte ptr[dosByte], 0E8h	;klasifikuota kaip transcendentine
				jne @@notFLD1
				printStr op_FLD1
				ret
				@@notFLD1:
				
				cmp byte ptr[dosByte], 0E9h	;klasifikuota kaip transcendentine
				jne @@notFLDL2T
				printStr op_FLDL2T
				ret
				@@notFLDL2T:
				
				cmp byte ptr[dosByte], 0EAh	;klasifikuota kaip transcendentine
				jne @@notFLDL2E
				printStr op_FLDL2E
				ret
				@@notFLDL2E:
				
				cmp byte ptr[dosByte], 0EBh	;klasifikuota kaip transcendentine
				jne @@notFLDPI
				printStr op_FLDPI
				ret
				@@notFLDPI:
				
				cmp byte ptr[dosByte], 0ECh	;klasifikuota kaip transcendentine		;<<<<<<<<<<<<
				jne @@notFLDLG2
				printStr op_FLDLG2
				ret
				@@notFLDLG2:
				
				cmp byte ptr[dosByte], 0EDh
				jne @@notFLDLN2
				printStr op_FLDLN2
				ret
				@@notFLDLN2:
				
				cmp byte ptr[dosByte], 0EEh	;klasifikuota kaip transcendentine
				jne @@notFLDZ
				printStr op_FLDZ
				ret
				@@notFLDZ:
				
				call printUnknownReuseDos
			@@FARF0toFF:
				
				cmp byte ptr[dosByte], 0F0h	;klasifikuota kaip transcendentine		;<<<<<<<<<<<<
				jne @@notF2XM1
				printStr op_F2XM1
				ret
				@@notF2XM1:
				
				cmp byte ptr[dosByte], 0F1h	;klasifikuota kaip transcendentine
				jne @@notFYL2X
				printStr op_FYL2X
				ret
				@@notFYL2X:
				
				cmp byte ptr[dosByte], 0F2h	;klasifikuota kaip transcendentine
				jne @@notFPTAN
				printStr op_FPTAN
				ret
				@@notFPTAN:
				
				cmp byte ptr[dosByte], 0F3h	;klasifikuota kaip transcendentine
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
				
				cmp byte ptr[dosByte], 0F9h	;klasifikuota kaip transcendentine
				jne @@notFYL2XP1
				printStr op_FYL2XP1
				ret
				@@notFYL2XP1:
				
				cmp byte ptr[dosByte], 0FAh		;<<<<<<<<<<<<
				jne @@notFSQRT
				printStr op_FSQRT
				ret
				@@notFSQRT:
				
				cmp byte ptr[dosByte], 0FBh		;<<<<<<<<<<<<
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
				printStr op_FNSTENV	;110		;itsatrap
				mov byte ptr[WordOrBytePtr], 00h
				jmp @@fin
				@@OPKextra111:
				printStr op_FNSTCW	;111		;itsatrap
				mov byte ptr[WordOrBytePtr], 'W'
		@@fin:
		call printRM
		ret
	endp
	
	decipherDA proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDAxxFPUExpansion
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
				jb @@notFCMOVBmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFCMOVBmod11
				printStr op_FCMOVB
				jmp @@partTwoFCMOVB
				@@notFCMOVBmod11:
				
				printStr op_FCMOVE
				@@partTwoFCMOVB:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
			@@FARD0toDF:
				cmp byte ptr[dosByte], 0D0h
				jb @@notFCMOVBEmod11
				cmp byte ptr[dosByte], 0D7h
				ja @@notFCMOVBEmod11
				printStr op_FCMOVBE
				jmp @@partTwoFCMOVBE
				@@notFCMOVBEmod11:
				
				printStr op_FCMOVU
				@@partTwoFCMOVBE:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0E9h
			jne @@notFUCOMPP
			printStr op_FUCOMPP
			ret
			@@notFUCOMPP:
		
		call printUnknownReuseDos
	endp
	decipherDAxxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], '.'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FIADD		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_FIMUL		;001
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FICOM		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FICOMP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FISUB		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_FISUBR		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FIDIV		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_FIDIVR		;111
		@@fin:
		call printRM
		ret
	endp
	
	decipherDB proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDBxxFPUExpansion
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
				jb @@notFCMOVNBmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFCMOVNBmod11
				printStr op_FCMOVNB
				jmp @@partTwoFCMOVNB
				@@notFCMOVNBmod11:
				
				printStr op_FCMOVNE
				@@partTwoFCMOVNB:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
			@@FARD0toDF:
				cmp byte ptr[dosByte], 0D0h
				jb @@notFCMOVNBEmod11
				cmp byte ptr[dosByte], 0D7h
				ja @@notFCMOVNBEmod11
				printStr op_FCMOVNBE
				jmp @@partTwoFCMOVNBE
				@@notFCMOVNBEmod11:
				
				printStr op_FCMOVNU
				@@partTwoFCMOVNBE:
				printStr FPU_ST
				printChar ','
				call printFPUSTi
				ret
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
		
				cmp byte ptr[dosByte], 0E0h
				jne @@notFNENI
				printStr op_FNENI
				ret
				@@notFNENI:
		
				cmp byte ptr[dosByte], 0E1h
				jne @@notFNDISI
				printStr op_FNDISI
				ret
				@@notFNDISI:
		
				cmp byte ptr[dosByte], 0E2h
				jne @@notFNCLEX
				printStr op_FNCLEX
				ret
				@@notFNCLEX:
		
				cmp byte ptr[dosByte], 0E3h
				jne @@notFNINIT
				printStr op_FNINIT
				ret
				@@notFNINIT:
		
				cmp byte ptr[dosByte], 0E4h
				jne @@notFNSETPM
				printStr op_FNSETPM
				ret
				@@notFNSETPM:
				
				call printUnknownReuseDos
			@@FARF0toFF:
				cmp byte ptr[dosByte], 0F0h
				jb @@notFCOMImod11
				cmp byte ptr[dosByte], 0F7h
				ja @@notFCOMImod11
				printStr op_FCOMI
				call printFPUSTi
				ret
				@@notFCOMImod11:
				
				call printUnknownReuseDos
		ret
	endp
	decipherDBxxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], '.'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FILD		;000
				jmp @@fin
				@@OPKextra001:
				call printUnknownReuseDos	;001
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FIST		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FISTP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				call printUnknownReuseDos	;100
				@@OPKextra101:
				printStr op_FLD			;101
				mov byte ptr[WordOrBytePtr], 'T'
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				call printUnknownReuseDos	;110
				@@OPKextra111:
				printStr op_FSTP		;111
				mov byte ptr[WordOrBytePtr], 'T'
		@@fin:
		call printRM
		ret
	endp
	
	decipherDC proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDCxxFPUExpansion
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
				jb @@notFADDmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFADDmod11
				printStr op_FADD
				jmp @@partTwoFADD
				@@notFADDmod11:
				
				printStr op_FMUL
				@@partTwoFADD:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
			@@FARD0toDF:
				
				call printUnknownReuseDos
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				cmp byte ptr[dosByte], 0E0h
				jb @@notFSUBRmod11
				cmp byte ptr[dosByte], 0E7h
				ja @@notFSUBRmod11
				printStr op_FSUBR
				jmp @@partTwoFSUBR
				@@notFSUBRmod11:
				
				printStr op_FSUB
				@@partTwoFSUBR:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
			@@FARF0toFF:
				cmp byte ptr[dosByte], 0F0h
				jb @@notFDIVRmod11
				cmp byte ptr[dosByte], 0F7h
				ja @@notFDIVRmod11
				printStr op_FDIVR
				jmp @@partTwoFDIVR
				@@notFDIVRmod11:
				
				printStr op_FDIV
				@@partTwoFDIVR:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
		ret
	endp
	decipherDCxxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], 'D'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FADD		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_FMUL		;001
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FCOM		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FCOMP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FSUB		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_FSUBR		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FDIV		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_FDIVR		;111
		@@fin:
		call printRM
		ret
	endp
	
	decipherDD proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDDxxFPUExpansion
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
				jb @@notFFREEmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFFREEmod11
				printStr op_FFREE
				call printFPUSTi
				ret
				@@notFFREEmod11:
				
				call printUnknownReuseDos
			@@FARD0toDF:
				cmp byte ptr[dosByte], 0D0h
				jb @@notFSTmod11
				cmp byte ptr[dosByte], 0D7h
				ja @@notFSTmod11
				printStr op_FST
				call printFPUSTi
				ret
				@@notFSTmod11:
				
				printStr op_FSTP
				call printFPUSTi
				ret
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				cmp byte ptr[dosByte], 0E0h
				jb @@notFCOMmod11
				cmp byte ptr[dosByte], 0E7h
				ja @@notFCOMmod11
				printStr op_FCOM
				call printFPUSTi
				ret
				@@notFCOMmod11:
				
				printStr op_FCOMP
				call printFPUSTi
				ret
			@@FARF0toFF:
				
				call printUnknownReuseDos
		ret
	endp
	decipherDDxxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], 'D'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FLD		;000
				jmp @@fin
				@@OPKextra001:
				call printUnknownReuseDos		;001
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FST		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FSTP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FRSTOR		;100
				jmp @@fin
				@@OPKextra101:
				call printUnknownReuseDos		;101
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FNSAVE		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_FNSTSW		;111
		@@fin:
		call printRM
		ret
	endp
	
	decipherDE proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDExxFPUExpansion
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
				jb @@notFADDPmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFADDPmod11
				printStr op_FADDP
				jmp @@partTwoFADDP
				@@notFADDPmod11:
				
				printStr op_FMULP
				@@partTwoFADDP:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
			@@FARD0toDF:
				cmp byte ptr[dosByte], 0D0h	;pagal debug nera
				jb @@notFUCOMPmod11
				cmp byte ptr[dosByte], 0D7h
				ja @@notFUCOMPmod11
				printStr op_FUCOMP
				call printFPUSTi
				ret
				@@notFUCOMPmod11:
				
				cmp byte ptr[dosByte], 0D9h
				jne @@notFCOMPP
				printStr op_FCOMPP
				ret
				@@notFCOMPP:
				
				call printUnknownReuseDos
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				cmp byte ptr[dosByte], 0E0h
				jb @@notFSUBRPmod11
				cmp byte ptr[dosByte], 0E7h
				ja @@notFSUBRPmod11
				printStr op_FSUBRP
				jmp @@partTwoFSUBRP
				@@notFSUBRPmod11:
				
				printStr op_FSUBP
				@@partTwoFSUBRP:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
			@@FARF0toFF:
				cmp byte ptr[dosByte], 0F0h
				jb @@notFDIVRPmod11
				cmp byte ptr[dosByte], 0F7h
				ja @@notFDIVRPmod11
				printStr op_FDIVRP
				jmp @@partTwoFDIVRP
				@@notFDIVRPmod11:
				
				printStr op_FDIVP
				@@partTwoFDIVRP:
				call printFPUSTi
				printChar ','
				printStr FPU_ST
				ret
		ret
	endp
	decipherDExxFPUExpansion proc
		mov byte ptr[WordOrBytePtr], 'W'
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FIADD		;000
				jmp @@fin
				@@OPKextra001:
				printStr op_FIMUL		;001
				jmp @@fin
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FICOM		;010
				jmp @@fin
				@@OPKextra011:
				printStr op_FICOMP		;011
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FISUB		;100
				jmp @@fin
				@@OPKextra101:
				printStr op_FISUBR		;101
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FIDIV		;110
				jmp @@fin
				@@OPKextra111:
				printStr op_FIDIVR		;111
		@@fin:
		call printRM
		ret
	endp
	
	decipherDF proc
		call readByteMakeBinaryDos
		
		cmp word ptr[addressByteBinary], 0101h
		je @@notExpandedOPK
		call decipherDFxxFPUExpansion
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
				jb @@notFFREEPmod11
				cmp byte ptr[dosByte], 0C7h
				ja @@notFFREEPmod11
				printStr op_FFREEP
				call printFPUSTi
				ret
				@@notFFREEPmod11:
				
				call printUnknownReuseDos
			@@FARD0toDF:
				
				call printUnknownReuseDos
		@@FARE0toFF:
			cmp byte ptr[dosByte], 0F0h
			jb @@E0toEF
			jmp @@FARF0toFF
			@@E0toEF:
				cmp byte ptr[dosByte], 0E0h
				jne @@notFNSTSW
				printStr op_FNSTSW
				printStr regAX
				ret
				@@notFNSTSW:
				
				call printUnknownReuseDos
			@@FARF0toFF:
				cmp byte ptr[dosByte], 0F0h
				jb @@notFCOMIPmod11
				cmp byte ptr[dosByte], 0F7h
				ja @@notFCOMIPmod11
				printStr op_FCOMIP
				call printFPUSTi
				ret
				@@notFCOMIPmod11:
				
				call printUnknownReuseDos
		ret
	endp
	decipherDFxxFPUExpansion proc
		cmp byte ptr[addressByteBinary+2], 01h
		je @@OPKextra1xx
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra01x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra001
				printStr op_FILD		;000
				mov byte ptr[WordOrBytePtr], 'W'
				jmp @@fin
				@@OPKextra001:
				call printUnknownReuseDos		;001
			@@OPKextra01x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra011
				printStr op_FIST		;010
				mov byte ptr[WordOrBytePtr], 'W'
				jmp @@fin
				@@OPKextra011:
				printStr op_FISTP		;011
				mov byte ptr[WordOrBytePtr], 'W'
				jmp @@fin
		@@OPKextra1xx:
			cmp byte ptr[addressByteBinary+3], 01h
			je @@OPKextra11x
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra101
				printStr op_FBLD		;100
				mov byte ptr[WordOrBytePtr], 'T'
				jmp @@fin
				@@OPKextra101:
				printStr op_FILD		;101
				mov byte ptr[WordOrBytePtr], 'Q'
				jmp @@fin
			@@OPKextra11x:
				cmp byte ptr[addressByteBinary+4], 01h
				je @@OPKextra111
				printStr op_FBSTP		;110
				mov byte ptr[WordOrBytePtr], 'T'
				jmp @@fin
				@@OPKextra111:
				printStr op_FISTP		;111
				mov byte ptr[WordOrBytePtr], 'Q'
		@@fin:
		call printRM
		ret
	endp
	
	printFPUSTi proc
		push ax
		printStr FPU_ST
		printChar '('
		mov al, byte ptr[dosByte]
		and al, 07h
		add al, 030h
		printChar al
		printChar ')'
		pop ax
		ret
	endp
;FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU_FPU
	
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
		jne @@print
		jmp @@printed
		@@print:
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
		jne @@notDotOverride
			printStr eaFloatPtr
			jmp @@printed
		@@notDotOverride:
		cmp byte ptr[WordOrBytePtr], 'D'
		jne @@notDOverride
			printStr eaDWordPtr
			jmp @@printed
		@@notDOverride:
		cmp byte ptr[WordOrBytePtr], 'T'
		jne @@notTOverride
			printStr eaTBytePtr
			jmp @@printed
		@@notTOverride:
		cmp byte ptr[WordOrBytePtr], 'Q'
		jne @@printed
			printStr eaQWordPtr
		@@printed:
		
		cmp byte ptr[redirectByte], 00h
		je @@noRedirection
		dec byte ptr[redirectByte]
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
		cmp byte ptr[redirectByte+1], 03Eh
		jne @@notRedirectToDS
		printStr segRegDS
		jmp @@redirected
		@@notRedirectToDS:
		cmp byte ptr[redirectByte+1], 064h
		jne @@notRedirectToFS
		printStr segRegFS
		jmp @@redirected
		@@notRedirectToFS:
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
		dec byte ptr[redirectByte]
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
		
		mov al, byte ptr[redirectByte+1]
		call printHex
		cmp al, 026h
		jne @@notHangingES
		printStr segESUnused
		jmp @@hangingRedirect
		@@notHangingES:
		cmp al, 02Eh
		jne @@notHangingCS
		printStr segCSUnused
		jmp @@hangingRedirect
		@@notHangingCS:
		cmp al, 036h
		jne @@notHangingSS
		printStr segSSUnused
		jmp @@hangingRedirect
		@@notHangingSS:
		cmp al, 03Eh
		jne @@notHangingDS
		printStr segDSUnused
		jmp @@hangingRedirect
		@@notHangingDS:
		cmp al, 064h
		jne @@notHangingFS
		printStr segFSUnused
		jmp @@hangingRedirect
		@@notHangingFS:
		@@hangingRedirect:
		printChar 0Ah
		
		lea dx, prnThisCS
		mov cl, byte ptr[printHowMany]
		add cl, 0Ah
		mov bx, word ptr[outFilePtr]
		mov ah, 040h
		int 21h
		jnc @@writeSuccess
		printStr errorWriting
		.exit
		@@writeSuccess:
		
		mov bh, 00h
		mov bl, byte ptr[printHowMany]
		mov byte ptr[prnThisCS+bx+9], '$'
		printStrNoWrite prnThisCS
		printCharNoWrite 0Ah
		
		lea si, printThisCopy
		lea di, printThis
		mov cl, byte ptr[printHowManyCopy]
		mov byte ptr[printHowMany], cl
		rep movsb
		
		cmp byte ptr[redirectByte], 01h
		jne @@fin
		mov al, byte ptr[redirectByte+2]
		mov byte ptr[redirectByte], al
		@@fin:
		inc word ptr[currentIP]
		call updateCSIP
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
	printStrNoWrite errorOpeningInputFile
	.exit
	pavykoAtidarytFaila:
	mov word ptr[filePtr], ax
	
	mov cx, 0000h
	mov ax, 03C00h
	lea dx, programParameter2
	int 21h
	jnc createSuccess
	printStrNoWrite errorCreatingOutputFile
	.exit
	createSuccess:
	mov ax, 03D01h
	lea dx, programParameter2
	int 21h
	jnc outFileOpened
	printStrNoWrite errorOpeningOutputFile
	.exit
	outFileOpened:
	mov word ptr[outFilePtr], ax
	
	push ds
	pop es
	cld
	
	
	
	byteByByte:
	mov byte ptr[printHowMany], 00h
	mov byte ptr[operationByteCount], 00h
	
	call decipher
	printChar 0Ah
	
	cmp byte ptr[redirectByte], 00h
	je notHangingRedirect
	call handleRedirect
	notHangingRedirect:
	
	mov cl, byte ptr[operationByteCount]
	add word ptr[currentIP], cx
	
	mov ah, byte ptr[printHowMany]
	mov byte ptr[printHowMany], 00h
	mov ch, 00h
	mov cl, byte ptr[operationByteCount]
	mov bx, 0000h
	printAllHexes:
	mov al, byte ptr[operationBytes+bx]
	call printHex
	inc bx
	loop printAllHexes
	mov byte ptr[printHowMany], ah
	add byte ptr[printHowMany], 0Ah		;nes CS:IP uzima 10 simboliu
	
	mov bh, 00h
	mov bl, byte ptr[printHowMany]
	mov byte ptr[prnThisCS+bx], '$'
	printStrNoWrite prnThisCS
	lea dx, prnThisCS
	mov cl, byte ptr[printHowMany]
	mov bx, word ptr[outFilePtr]
	mov ah, 040h
	int 21h
	jnc writeSuccess
	printStr errorWriting
	.exit
	writeSuccess:
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
