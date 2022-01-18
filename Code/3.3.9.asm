;ASM
;3.3.9 将10000H~1000FH作为栈空间, 初始状态为空, 设置AX=001AH, BX=001BH的数据
;      然后将其数值交换

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
        
    pop ax  ;交换
    pop bx
    
    ;
    ;mov ax, 4c00H
    ;int 21H
    
  msCode ends
	
end sMain
	
