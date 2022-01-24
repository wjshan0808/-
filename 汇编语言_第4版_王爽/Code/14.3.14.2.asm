;ASM
;14.3.14.2 用加法和移位指令计算(AX)=(AX)*10
;
;资料
;     (AX)*10=(AX)*2 + (AX)*8
;

assume cs:msCode
  
  msCode segment
sMain:
    
    mov bx, ax
    
    shl ax, 01H         ;*2    
    
    mov cl, 03H         ;*8
    shl bx, cl
    
    mov ax, bx
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
end sMain
	
