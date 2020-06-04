data segment
ioport equ  280h; tpc 卡中设备的 io 地址
io82530 equ 280h; 计数器通道 0 地址
io82531 equ  281h; 计数器通道 1 地址
io82532 equ  282h; 计数器通道 2 地址
io8253ctrl equ 283h; 8253 控制寄存器地址

io8255a equ  288h; 8255A 口地址
io8255b equ  289h; 8255B 口地址
io8255c equ  28ah; 8255C 口地址
io8255ctrl equ  28bh; 8255 控制寄存器端口地址

; 点阵显示
arrow_in db 00h, 18h, 3ch, 7eh, 18h, 18h, 18h, 00h; 箭头进
arrow_out db 00h, 18h, 18h, 18h, 7eh, 3ch, 18h, 00h; 箭头出
forbid db 81h, 42h, 24h, 18h, 18h, 24h, 42h, 81h; 禁止
whole db 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh, 0ffh; 禁止
;LED管
LED db 3fh, 06h, 5bh, 4fh, 66h, 6dh, 7dh, 07h, 7fh, 6fh; LED七段码
row equ  290h; 行选
red equ 298h; 红选
green equ 2a0h; 绿选

;C7、C6、C5、C4对应 A的进出口、B的进出口
;C3、C2对应A、B口栏杆LED小灯
;C1、C0对应数码管的十、个位片选

NUM db 3, 4 dup(0)

waitkey db 3, 4 dup(0) ;调试用

empty db 2 dup(0); 用于存放空闲车位的十位和个位
state_a db 00h; 标志 a 口进状态， 0 表示空闲， 1 表示准备进入， 2 标志正在进入
state_ax db 00h; 标志 a 口状态， 0 表示空闲， 1 表示准备出去， 2 标志正在出去

state_b db 00h; 标志 b 口状态， 0 表示空闲， 1 表示正在进入， 2 标志正在进入
state_bx db 00h; 标志 b 口状态， 0 表示空闲， 1 表示准备出去， 2 标志正在出去

FullFlag db 00h;停车场满标志
EmptyFlag db 00h;停车场空标志

checktimeA db 00h;A口显示进的checking信号激发次数
checktimeB db 00h;B口显示进的checking信号激发次数
checktimeAx db 00h;A口显示出的checking信号激发次数
checktimeBx db 00h;B口显示出的checking信号激发次数


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
    mov ax, data; 初始化寄存器
    mov ds, ax
    mov ax, stacks 
    mov ss, ax 
    
    mov dx, io8255ctrl
    mov al, 10001010b    ; 00 A工作方式 0, 0 输出  数码管的译码
                         ; 1 输入C高位 用于读取开关信号
                         ; 0 B工作方式 0, 1 输入 倒计时结束信号
                         ; 0 输出 C低位,C3、C2用于栏杆的led小灯、C1、C0数码管片选控制
                         
    out dx, al
    mov dx, io8253ctrl; 计数器 0 工作方式 3 方波发生器
    mov al, 00110110b
    out dx, al 
    mov al, 01110000b; 计数器 1，工作方式 0  计数结束高电平
    out dx, al 

    mov dx, io82530    ; 计数器 0 初值 1000(第一次分频)
    mov ax, 1000 
    out dx, al
    mov al, ah 
    out dx, al;两次写入
    
    mov dx, offset Welcome;欢迎界面
    mov ah, 09h
    int 21h
begin : 
    mov dx, offset String1; 执行输入的提示
    mov ah, 09h;    
    int 21h

    mov dx, offset NUM; 输入初始空车位保存到NUM
    mov ah, 0ah
    int 21h 

    mov dl, 0ah 
    mov ah, 02h
    int 21h ; 回车
    mov dl, 0dh
    mov ah, 02h
    int 21h; 换行

    mov al, NUM[2]; 判断输入数值是否符合条件
    sub al, 30h; 将 ASCII 码转换为数字
    cmp al, 0
    jb error
    cmp al, 9
    ja error
    mov empty[1], al;将数字a保存作为LED的十位

    mov al, NUM[3]
    sub al, 30h;
    cmp al, 0; 小于 0 的话就转移到 error
    jb error 
    cmp al, 9; 大于 9 的话就转移到 error
    ja error 
    mov empty[0], al; 将数字b保存作为LED的个位
    jmp main;执行主循环
error:
    mov dx, offset String2;输入错误报错
    mov ah, 09h
    int 21h
    jmp begin
error2:
    mov dx, offset Stringerror;开关按错报错
    mov ah, 09h
    int 21h
; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 
main:         ; 主循环 
    call LED_show  ; 调用数码管显示 
    call Arrow_show; 点阵显示相关图示 

    mov dx, io8255c; 从 8255C 高位读入开关信号
    in al, dx
    and al,0f0h

    ;;;;;;;;;调试用;;;;;;;;;;
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
    jz error2;四个开关全上拉;报错
    pop ax
    push ax
    xor al, 11000000B
    jz error2;A口开关全上拉;报错
    pop ax
    push ax
    xor al, 00110000B
    jz error2;B口开关全上拉;报错
    pop ax
    push ax
    xor al, 00000000B
    jz main
    pop ax
checkA1 :
    test state_ax,2;当前A出信号虽然没了， 但是却还是正在出的状态
    jnz checkA2plus
    test state_b,2; 当前B进信号虽然没了， 但是却还是正在进的状态
    jnz checkB1plus
    test state_bx,2;当前B出信号虽然没了， 但是却还是正在出的状态
    jnz checkB2plus
    test al, 10000000b;检测A口开关1
    jz checkA1plus;
    call TestA1; 否则A号口开关 1 上拉，有车要进入，此时应该检测当前A号口状态
    jmp main  
checkA1plus :
    test state_a,2;当前进信号虽然没了，但是却还是正在进的状态
    jz checkA2
    call TestA1;
    jmp main
checkA2 : 
    test al,01000000b;检测A口开关2
    jz checkA2plus;等于0则检查下一状态
    call TestA2; A号口开关 2 上拉，有车要出去，此时应该检测当前A号口状态
    jmp main
checkA2plus :
    test state_ax,2;当前出信号虽然没了，但是却还是正在出的状态
    jz checkB1
    call TestA2;
    jmp main

Tomain:
    jmp main

checkB1 :
    test al, 00100000b;检测B口开关1
    jz checkB1plus;等于0;当前开关未上拉, 则检查下一开关
    call TestB1; 否则B号口开关 1 上拉，有车要进入，此时应该检测当前B号口状态
    jmp Tomain  
checkB1plus :
    test state_b,2;当前进信号虽然没了，但是却还是正在进的状态
    jz checkB2
    call TestB1;
    jmp Tomain
checkB2 : 
    test al,00010000b;检测B口开关2
    jz checkB2plus;等于0则检查下一状态
    call TestB2; B号口开关 2 上拉，有车要出去，此时应该检测当前B号口状态
    jmp Tomain
checkB2plus :
    test state_bx,2;当前进信号虽然没了，但是却还是正在进的状态
    jz Tomain
    call TestB2;
    jmp Tomain                                                
exit : 
    mov ah, 4ch ;退出总程序
    int 21h
;;;;;;;;;;;;;;;;;;;;A口开关1上拉，检测A口状态;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestA1 proc near 
    push ax ;保护现场
    push dx; 
    mov state_ax, 0; A口出信号置0
    mov state_b,  0; B口进信号置0        防止上一过程信号无效时状态停留在1，即未结束
    mov state_bx, 0; B口出信号置0    
    mov checktimeAx,00h;
    mov checktimeB,00h;
    mov checktimeBx,00h;

    cmp state_a, 0; 
    jz state_A1; 等于0,停车场处于空闲状态，进行倒计时2s赋值
    cmp state_a, 1;状态1
    jz timein_a2s;为状态1，有车准备进，检测倒计时2s是否结束
    cmp state_a, 2;状态2,有车正在进，检测倒计时1s是否结束
    jz timein_a1s
    jmp exit1;退出
;;;;;;;;;;;;;;;;;;;;;;;当前为0，置A口状态1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
state_A1 : 
    mov dx, offset String3; 提示有车准备从A进入
    mov ah, 09h
    int 21h
    test FullFlag,1
    jnz fulljmp 
    jmp contjudgeA
fulljmp:
    mov dx, offset String7;显示已满
    mov ah, 09h
    int 21h;
    pop ax
    pop dx 
    ret
contjudgeA:
    mov state_a, 1;  置为状态1
    mov dx, io82531; 
    mov ax, 2000;第二次分频产生周期为2s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit1;跳出A口开关1检测,检测B口开关1
;;;;;;;;;;;;;;;;;;;检测A口2s倒计时,结束置A口状态为2;;;;;;;;;;;;;;;;;;;;;;
timein_a2s : 
    mov dx, io8255b;
    in al, dx 
    test al,01h
    jnz enterance ;2s时间到
    and checktimeA,1
    jnz exit1plus
    mov dx, offset String4;2s倒计时未到，提醒正在检测身份
    mov ah, 09h
    int 21h
    mov checktimeA,1;保证只显示一次checking语句
exit1plus:
    pop dx;因为exit1太远了
    pop ax 
    ret
enterance: 
    mov dx, offset String5;2s倒计时到，提醒栏杆已经打开
    mov ah, 09h
    int 21h
    mov state_a, 2;正在进入，准备开始1s倒计时
    mov dx, io8255ctrl; 开灯（栏杆打开）
    mov al, 00000111b;C按位置控制,0111: 011使得PC3口置1；C 的 3 号口对应于A栏杆信号)
    out dx, al
    mov dx, io82531; 
    mov ax, 1000;第二次分频产生周期为1s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit1;跳出A口开关1检测,检测B口开关1
;;;;;;;;;;;;;;;;;;;检测A口1s倒计时,结束置A口状态为2;;;;;;;;;;;;;;;;;;;;;;
timein_a1s : 
    mov dx, io8255b;
    in al, dx 
    test al, 01h;
    jnz entered ;1s时间到
    jmp exit1
entered : 
    mov state_a, 0;已经进入，置0
    mov EmptyFlag, 0

    mov checktimeA,00h;语句checking次数重新置0
    mov dx, io8255ctrl; 关灯（栏杆关闭）
    mov al, 00000110b;C按位置控制,0110: 011使得PC3口置0；C 的 3 号口对应于A栏杆信号)
    out dx, al
    mov al, empty[0];1s时间到，停车位减一
    mov ah, empty[1]
    cmp ax, 0;判断是否停车位是否已满
    jz fulled;停车场满了,返回
    cmp al,0
    jnz aldec
    sub ax,10
    mov al,0Ah
aldec:
    sub ax, 1;停车位减一
    mov empty[0], al;当前停车位数量赋值
    mov empty[1], ah
    mov dx, offset String6; 屏幕显示剩余车位
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示高位
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示低位
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; 回车
    mov dl, 0dh
    mov ah, 02h
    int 21h; 换行
    mov al, empty[0];1s时间到，停车位减一
    mov ah, empty[1]
    cmp ax, 0;判断是否停车位是否已满
    jz fulled;停车场满了,返回
    jmp exit1
fulled:
    mov FullFlag, 1
    mov dx, offset String7;显示已满
    mov ah, 09h
    int 21h;
exit1:
    pop dx
    pop ax 
    ret
TestA1 endp
;;;;;;;;;;;;;;;;;;;;;A口开关2上拉，检测A口状态,1s倒计时结束则置A口状态为3;;;;;;;;;;;;;;;;;;;;;;;;;;; 
TestA2 proc near
    push ax
    push dx 
    mov state_a, 0; A口出信号置0
    mov state_b,  0; B口进信号置0        防止上一过程未结束
    mov state_bx, 0; B口出信号置0    
    mov checktimeA,00h;
    mov checktimeB,00h;
    mov checktimeBx,00h;

    cmp state_ax, 0
    jz stateout_a1;A口状态为0,说明前面无车
    cmp state_ax,1
    jz timeout_a1s;A口状态为1,说明准备出行
    cmp state_ax,2
    jz timeout_a3s;A口状态为2,说明正在出行
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
    mov dx, offset String10; 提示有车准备从A离开
    mov ah, 09h
    int 21h
    mov state_ax, 1;置A口为1
    mov dx, io82531;开始分频1s
    mov ax,1000;第二次分频产生周期为1s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah 
    out dx, al;分高低位写入
    jmp exit2
timeout_a1s:
    mov dx, io8255b;
    in al, dx 
    and al, 01h;
    jnz outrance ;1s时间到
    and checktimeAx,1
    jnz exit2plus
    mov dx, offset String4;显示正在查询
    mov ah, 09h
    int 21h;
    mov checktimeAx,1
exit2plus:
    pop dx;因为exit2太远了
    pop ax 
    ret
outrance:
    mov dx, offset String9;显示栏杆已经打开
    mov ah, 09h
    int 21h;
    mov state_ax, 2;正在出行，准备开始3s倒计时
    mov dx, io8255ctrl; 开灯（栏杆打开）
    mov al,00000111b;C按位置控制,0101: 010使得PC2口置1；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov dx, io82531; 
    mov ax, 3000;第二次分频产生周期为2s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit2;
timeout_a3s:
    mov dx,io8255b;
    in al, dx 
    and al, 01h;
    jnz outed ;3s时间到
    jmp exit2
outed:
    mov state_ax, 0;已经离开，置0
    mov FullFlag, 0
      mov checktimeAx,0
    mov dx, io8255ctrl; 关灯（栏杆关闭）
    mov al, 00000110b;C按位置控制,0100: 010使得PC2口置0；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;判断是否停车位是否已空
    jz emptyed;停车场已空,返回
    mov al, empty[0]
    mov ah, empty[1]
    inc ax;停车位加一
    aaa;将16进制调整为BCD码
    mov empty[0], al;当前停车位数量赋值
    mov empty[1], ah
    mov dx, offset String6; 屏幕显示剩余车位
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示高位
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示低位
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; 回车
    mov dl, 0dh
    mov ah, 02h
    int 21h; 换行
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;判断是否停车位是否已空
    jz emptyed
    jmp exit2
emptyed:
    mov EmptyFlag, 1
    mov dx, offset String8; 屏幕显示停车场已空
    mov ah, 09h
    int 21h
exit2 : 
    pop dx
    pop ax
    ret
TestA2 endp


;;;;;;;;;;;;;;;;;;;;A口开关1上拉，检测A口状态;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestB1 proc near 
    push ax ;保护现场
    push dx; 
    mov state_a, 0; A口出信号置0
    mov state_ax, 0; A口出信号置0        防止上一过程信号无效时状态停留在1，即未结束
    mov state_bx, 0; B口出信号置0    
    mov checktimeA,00h;
    mov checktimeAx,00h;
    mov checktimeBx,00h;
    

    cmp state_b, 0; 
    jz state_B1; 等于0,停车场处于空闲状态，进行倒计时2s赋值
    cmp state_b, 1;状态1
    jz timein_b2s;为状态1，有车准备进，检测倒计时2s是否结束
    cmp state_b, 2;状态2,有车正在进，检测倒计时1s是否结束
    jz timein_b1s
    jmp exit1B;退出
;;;;;;;;;;;;;;;;;;;;;;;当前为0，置B口状态1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
state_B1 : 
    mov dx, offset String11; 提示有车准备从B进入
    mov ah, 09h
    int 21h
    test FullFlag,1
    jnz fulljmpB 
    jmp contjudgeB
fulljmpB:
    mov dx, offset String7;显示已满
    mov ah, 09h
    int 21h;
    pop ax
    pop dx 
    ret
contjudgeB:
    mov state_b, 1;  置为状态1
    mov dx, io82531; 
    mov ax, 2000;第二次分频产生周期为2s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit1B;跳出A口开关1检测,检测B口开关1
;;;;;;;;;;;;;;;;;;;检测B口2s倒计时,结束置B口状态为2;;;;;;;;;;;;;;;;;;;;;;
timein_b2s : 
    mov dx, io8255b;
    in al, dx 
    test al,01h
    jnz enteranceB ;2s时间到
    and checktimeB,1
    jnz exit1plusB
    mov dx, offset String4;2s倒计时未到，提醒正在检测身份
    mov ah, 09h
    int 21h
    mov checktimeB,1;保证只显示一次checking语句
exit1plusB:
    pop dx;因为exit1太远了
    pop ax 
    ret
enteranceB: 
    mov dx, offset String5;2s倒计时到，提醒栏杆已经打开
    mov ah, 09h
    int 21h
    mov state_b, 2;正在进入，准备开始1s倒计时
    mov dx, io8255ctrl; 开灯（栏杆打开）
    mov al, 00000101b;C按位置控制,0101: 010使得PC2口置1；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov dx, io82531; 
    mov ax, 1000;第二次分频产生周期为1s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit1B;跳出A口开关1检测,检测B口开关1
;;;;;;;;;;;;;;;;;;;检测B口1s倒计时,结束置B口状态为2;;;;;;;;;;;;;;;;;;;;;;
timein_b1s : 
    mov dx, io8255b;
    in al, dx 
    test al, 01h;
    jnz enteredB ;1s时间到
    jmp exit1
enteredB : 
    mov state_b, 0;已经进入，置0
    mov EmptyFlag, 0
    mov checktimeB,00h;语句checking次数重新置0
    mov dx, io8255ctrl; 关灯（栏杆关闭）
    mov al, 00000100b;C按位置控制,0101: 010使得PC2口置0；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov al, empty[0];1s时间到，停车位减一
    mov ah, empty[1]
    cmp ax, 0;判断是否停车位是否已满
    jz fulledB;停车场满了,返回
    cmp al,0
    jnz aldecB
    sub ax,10
    mov al,0Ah
aldecB:
    sub ax, 1;停车位减一
    mov empty[0], al;当前停车位数量赋值
    mov empty[1], ah
    mov dx, offset String6; 屏幕显示剩余车位
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示高位
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示低位
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; 回车
    mov dl, 0dh
    mov ah, 02h
    int 21h; 换行
    mov al, empty[0];1s时间到，停车位减一
    mov ah, empty[1]
    cmp ax, 0;判断是否停车位是否已满
    jz fulledB;停车场满了,返回
    jmp exit1
fulledB:
    mov FullFlag, 1
    mov dx, offset String7;显示已满
    mov ah, 09h
    int 21h;
exit1B:
    pop dx
    pop ax 
    ret
TestB1 endp
;;;;;;;;;;;;;;;;;;;;;B口开关2上拉，检测B口状态,1s倒计时结束则置A口状态为3;;;;;;;;;;;;;;;;;;;;;;;;;;; 
TestB2 proc near
    push ax
    push dx 
    mov state_a, 0; A口出信号置0
    mov state_ax, 0; A口出信号置0
    mov state_b,  0; B口进信号置0        防止上一过程未结束   
    mov checktimeA,00h;
    mov checktimeAx,00h;
    mov checktimeB,00h;
    

    cmp state_bx, 0
    jz stateout_b1;B口状态为0,说明前面无车
    cmp state_bx,1
    jz timeout_b1s;B口状态为1,说明准备出行
    cmp state_bx,2
    jz timeout_b3s;B口状态为2,说明正在出行
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
    mov dx, offset String12; 提示有车准备从B离开
    mov ah, 09h
    int 21h
    mov state_bx, 1;置A口为1
    mov dx, io82531;开始分频1s
    mov ax,1000;第二次分频产生周期为1s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah 
    out dx, al;分高低位写入
    jmp exit2B
timeout_b1s:
    mov dx, io8255b;
    in al, dx 
    and al, 01h;
    jnz outranceB ;1s时间到
    and checktimeBx,1
    jnz exit2plusB
    mov dx, offset String4;显示正在查询
    mov ah, 09h
    int 21h;
    mov checktimeBx,1
exit2plusB:
    pop dx;因为exit2太远了
    pop ax 
    ret
outranceB:
    mov dx, offset String9;显示栏杆已经打开
    mov ah, 09h
    int 21h;
    mov state_bx, 2;正在出行，准备开始3s倒计时
    mov dx, io8255ctrl; 开灯（栏杆打开）
    mov al,00000101b;C按位置控制,0101: 010使得PC2口置1；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov dx, io82531; 
    mov ax, 3000;第二次分频产生周期为2s的最后一次为高电平的脉冲
    out dx, al 
    mov al, ah
    out dx, al;高低位分两次写入
    jmp exit2B;
timeout_b3s:
    mov dx,io8255b;
    in al, dx 
    and al, 01h;
    jnz outedB ;3s时间到
    jmp exit2B
outedB:
    mov state_bx, 0;已经离开，置0
    mov FullFlag, 0
     mov checktimeBx,0
    mov dx, io8255ctrl; 关灯（栏杆关闭）
    mov al, 00000100b;C按位置控制,0100: 010使得PC2口置0；C 的 2 号口对应于B栏杆信号)
    out dx, al
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;判断是否停车位是否已空
    jz emptyedB;停车场已空,返回
    mov al, empty[0]
    mov ah, empty[1]
    inc ax;停车位加一
    aaa;将16进制调整为BCD码
    mov empty[0], al;当前停车位数量赋值
    mov empty[1], ah
    mov dx, offset String6; 屏幕显示剩余车位
    mov ah, 09h
    int 21h
    mov dl, empty[1]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示高位
    mov dl, empty[0]
    add dl, 30h
    mov ah, 02h
    int 21h ;显示低位
    mov dl, 0ah 
    mov ah, 02h
    int 21h ; 回车
    mov dl, 0dh
    mov ah, 02h
    int 21h; 换行
    mov al, empty[0]
    mov ah, empty[1]
    xor ax, 0909h;判断是否停车位是否已空
    jz emptyedB
    jmp exit2B
emptyedB:
    mov EmptyFlag, 1
    mov dx, offset String8; 屏幕显示停车场已空
    mov ah, 09h
    int 21h
exit2B : 
    pop dx
    pop ax
    ret
TestB2 endp
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;数码管显示;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LED_show proc near
    ;个位显示
    mov al,0
    mov dx, io8255a
    out dx,al;全灭数码管
    mov dx, io8255ctrl; 
    mov al, 00000010b;C按位置控制,0010: 100使得PC1置0；C 的 1 号口对应于数码管十位信号)
    out dx, al
    mov al, 00000001b;C按位置控制,0001: 100使得PC0置1；C 的 0 号口对应于数码管个位信号)
    out dx, al
    mov ah, 0
    mov al, 1
    mov si,ax
    mov al, empty[si];取数码管各位
    mov si,ax
    mov al, LED[si];取各个数的七段码
    mov dx, io8255a; A 口输出
    out dx, al
    mov cx, 3000h
LED_delay:    
    loop LED_delay; 延时
    ;十位显示
    mov al,0
    mov dx, io8255a
    out dx,al;全灭数码管  
    mov dx, io8255ctrl; 
    mov al, 00000000b;C按位置控制,0000: 000使得PC0置0；C 的 0 号口对应于数码管个位信号)
    out dx, al
    mov al, 00000011b;C按位置控制,0011: 001使得PC1置1；C 的 1 号口对应于数码管十位信号)
    out dx, al
    mov ah, 0
    mov al, 0
    mov si,ax
    mov al, empty[si];取数码管各位
    mov si,ax
    mov al, LED[si];取各个数的七段码
    mov dx, io8255a; A 口输出
    out dx, al
    mov cx, 3000h
LED_delay1:    
    loop LED_delay1; 延时
    ret
LED_show endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;8X8 矩阵灯显示;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Arrow_show proc near
    push si
    push ax
    push cx
    push dx
    mov al, state_a 
    test al, 02h; 2 标志状态中，
    jnz ledin ;零标志位ZF为0，说明al = 02h;
    mov al, state_ax
    test al, 02h; 2 标志状态中，
    jnz ledoutx ;零标志位ZF为0，说明al = 02h;

    mov al, state_b;检测b口
    test al, 02h 
    jnz ledin
    mov al, state_bx;检测b口
    test al, 02h 
    jnz ledoutx
    test FullFlag,1
    jnz ledfullx
    test EmptyFlag,1
    jnz ledemptyxx
    ;都不是则进入禁止显示
    mov cx, 08h;每循环一次点亮一列
    mov si, 0;
    mov ah, 01 
;禁止信号
loop_no:
    mov dx, red
    mov al, 00h 
    out dx, al;红选熄灭
    mov dx, green;
    out dx, al ;绿选熄灭
    mov dx, row;行选
    mov al, forbid[si];选择当前的列选信号
    out dx,al ;输出
    mov dx,red ;红选
    mov al,ah;
    out dx,al 
    shl ah,01;？？？？？
    push cx 
    mov cx,3000 
delay2: 
    loop delay2 
    pop cx 
    inc si ;显示下一行
    loop loop_no 
    jmp exit7 
 ledemptyxx:
    jmp ledemptyx
;进入信号
ledin: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_in:
    mov dx,red  ;红选
    mov al,00h 
    out dx,al 
    mov dx,green  ;绿选
    out dx,al 
    mov dx,row ;行选
    mov al,arrow_in[si] 
    out dx,al 
    mov dx,green  ;绿选
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
; 离开信号
ledout: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_out: 
    mov dx,red ;红选
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; 行选
    mov al, arrow_out[si]
    out dx, al 
    mov dx, green; 绿选
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
  
    ; 离开信号
ledfull: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_full: 
    mov dx,red ;红选
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; 行选
    mov al, whole[si]
    out dx, al 
    mov dx, red; 绿选
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
        ; 离开信号
ledempty: 
    mov cx,08h 
    mov si,0 
    mov ah,01 
loop_empty: 
    mov dx,red ;红选
    mov al, 00h
    out dx, al
    mov dx, green
    out dx, al 
    mov dx, row; 行选
    mov al, whole[si]
    out dx, al 
    mov dx, green; 绿选
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