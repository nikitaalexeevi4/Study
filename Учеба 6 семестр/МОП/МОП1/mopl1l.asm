;*********************************************************
; Процедуры для учебного примера лабораторной работы N 1  *
; по МОП.                                                 *
;*********************************************************

.MODEL SMALL
.CODE
.386
 INCLUDE MOPL1.INC
 LOCALS
;=====================================================
; Подпрограмма вывода на экран строки, адресуемой SI, 
; с задержкой времени между символами в <CX,DX> mcs.
; Завершителями строки являеются байты 0 или 0FFh.
; ЕСЛИ строка заканчивается байтом 0,
;   ТО добавляется переход в начало новой строки
; 
;=====================================================
PUTSS   PROC	NEAR
@@L:    MOV	AL,	[SI]
        CMP	AL,	0FFH
        JE	@@R
        CMP	AL,	0
        JZ	@@E
        CALL	PUTC
        INC	SI
	CALL	DILAY
        JMP	SHORT @@L
        ; Переход на следующую строку
@@E:    MOV	AL, CHCR
        CALL	PUTC
        MOV	AL, CHLF
        CALL	PUTC
@@R:    RET
PUTSS	ENDP

;==============================================
; Подпрограмма вывода AL на терминал
;==============================================
PUTC	PROC	NEAR
        PUSH	DX
        MOV	DL,   AL
        MOV	AH,   FUPUTC
        INT	DOSFU
        POP	DX
        RET
PUTC	ENDP

;==============================================
; Подпрограмма ввода символа в AL с терминала
;==============================================
GETCH	PROC	NEAR
        MOV	AH,   FUGETCH
        INT	DOSFU
        RET
GETCH	ENDP

;==============================================
; Подпрограмма посимвольного считывания с терминала
;==============================================

GETECH	PROC	NEAR
        MOV	AH,   1h
        INT	DOSFU
        RET
GETECH	ENDP

;==============================================
; Подпрограмма вывода ЕВХ на терминал
;==============================================

PRINT_NUMBER_EBX PROC	NEAR
	PUSH ebx
	MOV cx, 19
CICLE: BT ebx, 19
	JNC ZERO
    MOV	AH, 2h
	MOV DL, '1'
    INT	21h
	JMP INCREM
	ZERO: 
    MOV	AH, 2h
	MOV DL, '0'
    INT	21h
INCREM:	
	SHL ebx, 1
	LOOP CICLE
R:	POP ebx
	RET
PRINT_NUMBER_EBX	ENDP

;==============================================
; Подпрограмма ввода числа ЕВХ с терминала
;==============================================

INP_NUM_EBX PROC NEAR
	MOV cx, 19
	XOR ebx, ebx
	
READ_NEXT:	
    CALL GETECH
	CMP AL, '1'
	JNE NOT_E
	BTS ebx, 0
	SHL ebx, 1
	JMP DECREM
NOT_E: 
	CMP AL, '0'
	JNE FINISH
	SHL ebx, 1
DECREM: 
	CMP cx, 0
	JE RETURN
	DEC cx
	JMP READ_NEXT
FINISH:
	CMP cx, 0
	JE RETURN
	;;SHR ebx, 1
	DEC cx
	JMP FINISH
RETURN: RET
INP_NUM_EBX ENDP

;=================================================
; Подпрограмма ввода строки в буфер, адресуемый DX
;   и имеющий структуру: 
;    { char size; // размер буфера 
;      char len;  // реально введено
;      char str[size]; // символы строки }
;=================================================
GETS	PROC	NEAR
	PUSH	SI
	MOV	SI,	DX
        MOV	AH,	FUGETS
        INT	DOSFU
	; прописать байт 0 в конец строки
	XOR	AH,	AH
	MOV	AL,	[SI+1]
	ADD	SI,	AX
	MOV	BYTE PTR [SI+2], 0
	POP	SI
        RET
GETS	ENDP

;==============================================
; Подпрограмма подсчета числа символов в строке,
; адресуемой SI. Завершители строки: 0 и 0FFh
; Результат возвращается в AX
;==============================================
SLEN	PROC	NEAR
	XOR     AX,   AX
LSLEN:  CMP     BYTE PTR [SI], 0
	JE	RSLEN
        CMP     BYTE PTR [SI], 0FFh
	JE	RSLEN
	INC	AX
	INC	SI
	JMP	SHORT	LSLEN
RSLEN:  RET
SLEN 	ENDP

;====================================================
; Подпрограмма преобразования <EDX,EAX> в беззнаковое 
; десятичное, размещаемое по адресу DI
;==============================================
	.DATA
UBINARY	DQ	0  ; Исходное двоичное 64-разрядное
UPACK	DT	0  ; Упакованные 18 десятичных цифр	
	.CODE
UTOA10	PROC	NEAR
	PUSH	CX
	PUSH	DI
	MOV	DWORD PTR [UBINARY],   EAX
	MOV	DWORD PTR [UBINARY+4], EDX
	FINIT			; инициализация сопроцессора
	FILD	UBINARY		; забрасывание в него бинарного
	FBSTP	UPACK		; извлечение упаковонного десятичного
	MOV	CX,	LENPACK	; получено 9 пар цифр
	PUSH	DS		; писать 
	POP	ES 		;   будем
	CLD     		;     через stosw
	LEA	SI,	UPACK   ;     с конца 
	ADD	SI,	LENPACK	;     буфера upack        
	; Цикл преобразования пар полубайтов в ASCII-коды цифр
@@L:	XOR	AX,	AX
	DEC	SI
	MOV	AL,	[SI]
	SHL	AX,	4
	SHR	AL,	4	
	ADD	AX,	3030h
	XCHG	AL,	AH
	STOSW		
	LOOP	@@L
	; Фиксация конца строки
	XOR	AL, 	AL
	STOSB
	; Улучшим читабельность слишком длинного числа
	CLD
	MOV	AX,	LENNUM-4	
@@L1:	MOV	CX,	AX
	POP	DI	   ; встаем на начало строки
	PUSH	DI	
	MOV	SI,	DI
	INC	SI
	REP	MOVSB
	MOV	BYTE PTR [DI], CHCOMMA ; вставить разделитель троек цифр
	SUB	AX,	4  ;     3 цифры + разделитель обработаны
	JS	@@E        ; прекратить, если осталось не больше 3-х цифр
	JMP	SHORT	@@L1
@@E:	POP	SI
	PUSH	SI
	XOR	CX,	CX
	; Съедаем первые нули
	;   сначала подсчитываем
@@L2:	CMP	BYTE PTR [SI], '0'
	JE	@@N
	CMP	BYTE PTR [SI], CHCOMMA		
	JNE	@@N1
@@N:	INC	CX
	INC	SI
	JMP	SHORT	@@L2
@@N1:	;   а теперь съедаем
	POP	DI
	SUB	CX, LENNUM+1
	NEG	CX
	REP	MOVSB
	POP	CX
        RET
UTOA10	ENDP

;==============================================
; Подпрограмма задержки выполнения программы 
; на <CX,DX> микросекунд 
;==============================================
DILAY	PROC	NEAR
	MOV	AH,	86h
        INT	15h
        RET
DILAY	ENDP

        PUBLIC	PUTSS, PUTC, GETCH, GETS, DILAY, SLEN, UTOA10, GETECH, PRINT_NUMBER_EBX, INP_NUM_EBX

        END
