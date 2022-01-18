;ASM
;9.8 奇怪的程序
;    Debug:U指令看看每个指令所占字节数, 机器码

assume cs:msCode
  msCode segment
    
    ;
    mov ax, 4c00H       ;03
    int 21H             ;02
    
sMain:
    mov ax, 00H         ;03
    
    s:
      nop               ;01
      nop               ;01
    
    mov di, offset s    ;03 (DI)=08H
    mov si, offset s2   ;03 (SI)=20H
    mov ax, cs:[si]     ;03
    mov cs:[di], ax     ;03 s处的nop被设置为s2处的机器码(2字节)
    
    s0:
      jmp short s       ;02 等价执行s2处的指令, 跳转到第一行指令处
      
    s1:
      mov ax, 00H       ;03 迷
      int 21H           ;02 惑
      mov ax, 00H       ;03 的
      
    s2:
      jmp short s1      ;02 EB F6(-08H)(补码, 取反加一)
      nop               ;01
    
  msCode ends

end sMain
	
