data segment
ioport equ  280h; tpc �����豸�� io ��ַ
io82530 equ 280h; ������ͨ�� 0 ��ַ
io82531 equ  281h; ������ͨ�� 1 ��ַ
io82532 equ  282h; ������ͨ�� 2 ��ַ
io8253ctrl equ 283h; 8253 ���ƼĴ�����ַ

io8255a equ  288h; 8255A �ڵ�ַ
io8255b equ  289h; 8255B �ڵ�ַ
io8255c equ  28ah; 8255C �ڵ�ַ
io8255ctrl equ  28bh; 8255 ���ƼĴ����˿ڵ�ַ

; ������ʾ
arrow_in db 00h, 18h, 3ch, 7eh, 18h, 18h, 18h, 00h; ��ͷ��
arrow_out db 00h, 18h, 18h, 18h, 7eh, 3ch, 18h, 00h; ��ͷ��
forbid db 81h, 42h, 24h, 18h, 18h, 24h, 42h, 81h; ��ֹ
whole db 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh; ��ֹ
;LED��
LED db 3fh, 06h, 5bh, 4fh, 66h, 6dh, 7dh, 07h, 7fh, 6fh; LED�߶���
row equ  290h; ��ѡ
red equ 298h; ��ѡ
green equ 2a0h; ��ѡ

;C7��C6��C5��C4��Ӧ A�Ľ����ڡ�B�Ľ�����
;C3��C2��ӦA��B������LEDС��
;C1��C0��Ӧ����ܵ�ʮ����λƬѡ

NUM db 3, 4 dup(0)

waitkey db 3, 4 dup(0) ;������

empty db 2 dup(0); ���ڴ�ſ��г�λ��ʮλ�͸�λ
state_a db 00h; ��־ a �ڽ�״̬�� 0 ��ʾ���У� 1 ��ʾ׼�����룬 2 ��־���ڽ���
state_ax db 00h; ��־ a ��״̬�� 0 ��ʾ���У� 1 ��ʾ׼����ȥ�� 2 ��־���ڳ�ȥ

state_b db 00h; ��־ b ��״̬�� 0 ��ʾ���У� 1 ��ʾ���ڽ��룬 2 ��־���ڽ���
state_bx db 00h; ��־ b ��״̬�� 0 ��ʾ���У� 1 ��ʾ׼����ȥ�� 2 ��־���ڳ�ȥ

FullFlag db 00h;ͣ��������־
EmptyFlag db 00h;ͣ�����ձ�־

checktimeA db 00h;A����ʾ����checking�źż�������
checktimeB db 00h;B����ʾ����checking�źż�������
checktimeAx db 00h;A����ʾ����checking�źż�������
checktimeBx db 00h;B����ʾ����checking�źż�������


Welcome DB '|---------------------------------------------------------|', 0DH, 0AH
DB '|                Welcome To SEU PARKING LOT               |', 0DH, 0AH
DB '|                     -By YYH & LYH-                      |', 0DH, 0AH
DB '|                         -2019-                          |', 0DH, 0AH
DB '|---------------------------------------------------------|', 0DH, 0AH, '$'

String1 db 'Please Decide How Many Empty Parking Spots Is Available(00~99):', 0dh, 0ah, '$'
String2 db 'Out Of Range!Please Try Again!', 0dh, 0ah, '$'
String3 db 'A car wants to enter from A...', 0dh, 0ah, '$'
String4 db 'Checking...', 0dh, 0ah, '$'
String5 db 'Permit to enter!', 0dh, 0ah, '$'

String6 db 'Empty parking spots:', 0dh, 0ah, '$'
String7 db 'Full!', 0dh, 0ah, '$'
String8 db 'Empty!', 0dh, 0ah, '$'
String9 db 'Permit to leave!', 0dh, 0ah, '$'

String10 db 'A car wants to leave from A...', 0dh, 0ah, '$'
String11 db 'A car wants to enter from B...', 0dh, 0ah, '$'
String12 db 'A car wants to leave from B...', 0dh, 0ah, '$'

Stringerror db 'Error From Signals !', 0dh, 0ah, '$'
bz dw ?
data ends

stacks segment stack
db 100 dup(? )
stacks ends

code segment
assume cs : code, ds : data, ss : stacks

start : 
    mov ax, data; ��ʼ���Ĵ���
    mov ds, ax
    mov ax, stacks 
    mov ss, ax 
    
    mov dx, io8255ctrl
    mov al, 10001010b    ; 00 A������ʽ 0, 0 ���  ����ܵ�����
                         ; 1 ����C��λ ���ڶ�ȡ�����ź�
                         ; 0 B������ʽ 0, 1 ���� ����ʱ�����ź�
                         ; 0 ��� C��λ,C3��C2�������˵�ledС�ơ�C1��C0�����Ƭѡ����
                         
    out dx, al
    mov dx, io8253ctrl; ������ 0 ������ʽ 3 ����������
    mov al, 00110110b
    out dx, al 
    mov al, 01110000b; ������ 1��������ʽ 0  ���������ߵ�ƽ
    out dx, al 

    mov dx, io82530    ; ������ 0 ��ֵ 1000(��һ�η�Ƶ)
    mov ax, 1000 
    out dx, al
    mov al, ah 
    out dx, al;����д��
    
    mov dx, offset Welcome;��ӭ����
    mov ah, 09h
    int 21h
begin : 
    mov dx, offset String1; ִ���������ʾ
    mov ah, 09h;    
    int 21h

    mov dx, offset NUM; �����ʼ�ճ�λ���浽NUM
    mov ah, 0ah
    int 21h 

    mov dl, 0ah 
    mov ah, 02h
    int 21h ; �س�
    mov dl, 0dh
    mov ah, 02h
    int 21h; ����

    mov al, NUM[2]; �ж�������ֵ�Ƿ��������
    sub al, 30h; �� ASCII ��ת��Ϊ����
    cmp al, 0
    jb error
    cmp al, 9
    ja error
    mov empty[1], al;������a������ΪLED��ʮλ

    mov al, NUM[3]
    sub al, 30h;
    cmp al, 0; С�� 0 �Ļ���ת�Ƶ� error
    jb error 
    cmp al, 9; ���� 9 �Ļ���ת�Ƶ� error
    ja error 
    mov empty[0], al; ������b������ΪLED�ĸ�λ
    jmp main;ִ����ѭ��
error:
    mov dx, offset String2;������󱨴�
    mov ah, 09h
    int 21h
    jmp begin
error2:
    mov dx, offset Stringerror;���ذ�����
    mov ah, 09h
    int 21h
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
main:         ; ��ѭ�� 
    call LED_show  ; �����������ʾ 
    call Arrow_show; ������ʾ���ͼʾ 

    mov dx, io8255c; �� 8255C ��λ���뿪���ź�
    in al, dx
    and al,0f0h

    ;;;;;;;;;������;;;;;;;;;;
    ;mov dx, offset waitkey; 
    ;mov ah, 0ah
    ;int 21h 
    ;mov ax,0
    ;mov al, waitkey[2]
    ;sub ax,30h
    ;shl ax,1
    ;shl ax,1
    ;shl ax,1
    ;shl ax,1

    push ax
    xor al,11110000B
    pop ax
    push ax
    jz error2;�ĸ�����ȫ����;����
    pop ax
    push ax
    xor al, 11000000B
    jz error2;A�ڿ���ȫ����;����
    pop ax
    push ax
    xor al, 00110000B
    jz error2;B�ڿ���ȫ����;����
    pop ax
    push ax
    xor al, 00000000B
    jz main
    pop ax
checkA1 :
    test state_ax,2;��ǰA���ź���Ȼû�ˣ� ����ȴ�������ڳ���״̬
    jnz checkA2plus
    test state_b,2; ��ǰB���ź���Ȼû�ˣ� ����ȴ�������ڽ���״̬
    jnz checkB1plus
    test state_bx,2;��ǰB���ź���Ȼû�ˣ� ����ȴ�������ڳ���״̬
    jnz checkB2plus
    test al, 10000000b;���A�ڿ���1
    jz checkA1plus;
    call TestA1; ����A�ſڿ��� 1 �������г�Ҫ���룬��ʱӦ�ü�⵱ǰA�ſ�״̬
    jmp main  
checkA1plus :
    test state_a,2;��ǰ���ź���Ȼû�ˣ�����ȴ�������ڽ���״̬
    jz checkA2
    call TestA1;
    jmp main
checkA2 : 
    test al,01000000b;���A�ڿ���2
    jz checkA2plus;����0������һ״̬
    call TestA2; A�ſڿ��� 2 �������г�Ҫ��ȥ����ʱӦ�ü�⵱ǰA�ſ�״̬
    jmp main
checkA2plus :
    test state_ax,2;��ǰ���ź���Ȼû�ˣ�����ȴ�������ڳ���״̬
    jz checkB1
    call TestA2;
    jmp main

Tomain:
    jmp main

checkB1 :
    test al, 00100000b;���B�ڿ���1
    jz checkB1plus;����0;��ǰ����δ����, ������һ����
    call TestB1; ����B�ſڿ��� 1 �������г�Ҫ���룬��ʱӦ�ü�⵱ǰB�ſ�״̬
    jmp Tomain  
checkB1plus :
    test state_b,2;��ǰ���ź���Ȼû�ˣ�����ȴ�������ڽ���״̬
    jz checkB2
    call TestB1;
    jmp Tomain
checkB2 : 
    test al,00010000b;���B�ڿ���2
    jz checkB2plus;����0������һ״̬
    call TestB2; B�ſڿ��� 2 �������г�Ҫ��ȥ����ʱӦ�ü�⵱ǰB�ſ�״̬
    jmp Tomain
checkB2plus :
    test state_bx,2;��ǰ���ź���Ȼû�ˣ�����ȴ�������ڽ���״̬
    jz Tomain
    call TestB2;
    jmp Tomain                                                
exit : 
    mov ah, 4ch ;�˳��ܳ���
    int 21h
;;;;;;;;;;;;;;;;;;;;A�ڿ���1���������A��״̬;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestA1 proc near 
    push ax ;�����ֳ�
    push dx; 
    mov state_ax, 0; A�ڳ��ź���0
    mov state_b,  0; B�ڽ��ź���0        ��ֹ��һ�����ź���Чʱ״̬ͣ����1����δ����
    mov state_bx, 0; B�ڳ��ź���0    
    mov checktimeAx,00h;
    mov checktimeB,00h;
    mov checktimeBx,00h;

    cmp state_a, 0; 
    jz state_A1; ����0,ͣ�������ڿ���״̬�����е���ʱ2s��ֵ
    cmp state_a, 1;״̬1
    jz timein_a2s;Ϊ״̬1���г�׼��������⵹��ʱ2s�Ƿ����
    cmp state_a, 2;״̬2,�г����ڽ�����⵹��ʱ1s�Ƿ����
    jz timein_a1s
    jmp exit1;�˳�
;;;;;;;;;;;;;;;;;;;;;;;��ǰΪ0����A��״̬1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
state_A1 : 
    mov dx, offset String3; ��ʾ�г�׼����A����
    mov ah, 09h
    int 21h
    test FullFlag,1
    jnz fulljmp 
    jmp contjudgeA
fulljmp:
    mov dx, offset String7;��ʾ����
    mov ah, 09h
    int 21h;
    pop ax
    pop dx 
    ret
contjudgeA:
    mov state_a, 1;  ��Ϊ״̬1
    mov dx, io82531; 
    mov ax, 2000;�ڶ��η�Ƶ��������Ϊ2s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit1;����A�ڿ���1���,���B�ڿ���1
;;;;;;;;;;;;;;;;;;;���A��2s����ʱ,������A��״̬Ϊ2;;;;;;;;;;;;;;;;;;;;;;
timein_a2s : 
    mov dx, io8255b;
    in al, dx 
    test al,01h
    jnz enterance ;2sʱ�䵽
    and checktimeA,1
    jnz exit1plus
    mov dx, offset String4;2s����ʱδ�����������ڼ�����
    mov ah, 09h
    int 21h
    mov checktimeA,1;��ֻ֤��ʾһ��checking���
exit1plus:
    pop dx;��Ϊexit1̫Զ��
    pop ax 
    ret
enterance: 
    mov dx, offset String5;2s����ʱ�������������Ѿ���
    mov ah, 09h
    int 21h
    mov state_a, 2;���ڽ��룬׼����ʼ1s����ʱ
    mov dx, io8255ctrl; ���ƣ����˴򿪣�
    mov al, 00000111b;C��λ�ÿ���,0111: 011ʹ��PC3����1��C �� 3 �ſڶ�Ӧ��A�����ź�)
    out dx, al
    mov dx, io82531; 
    mov ax, 1000;�ڶ��η�Ƶ��������Ϊ1s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit1;����A�ڿ���1���,���B�ڿ���1
;;;;;;;;;;;;;;;;;;;���A��1s����ʱ,������A��״̬Ϊ2;;;;;;;;;;;;;;;;;;;;;;
timein_a1s : 
    mov dx, io8255b;
    in al, dx 
    test al, 01h;
    jnz entered ;1sʱ�䵽
    jmp exit1
entered : 
    mov state_a, 0;�Ѿ����룬��0
    mov EmptyFlag, 0

    mov checktimeA,00h;���checking����������0
    mov dx, io8255ctrl; �صƣ����˹رգ�
    mov al, 00000110b;C��λ�ÿ���,0110: 011ʹ��PC3����0��C �� 3 �ſڶ�Ӧ��A�����ź�)
    out dx, al
    mov al, empty[0];1sʱ�䵽��ͣ��λ��һ
    mov ah, empty[1]
    cmp ax, 0;�ж��Ƿ�ͣ��λ�Ƿ�����
    jz fulled;ͣ��������,����
    cmp al,0
    jnz aldec
    sub ax,10
    mov al,0Ah
aldec:
    sub ax, 1;ͣ��λ��һ
    mov empty[0], al;��ǰͣ��λ������ֵ
    mov empty[1], ah
    mov dx, offset String6; ��Ļ��ʾʣ�೵λ
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; �س�
    mov dl, 0dh
    mov ah, 02h
    int 21h; ����
    mov al, empty[0];1sʱ�䵽��ͣ��λ��һ
    mov ah, empty[1]
    cmp ax, 0;�ж��Ƿ�ͣ��λ�Ƿ�����
    jz fulled;ͣ��������,����
    jmp exit1
fulled:
    mov FullFlag, 1
    mov dx, offset String7;��ʾ����
    mov ah, 09h
    int 21h;
exit1:
    pop dx
    pop ax 
    ret
TestA1 endp
;;;;;;;;;;;;;;;;;;;;;A�ڿ���2���������A��״̬,1s����ʱ��������A��״̬Ϊ3;;;;;;;;;;;;;;;;;;;;;;;;;;; 
TestA2 proc near
    push ax
    push dx 
    mov state_a, 0; A�ڳ��ź���0
    mov state_b,  0; B�ڽ��ź���0        ��ֹ��һ����δ����
    mov state_bx, 0; B�ڳ��ź���0    
    mov checktimeA,00h;
    mov checktimeB,00h;
    mov checktimeBx,00h;

    cmp state_ax, 0
    jz stateout_a1;A��״̬Ϊ0,˵��ǰ���޳�
    cmp state_ax,1
    jz timeout_a1s;A��״̬Ϊ1,˵��׼������
    cmp state_ax,2
    jz timeout_a3s;A��״̬Ϊ2,˵�����ڳ���
    jmp exit2
stateout_a1:
    test EmptyFlag,1
    jnz emptyjmp 
    jmp contjudgeAx
emptyjmp:
    pop ax
    pop dx 
    ret
contjudgeAx:
    mov dx, offset String10; ��ʾ�г�׼����A�뿪
    mov ah, 09h
    int 21h
    mov state_ax, 1;��A��Ϊ1
    mov dx, io82531;��ʼ��Ƶ1s
    mov ax,1000;�ڶ��η�Ƶ��������Ϊ1s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah 
    out dx, al;�ָߵ�λд��
    jmp exit2
timeout_a1s:
    mov dx, io8255b;
    in al, dx 
    and al, 01h;
    jnz outrance ;1sʱ�䵽
    and checktimeAx,1
    jnz exit2plus
    mov dx, offset String4;��ʾ���ڲ�ѯ
    mov ah, 09h
    int 21h;
    mov checktimeAx,1
exit2plus:
    pop dx;��Ϊexit2̫Զ��
    pop ax 
    ret
outrance:
    mov dx, offset String9;��ʾ�����Ѿ���
    mov ah, 09h
    int 21h;
    mov state_ax, 2;���ڳ��У�׼����ʼ3s����ʱ
    mov dx, io8255ctrl; ���ƣ����˴򿪣�
    mov al,00000111b;C��λ�ÿ���,0101: 010ʹ��PC2����1��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov dx, io82531; 
    mov ax, 3000;�ڶ��η�Ƶ��������Ϊ2s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit2;
timeout_a3s:
    mov dx,io8255b;
    in al, dx 
    and al, 01h;
    jnz outed ;3sʱ�䵽
    jmp exit2
outed:
    mov state_ax, 0;�Ѿ��뿪����0
    mov FullFlag, 0
      mov checktimeAx,0
    mov dx, io8255ctrl; �صƣ����˹رգ�
    mov al, 00000110b;C��λ�ÿ���,0100: 010ʹ��PC2����0��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;�ж��Ƿ�ͣ��λ�Ƿ��ѿ�
    jz emptyed;ͣ�����ѿ�,����
    mov al, empty[0]
    mov ah, empty[1]
    inc ax;ͣ��λ��һ
    aaa;��16���Ƶ���ΪBCD��
    mov empty[0], al;��ǰͣ��λ������ֵ
    mov empty[1], ah
    mov dx, offset String6; ��Ļ��ʾʣ�೵λ
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; �س�
    mov dl, 0dh
    mov ah, 02h
    int 21h; ����
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;�ж��Ƿ�ͣ��λ�Ƿ��ѿ�
    jz emptyed
    jmp exit2
emptyed:
    mov EmptyFlag, 1
    mov dx, offset String8; ��Ļ��ʾͣ�����ѿ�
    mov ah, 09h
    int 21h
exit2 : 
    pop dx
    pop ax
    ret
TestA2 endp


;;;;;;;;;;;;;;;;;;;;A�ڿ���1���������A��״̬;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestB1 proc near 
    push ax ;�����ֳ�
    push dx; 
    mov state_a, 0; A�ڳ��ź���0
    mov state_ax, 0; A�ڳ��ź���0        ��ֹ��һ�����ź���Чʱ״̬ͣ����1����δ����
    mov state_bx, 0; B�ڳ��ź���0    
    mov checktimeA,00h;
    mov checktimeAx,00h;
    mov checktimeBx,00h;
    

    cmp state_b, 0; 
    jz state_B1; ����0,ͣ�������ڿ���״̬�����е���ʱ2s��ֵ
    cmp state_b, 1;״̬1
    jz timein_b2s;Ϊ״̬1���г�׼��������⵹��ʱ2s�Ƿ����
    cmp state_b, 2;״̬2,�г����ڽ�����⵹��ʱ1s�Ƿ����
    jz timein_b1s
    jmp exit1B;�˳�
;;;;;;;;;;;;;;;;;;;;;;;��ǰΪ0����B��״̬1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
state_B1 : 
    mov dx, offset String11; ��ʾ�г�׼����B����
    mov ah, 09h
    int 21h
    test FullFlag,1
    jnz fulljmpB 
    jmp contjudgeB
fulljmpB:
    mov dx, offset String7;��ʾ����
    mov ah, 09h
    int 21h;
    pop ax
    pop dx 
    ret
contjudgeB:
    mov state_b, 1;  ��Ϊ״̬1
    mov dx, io82531; 
    mov ax, 2000;�ڶ��η�Ƶ��������Ϊ2s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit1B;����A�ڿ���1���,���B�ڿ���1
;;;;;;;;;;;;;;;;;;;���B��2s����ʱ,������B��״̬Ϊ2;;;;;;;;;;;;;;;;;;;;;;
timein_b2s : 
    mov dx, io8255b;
    in al, dx 
    test al,01h
    jnz enteranceB ;2sʱ�䵽
    and checktimeB,1
    jnz exit1plusB
    mov dx, offset String4;2s����ʱδ�����������ڼ�����
    mov ah, 09h
    int 21h
    mov checktimeB,1;��ֻ֤��ʾһ��checking���
exit1plusB:
    pop dx;��Ϊexit1̫Զ��
    pop ax 
    ret
enteranceB: 
    mov dx, offset String5;2s����ʱ�������������Ѿ���
    mov ah, 09h
    int 21h
    mov state_b, 2;���ڽ��룬׼����ʼ1s����ʱ
    mov dx, io8255ctrl; ���ƣ����˴򿪣�
    mov al, 00000101b;C��λ�ÿ���,0101: 010ʹ��PC2����1��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov dx, io82531; 
    mov ax, 1000;�ڶ��η�Ƶ��������Ϊ1s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit1B;����A�ڿ���1���,���B�ڿ���1
;;;;;;;;;;;;;;;;;;;���B��1s����ʱ,������B��״̬Ϊ2;;;;;;;;;;;;;;;;;;;;;;
timein_b1s : 
    mov dx, io8255b;
    in al, dx 
    test al, 01h;
    jnz enteredB ;1sʱ�䵽
    jmp exit1
enteredB : 
    mov state_b, 0;�Ѿ����룬��0
    mov EmptyFlag, 0
    mov checktimeB,00h;���checking����������0
    mov dx, io8255ctrl; �صƣ����˹رգ�
    mov al, 00000100b;C��λ�ÿ���,0101: 010ʹ��PC2����0��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov al, empty[0];1sʱ�䵽��ͣ��λ��һ
    mov ah, empty[1]
    cmp ax, 0;�ж��Ƿ�ͣ��λ�Ƿ�����
    jz fulledB;ͣ��������,����
    cmp al,0
    jnz aldecB
    sub ax,10
    mov al,0Ah
aldecB:
    sub ax, 1;ͣ��λ��һ
    mov empty[0], al;��ǰͣ��λ������ֵ
    mov empty[1], ah
    mov dx, offset String6; ��Ļ��ʾʣ�೵λ
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; �س�
    mov dl, 0dh
    mov ah, 02h
    int 21h; ����
    mov al, empty[0];1sʱ�䵽��ͣ��λ��һ
    mov ah, empty[1]
    cmp ax, 0;�ж��Ƿ�ͣ��λ�Ƿ�����
    jz fulledB;ͣ��������,����
    jmp exit1
fulledB:
    mov FullFlag, 1
    mov dx, offset String7;��ʾ����
    mov ah, 09h
    int 21h;
exit1B:
    pop dx
    pop ax 
    ret
TestB1 endp
;;;;;;;;;;;;;;;;;;;;;B�ڿ���2���������B��״̬,1s����ʱ��������A��״̬Ϊ3;;;;;;;;;;;;;;;;;;;;;;;;;;; 
TestB2 proc near
    push ax
    push dx 
    mov state_a, 0; A�ڳ��ź���0
    mov state_ax, 0; A�ڳ��ź���0
    mov state_b,  0; B�ڽ��ź���0        ��ֹ��һ����δ����   
    mov checktimeA,00h;
    mov checktimeAx,00h;
    mov checktimeB,00h;
    

    cmp state_bx, 0
    jz stateout_b1;B��״̬Ϊ0,˵��ǰ���޳�
    cmp state_bx,1
    jz timeout_b1s;B��״̬Ϊ1,˵��׼������
    cmp state_bx,2
    jz timeout_b3s;B��״̬Ϊ2,˵�����ڳ���
    jmp exit2B
stateout_b1:
    test EmptyFlag,1
    jnz emptyjmpB 
    jmp contjudgeBx
emptyjmpB:
    pop ax
    pop dx 
    ret
contjudgeBx:
    mov dx, offset String12; ��ʾ�г�׼����B�뿪
    mov ah, 09h
    int 21h
    mov state_bx, 1;��A��Ϊ1
    mov dx, io82531;��ʼ��Ƶ1s
    mov ax,1000;�ڶ��η�Ƶ��������Ϊ1s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah 
    out dx, al;�ָߵ�λд��
    jmp exit2B
timeout_b1s:
    mov dx, io8255b;
    in al, dx 
    and al, 01h;
    jnz outranceB ;1sʱ�䵽
    and checktimeBx,1
    jnz exit2plusB
    mov dx, offset String4;��ʾ���ڲ�ѯ
    mov ah, 09h
    int 21h;
    mov checktimeBx,1
exit2plusB:
    pop dx;��Ϊexit2̫Զ��
    pop ax 
    ret
outranceB:
    mov dx, offset String9;��ʾ�����Ѿ���
    mov ah, 09h
    int 21h;
    mov state_bx, 2;���ڳ��У�׼����ʼ3s����ʱ
    mov dx, io8255ctrl; ���ƣ����˴򿪣�
    mov al,00000101b;C��λ�ÿ���,0101: 010ʹ��PC2����1��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov dx, io82531; 
    mov ax, 3000;�ڶ��η�Ƶ��������Ϊ2s�����һ��Ϊ�ߵ�ƽ������
    out dx, al 
    mov al, ah
    out dx, al;�ߵ�λ������д��
    jmp exit2B;
timeout_b3s:
    mov dx,io8255b;
    in al, dx 
    and al, 01h;
    jnz outedB ;3sʱ�䵽
    jmp exit2B
outedB:
    mov state_bx, 0;�Ѿ��뿪����0
    mov FullFlag, 0
     mov checktimeBx,0
    mov dx, io8255ctrl; �صƣ����˹رգ�
    mov al, 00000100b;C��λ�ÿ���,0100: 010ʹ��PC2����0��C �� 2 �ſڶ�Ӧ��B�����ź�)
    out dx, al
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;�ж��Ƿ�ͣ��λ�Ƿ��ѿ�
    jz emptyedB;ͣ�����ѿ�,����
    mov al, empty[0]
    mov ah, empty[1]
    inc ax;ͣ��λ��һ
    aaa;��16���Ƶ���ΪBCD��
    mov empty[0], al;��ǰͣ��λ������ֵ
    mov empty[1], ah
    mov dx, offset String6; ��Ļ��ʾʣ�೵λ
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;��ʾ��λ
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; �س�
    mov dl, 0dh
    mov ah, 02h
    int 21h; ����
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;�ж��Ƿ�ͣ��λ�Ƿ��ѿ�
    jz emptyedB
    jmp exit2B
emptyedB:
    mov EmptyFlag, 1
    mov dx, offset String8; ��Ļ��ʾͣ�����ѿ�
    mov ah, 09h
    int 21h
exit2B : 
    pop dx
    pop ax
    ret
TestB2 endp
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;�������ʾ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LED_show proc near
    ;��λ��ʾ
    mov al,0
    mov dx, io8255a
    out dx,al;ȫ�������
    mov dx, io8255ctrl; 
    mov al, 00000010b;C��λ�ÿ���,0010: 100ʹ��PC1��0��C �� 1 �ſڶ�Ӧ�������ʮλ�ź�)
    out dx, al
    mov al, 00000001b;C��λ�ÿ���,0001: 100ʹ��PC0��1��C �� 0 �ſڶ�Ӧ������ܸ�λ�ź�)
    out dx, al
    mov ah, 0
    mov al, 1
    mov si,ax
    mov al, empty[si];ȡ����ܸ�λ
    mov si,ax
    mov al, LED[si];ȡ���������߶���
    mov dx, io8255a; A �����
    out dx, al
    mov cx, 3000h
LED_delay:    
    loop LED_delay; ��ʱ
    ;ʮλ��ʾ
    mov al,0
    mov dx, io8255a
    out dx,al;ȫ�������  
    mov dx, io8255ctrl; 
    mov al, 00000000b;C��λ�ÿ���,0000: 000ʹ��PC0��0��C �� 0 �ſڶ�Ӧ������ܸ�λ�ź�)
    out dx, al
    mov al, 00000011b;C��λ�ÿ���,0011: 001ʹ��PC1��1��C �� 1 �ſڶ�Ӧ�������ʮλ�ź�)
    out dx, al
    mov ah, 0
    mov al, 0
    mov si,ax
    mov al, empty[si];ȡ����ܸ�λ
    mov si,ax
    mov al, LED[si];ȡ���������߶���
    mov dx, io8255a; A �����
    out dx, al
    mov cx, 3000h
LED_delay1:    
    loop LED_delay1; ��ʱ
    ret
LED_show endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;8X8 �������ʾ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Arrow_show proc near
    push si
    push ax
    push cx
    push dx
    mov al, state_a 
    test al, 02h; 2 ��־״̬�У�
    jnz ledin ;���־λZFΪ0��˵��al = 02h;
    mov al, state_ax
    test al, 02h; 2 ��־״̬�У�
    jnz ledoutx ;���־λZFΪ0��˵��al = 02h;

    mov al, state_b;���b��
    test al, 02h 
    jnz ledin
    mov al, state_bx;���b��
    test al, 02h 
    jnz ledoutx
    test FullFlag,1
    jnz ledfullx
    test EmptyFlag,1
    jnz ledemptyxx
    ;������������ֹ��ʾ
    mov cx, 08h;ÿѭ��һ�ε���һ��
    mov si, 0;
    mov ah, 01 
;��ֹ�ź�
loop_no:
    mov dx, red
    mov al, 00h 
    out dx, al;��ѡϨ��
    mov dx, green;
    out dx, al ;��ѡϨ��
    mov dx, row;��ѡ
    mov al, forbid[si];ѡ��ǰ����ѡ�ź�
    out dx,al ;���
    mov dx,red ;��ѡ
    mov al,ah;
    out dx,al 
    shl ah,01;����������
    push cx 
    mov cx,3000 
delay2: 
    loop delay2 
    pop cx 
    inc si ;��ʾ��һ��
    loop loop_no 
    jmp exit7 
 ledemptyxx:
    jmp ledemptyx
;�����ź�
ledin: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_in:
    mov dx,red  ;��ѡ
    mov al,00h 
    out dx,al 
    mov dx,green  ;��ѡ
    out dx,al 
    mov dx,row ;��ѡ
    mov al,arrow_in[si] 
    out dx,al 
    mov dx,green  ;��ѡ
    mov al,ah ; 01h 
    out dx,al 
    shl ah,01 ; 
    push cx 
    mov cx,3000 
delay3: 
    loop delay3 
    pop cx 
    inc si 
    loop loop_in 
    jmp exit7
 ledoutx:
    jmp ledout   
ledfullx:
    jmp ledfull
 ledemptyx:
    jmp ledempty   
; �뿪�ź�
ledout: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_out: 
    mov dx,red ;��ѡ
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; ��ѡ
    mov al, arrow_out[si]
    out dx, al 
    mov dx, green; ��ѡ
    mov al, ah 
    out dx, al
    shl ah, 01
    push cx 
    mov cx, 3000
delay4 :
    loop delay4 
    pop cx
    inc si 
    loop loop_out
    jmp exit7
exit7 : 
    pop dx
    pop cx 
    pop ax
    pop si
    ret 
  
    ; �뿪�ź�
ledfull: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_full: 
    mov dx,red ;��ѡ
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; ��ѡ
    mov al, whole[si]
    out dx, al 
    mov dx, red; ��ѡ
    mov al, ah 
    out dx, al
    shl ah, 01
    push cx 
    mov cx, 3000
delay4_ :
    loop delay4_ 
    pop cx
    inc si 
    loop loop_full
    jmp exit7_
exit7_ : 
    pop dx
    pop cx 
    pop ax
    pop si
    ret 
        ; �뿪�ź�
ledempty: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_empty: 
    mov dx,red ;��ѡ
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; ��ѡ
    mov al, whole[si]
    out dx, al 
    mov dx, green; ��ѡ
    mov al, ah 
    out dx, al
    shl ah, 01
    push cx 
    mov cx, 3000
delay4_x :
    loop delay4_x
    pop cx
    inc si 
    loop loop_empty
    jmp exit7_x
exit7_x : 
    pop dx
    pop cx 
    pop ax
    pop si
    ret 
Arrow_show endp
code ends
end start