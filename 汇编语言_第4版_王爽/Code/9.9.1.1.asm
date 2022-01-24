;ASM
;9.9.1.1 使jmp执行后, CS:IP指向程序的第一条指令, data中应是什么值
;      

assume cs:msCode
  
  ;占16字节
  msData segment
    db 00, 00, 00
  msData ends

  msCode segment
sMain:
    
    mov ax, msData
    mov ds, ax
    mov bx, 00H
    jmp word ptr [bx + 01H] ;设置(IP)=0x00
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
