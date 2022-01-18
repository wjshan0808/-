;ASM
;3.3.7 将10000H~1000FH作为栈空间, 初始状态为空, 将AX, BX, DS中的数据入栈

assume cs:msCode

  msCode segment
sMain:

    mov ax, 1000H
    mov ss, ax
    mov sp, 0010H ;空栈
    
    push ax
    push bx
    push ds
    
    ;
    ;mov ax, 4c00H
    ;int 21H
    
  msCode ends
	
end sMain
	
