;***************************************************************************************************
; MOPL1.ASM - �祡�� �ਬ�� ��� �믮������ 
; ������୮� ࠡ��� N1 �� ��設��-�ਥ��஢������ �ணࠬ��஢����
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       �ᯮ������� ������樨 ����⠭� � ����ᮢ
        INCLUDE MOPL1.INC	
        INCLUDE MOPL1.MAC

; ������樨 ������
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"������� �.�.: ",0FFh
MINIS	DB	"������������ ����������� ���������� ���������",0
ULSTU	DB	"����������� ��������������� ����������� �����������",0
DEPT	DB	"��䥤� ���᫨⥫쭮� �孨��",0
MOP	DB	"��設��-�ਥ��஢����� �ணࠬ��஢����",0
LABR	DB	"������ୠ� ࠡ�� N 1",0
REQ1    DB      "��������� �६� ࠡ��� � ⠪��(-), �᪮��� �६� ࠡ��� � ⠪�� (+),", 0
;------------- ���� ��६���� ------------------------------------------------------------------
REQ2	DB	"���᫨�� �㭪�� (f), ���(ESC)?", 0FFh
;-------------------------------------------------------------------------------------------------
STR_TASK DB "����� 2 20ࠧ�來�� ������� �᫠, ���᫨�� ��ࠦ���� � �뢥�� १����.", 0
FUNCTION_TEXT DB "��ࠦ���� ����� ���: "
FUNCTION_EQUAL DB "Z = f5 ? "
FUNC_PART1 DB "X + Y * 2", 0FFh
FUNC_PART_SEP DB " : ", 0FFh
FUNC_PART2 DB "X / 2 - Y", 0
BOOL_FUNC DB "f5 = x1x2 | !x2!x3 | x1!x2x3 | !x1!x3 | !x1x2x3", 0
EQUAL_F5 DB "f5 = ", 0FFh
NEXT_EQUAL DB "����� "
Z_EQUAL DB "Z = ", 0FFh
TACTS   DB	"�६� ࠡ��� � ⠪��: ",0FFh
WRITE_X DB "������ X:", 0FFh
WRITE_Y DB "������ Y:", 0FFh
STR_TRUE DB "TRUE", 0
STR_FALSE DB "FALSE", 0
AFTER_CHANGE DB "��᫥ �ந��������� �८�ࠧ������: z6 = !z2; z16 &= z12; z11 |= z13", 0
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
PAUSE	DW	0, 0 ; ����襥 � ���襥 ᫮�� ����প� �� �뢮�� ��ப�
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; ��ப� �뢮�� �᫠ ⠪⮢
                                          ; ����� ��� ࠧ����⥫��� "`"

;========================= �ணࠬ�� =========================
        .CODE
; ����� ���������� ��ப� LINE �� ����樨 POS ᮤ�ন�� CNT ��ꥪ⮢,
; ����㥬�� ���ᮬ ADR �� �ਭ� ���� �뢮�� WFLD
BEGIN	LABEL	NEAR
	; ���樠������ ᥣ���⭮�� ॣ����
	MOV	AX,	@DATA
	MOV	DS,	AX
	; ���樠������ ����প�
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; ����� �����
	; ���� �����
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; 横���᪨� ����� ����७�� �뢮�� ���⠢��
	; �뢮� ���⠢��
	; ��������� ������� ������ �����
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; ࠧ����⥫쭠� ���
	PUTL	EMPTYS
	PUTLSC	MINIS	; ��ࢠ� 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  �  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   ��᫥���騥 
	PUTL	EMPTYS
	PUTLSC	MOP	;    ��ப�  
	PUTL	EMPTYS
	PUTLSC	LABR	;     ���⠢��
	PUTL	EMPTYS
	; �ਢ���⢨�
	PUTLSC	SNAME   ; ��� ��㤥��
	PUTL	EMPTYS
	; ࠧ����⥫쭠� ���
	PUTL	SLINE
	; ��������� ������� ��������� ����� 
	DURAT    	; ������ ����祭���� �६���
	; �८�ࠧ������ �᫠ ⨪�� � ��ப� � �뢮�
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; �뢮� �᫠ ⠪⮢
	; ��ࠡ�⪠ �������
	PUTL	REQ1
;------�뢮� ᢮�� ��ப � ����⢨ﬨ -------------------
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
PROC_TIME:	CMP	AL,	'-'    ; 㤫������ ����প�?
	JNE	CMINUS
	INC	PAUSE+2        ; �������� 65536 ���
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; 㪮�稢��� ����প�?
	JNE	CEXIT
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; 㡠���� 65536 ���
BACK:	JMP	@@L
CEXIT:	CMP	AL,	CHESC	
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; ��室 �� �ணࠬ��
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
