;ASM
;2.1.2 最多4条指令, 计算2的4次方

assume cs:msCode

  msCode segment
sMain:

    mov ax, 02H
    add ax, ax
    add ax, ax
    add ax, ax
    
    ;
    ;mov ax, 4c00H
    ;int 21H
    
  msCode ends
	
end sMain
	
