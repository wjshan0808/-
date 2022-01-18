;ASM
;9.9.1.2 使jmp执行后, CS:IP指向程序的第一条指令
;      

assume cs:msCode
  
  ;占16字节
  msData segment
    dd 12345678H
  msData ends

  msCode segment
sMain:
    
    mov ax, msData
    mov ds, ax
    mov bx, 00H
    
    mov [bx], bx          ;设置(IP)=0x00
    mov [bx + 02H], cs    ;设置(CS)=(CS)
    jmp dword ptr ds:[00H]
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
