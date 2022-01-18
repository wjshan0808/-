;ASM
;6.5.1-4 段中的数据的实际占有空间(10H倍数)
;      

assume cs:msCode, ds:msData, ss:msStack

  msCode segment
sMain:

    mov ax, msStack
    mov ss, ax
    mov sp, 10H
    
    mov ax, msData
    mov ds, ax
    
    push ds:[0]
    push ds:[2]
    pop ds:[2]
    pop ds:[0]
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
	
  msData segment
    dw 0123H, 0456H;, 0789H, 0abcH, 0defH, 0fedH, 0cbaH, 0987H
  msData ends
  
  msStack segment
    dw 0, 0;, 0, 0, 0, 0, 0, 0
  msStack ends

end; sMain
	
