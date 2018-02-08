;***************************************************************************************************
; MOPL1.ASM - учебный пример для выполнения 
; лабораторной работы N1 по машинно-ориентированному программированию
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       Используются декларации констант и макросов
        INCLUDE MOPL1.INC	
        INCLUDE MOPL1.MAC

; Декларации данных
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"Фимилия И.О.: ",0FFh
MINIS	DB	"МИНИСТЕРСТВО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ",0
ULSTU	DB	"УЛЬЯНОВСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ",0
DEPT	DB	"Кафедра вычислительной техники",0
MOP	DB	"Машинно-ориентированное программирование",0
LABR	DB	"Лабораторная работа N 1",0
REQ1    DB      "Замедлить время работы в тактах(-), ускорить время работы в тактах (+),", 0
;------------- Новые переменные ------------------------------------------------------------------
REQ2	DB	"вычислить функцию (f), выйти(ESC)?", 0FFh
;-------------------------------------------------------------------------------------------------
STR_TASK DB "Ввести 2 20разрядных двоичных числа, вычислить выражение и вывести результат.", 0
FUNCTION_TEXT DB "Выражение имеет вид: "
FUNCTION_EQUAL DB "Z = f5 ? "
FUNC_PART1 DB "X + Y * 2", 0FFh
FUNC_PART_SEP DB " : ", 0FFh
FUNC_PART2 DB "X / 2 - Y", 0
BOOL_FUNC DB "f5 = x1x2 | !x2!x3 | x1!x2x3 | !x1!x3 | !x1x2x3", 0
EQUAL_F5 DB "f5 = ", 0FFh
NEXT_EQUAL DB "Тогда "
Z_EQUAL DB "Z = ", 0FFh
TACTS   DB	"Время работы в тактах: ",0FFh
WRITE_X DB "Введите X:", 0FFh
WRITE_Y DB "Введите Y:", 0FFh
STR_TRUE DB "TRUE", 0
STR_FALSE DB "FALSE", 0
AFTER_CHANGE DB "После произведенных преобразований: z6 = !z2; z16 &= z12; z11 |= z13", 0
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
BUF_LEN_NUMBER = 21
BUF_NUMBER	DB	BUF_LEN_NUMBER
LEN_NUMBER	DB	?
W_NUMBER	DB	BUF_LEN_NUMBER DUP (0)
X DD 0
Y DD 0
Z DD 0
PAUSE	DW	0, 0 ; младшее и старшее слова задержки при выводе строки
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; строка вывода числа тактов
                                          ; запас для разделительных "`"

;========================= Программа =========================
        .CODE
; Макрос заполнения строки LINE от позиции POS содержимым CNT объектов,
; адресуемых адресом ADR при ширине поля вывода WFLD
BEGIN	LABEL	NEAR
	; инициализация сегментного регистра
	MOV	AX,	@DATA
	MOV	DS,	AX
	; инициализация задержки
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; запрос имени
	; ввод имени
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; циклический процесс повторения вывода заставки
	; вывод заставки
	; ИЗМЕРЕНИЕ ВРЕМЕНИ НАЧАТЬ ЗДЕСЬ
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; разделительная черта
	PUTL	EMPTYS
	PUTLSC	MINIS	; первая 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  и  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   последующие 
	PUTL	EMPTYS
	PUTLSC	MOP	;    строки  
	PUTL	EMPTYS
	PUTLSC	LABR	;     заставки
	PUTL	EMPTYS
	; приветствие
	PUTLSC	SNAME   ; ФИО студента
	PUTL	EMPTYS
	; разделительная черта
	PUTL	SLINE
	; ИЗМЕРЕНИЕ ВРЕМЕНИ ЗАКОНЧИТЬ ЗДЕСЬ 
	DURAT    	; подсчет затраченного времени
	; Преобразование числа тиков в строку и вывод
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; вывод числа тактов
	; обработка команды
	PUTL	REQ1
;------Вывод своих строк с действиями -------------------
	PUTL	REQ2
;--------------------------------------------------------
	CALL	GETCH
	CMP AL, 'f'
	JNE PROC_TIME
INP_NUM:	
	PUTL EMPTYS
	PUTL STR_TASK
	PUTL EMPTYS
	PUTL FUNCTION_TEXT
	PUTL FUNC_PART_SEP
	PUTL FUNC_PART2
	PUTL EMPTYS
	PUTL BOOL_FUNC
	PUTL EMPTYS
	PUTL WRITE_X
	PUTL EMPTYS
	CALL INP_NUM_EBX
	MOV X, ebx
	PUTL EMPTYS
	PUTL WRITE_Y
	PUTL EMPTYS
	CALL INP_NUM_EBX
	MOV Y, ebx
	
FUN_BOOL_CALC:
	MOV eax, X
	BT eax, 1
	JNC B2
	BT eax, 2
	JC TRUE
B2: 
	BT eax, 2
	JC B3
	BT eax, 3
	JNC TRUE
B3:
	BT eax, 1
	JNC B4
	BT eax, 2
	JC B4
	BT eax, 3
	JC TRUE 
B4: 
	BT eax, 1
	JC B5
	BT eax, 3
	JNC TRUE
B5:
	BT eax, 1
	JC FALSE
	BT eax, 2
	JNC FALSE
	BT eax, 3
	JC TRUE	
FALSE:
	PUTL EMPTYS
	PUTL EQUAL_F5
	PUTL STR_FALSE
	PUTL NEXT_EQUAL
	PUTL FUNC_PART2
	JMP	CALC_Z_0
TRUE:
	PUTL EMPTYS
	PUTL EQUAL_F5
	PUTL STR_TRUE
	PUTL NEXT_EQUAL
	PUTL FUNC_PART1
	JMP	CALC_Z_1
	
CALC_Z_1:
	MOV ebx, X
	MOV eax, Y
	SHL eax, 1
	ADD ebx, eax
	MOV Z, ebx
	PUTL EMPTYS
	PUTL Z_EQUAL
	CALL PRINT_NUMBER_EBX
	JMP	CNG_Z
CALC_Z_0:
	MOV ebx, X
	MOV eax, Y
	SHR ebx, 1
	MOV ecx, ebx
	SUB ecx, eax
	CMP ECX, 0
	JNS POSIT
	SUB eax, ebx
	MOV ebx, eax
	BTS ebx, 19
	JMP SAP
POSIT:
	SUB ebx, eax
SAP: 
	MOV Z, ebx
	PUTL EMPTYS
	PUTL Z_EQUAL
	CALL PRINT_NUMBER_EBX
	JMP	CNG_Z
	
CNG_Z: 
	MOV ebx, Z
	BT ebx, 2
	JC ZERO
	BTS ebx, 6
	JMP Z_2
ZERO:
	BTR ebx, 6
Z_2:
	BT ebx,12
	JC Z_3
	BTR ebx, 16
Z_3:
	BT ebx, 13
	JNC FIN_Z
	BTS ebx, 11
FIN_Z:
	PUTL EMPTYS
	PUTL EMPTYS
	PUTL AFTER_CHANGE
	PUTL Z_EQUAL
	CALL PRINT_NUMBER_EBX
	PUTL EMPTYS
	JMP	@@E
PRINT:
	PUTL EMPTYS
	MOV ebx, X
	CALL PRINT_NUMBER_EBX
	PUTL EMPTYS
	MOV ebx, Y
	CALL PRINT_NUMBER_EBX
	PUTL EMPTYS
	JMP	@@E
PROC_TIME:	CMP	AL,	'-'    ; удлиннять задержку?
	JNE	CMINUS
	INC	PAUSE+2        ; добавить 65536 мкс
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; укорачивать задержку?
	JNE	CEXIT
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; убавить 65536 мкс
BACK:	JMP	@@L
CEXIT:	CMP	AL,	CHESC	
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; Выход из программы
@@E:	EXIT	
    EXTRN	PUTSS:  NEAR
    EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETECH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR 
	EXTRN PRINT_NUMBER_EBX: NEAR 
	EXTRN INP_NUM_EBX: NEAR 
	EXTRN   UTOA10: NEAR
	END	BEGIN
