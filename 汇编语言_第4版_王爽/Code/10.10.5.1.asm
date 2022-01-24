;ASM
;10.10.5.1 程序执行后ax的值
;    

assume cs:msCode
  
  msStack segment
    dw 08H dup (00H)
  msStack ends
  
  msCode segment    
sMain:

    mov ax, msStack
    mov ss, ax
    mov sp, 10H
    mov ds, ax
    mov ax, 00H
    call word ptr ds:[0eH]    ;push ip = (1. inc ax) = ds:[0eH] = jmp word ptr ds:[0eH]
    inc ax
    inc ax
    inc ax
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
