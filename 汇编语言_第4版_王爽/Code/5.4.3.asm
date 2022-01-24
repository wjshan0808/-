;ASM
;5.4.3 将 mov ax, 4c00H 之前的指令复制到内存0:200处
;      

assume cs:msCode

  msCode segment
sMain:

    mov ax, cs  ;CS段为程序的地址
    mov ds, ax
    mov ax, 0020H
    mov es, ax
    mov bx, 0
    
    mov cx, 17H  ;Debug R-U看程序总长度(cx存放程序长度 - 最后两个指令的长度)
    sCX_2:
        mov al, [bx]
        mov es:[bx], al
        inc bx
      loop sCX_2
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
	
end sMain
	
