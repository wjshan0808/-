;ASM
;9.9.3 利用loop指令, 实现在2000H段中查找第一个值为0的字节, 将其偏移地址存储在dx中
;      

assume cs:msCode
  
  msData segment
  msData ends

  msCode segment
sMain:
    
    mov ax, 2000H
    mov ds, ax
    mov bx, 00H
    
    sFind0:
        mov cl, [bx]  ;设置(CX)字节值
        mov ch, 00H   ;
        inc cx        ;中和loop指令
        inc bx        ;增加偏移值 
      loop sFind0
      
    sFound0:
      dec bx
      mov dx, bx
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
