;ASM
;10.10.5.2 程序执行后ax的值
;    

assume cs:msCode
  
  msData segment
    dw 08H dup (00H)
  msData ends
  
  msCode segment    
sMain:

    mov ax, msData
    mov ss, ax
    mov sp, 10H
    mov word ptr ss:[00H], offset sFlag   ;sFlag处地址
    mov ss:[02H], cs
    call dword ptr ss:[00H]
    nop
    
    sFlag:
      mov ax, offset sFlag
      sub ax, ss:[0cH]
      mov bx, cs
      sub bx, ss:[0eH]
      
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
