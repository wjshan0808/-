;ASM
;3.3.8 将10000H~1000FH作为栈空间, 初始状态为空, 将AX=001AH, BX=001BH的数据入栈
;      然后将其数值清零后恢复

assume cs:msCode

  msCode segment
sMain:

    mov ax, 1000H
    mov ss, ax
    mov sp, 0010H ;空栈
    
    mov ax, 001AH
    mov bx, 001BH
    
    push ax ;入栈
    push bx
    
    sub ax, ax  ;sub为2个字节
    sub bx, bx  ;mov为3个字节
    
    pop bx  ;出栈和入栈相反
    pop ax
    
    ;
    ;mov ax, 4c00H
    ;int 21H
    
  msCode ends
	
end sMain
	
