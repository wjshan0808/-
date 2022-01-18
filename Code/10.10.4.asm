;ASM
;10.10.4 程序执行后ax的值
;    

assume cs:msCode
  
  msCode segment    
sMain:

    mov ax, 06
    call ax     ;push ip=(05)
    inc ax
    mov bp, sp  ;ss:sp=(05)
    add ax, [bp]
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
