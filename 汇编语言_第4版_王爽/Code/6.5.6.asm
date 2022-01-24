;ASM
;6.5.6 用push指令将a段的前8个字型数据逆序存储到b段中
;      

assume cs:msCode
	
  a segment
    dw 01H, 02H, 03H, 04H, 05H, 06H, 07H, 08H, 09H, 0aH, 0bH, 0cH, 0dH, 0eH, 0fH, 0ffH
  a ends
  
  b segment
    dw 0, 0, 0, 0, 0, 0, 0, 0
  b ends

  msCode segment
sMain:

    mov ax, a
    mov ds, ax
    
    mov ax, b
    mov ss, ax
    mov sp, 10H ;栈空
    
    mov bx, 00H
    
    mov cx, 08H
    s08:
        push [bx]
        add bx, 02H
      loop s08
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
