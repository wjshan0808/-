;ASM
;5.4.1-2 向内存0:200~0:23F依次传送数据0~63(3FH)
;        程序中只能使用9条指令

assume cs:msCode

  msCode segment
sMain:

    mov ax, 20H
    mov ds, ax
    mov bx, 00H

    mov cx, 40H
    s40:
        mov ds:[bx], bl
        inc bl
      loop s40
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
	
end sMain
	
