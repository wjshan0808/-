;ASM
;6.5.5 将a段和b段的数据依次相加存入到c段中
;      

assume cs:msCode
	
  a segment
    db 1H, 2H, 3H, 4H, 5H, 6H, 7H, 8H
  a ends
  
  b segment
    db 1H, 2H, 3H, 4H, 5H, 6H, 7H, 8H
  b ends
  
  c segment
    db 0, 0, 0, 0, 0, 0, 0, 0
  c ends

  msCode segment
sMain:

    mov ax, a
    mov ds, ax
    
    mov bx, 00H
    
    mov cx, 08H
    s08:
        mov al, [bx + 00H]
        add al, [bx + 10H]
        mov [bx + 20H], al
        inc bx
      loop s08
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
