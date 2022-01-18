;ASM
;9.9.2 利用jcxz指令, 实现在2000H段中查找第一个值为0的字节, 将其偏移地址存储在dx中
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
        jcxz sFound0  ;(CX)=0x00 短转移 至 标号
        inc bx        ;增加偏移值 
      jmp short sFind0
      
    sFound0:
      mov dx, bx
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
