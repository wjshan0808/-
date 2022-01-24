;ASM
;16.3.1 编写子程序, 以十六进制的形式在屏幕中间显示给定的字节型数据
;
;资料
;     '0'~'9'=30H~39H
;     'A'~'F'=41H~46H
;

assume cs:msCode

  
  msCode segment
sMain:
     

    mov al, cs:[0CH]
    call func_ASCII_Show

    ;
    mov ax, 4c00H
    int 21H
    
    
    func_ASCII_Show:
        push cx
        push bx
        push es
        push di
        push ax
                                  ;暂借寄存器
          
          jmp short sDo_ASCII_Show
          
          ASCII db '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'
          
          sDo_ASCII_Show:      
            mov bx, 0B800H          ;字符显示地址
            mov es, bx
            mov di, (0A0H * 0CH + 40H)
            
            mov bh, 00H
            mov bl, al
            
            and bl, 0FH
            mov bl, ASCII[bx]
            mov es:[di + 02H], bl
            
            mov cl, 04H
            shr al, cl
            mov bl, al
            mov bl, ASCII[bx]
            mov es:[di + 00H], bl
                                  
                                  ;归还寄存器
        pop ax
        pop di
        pop es
        pop bx
        pop cx
      ret
    
  msCode ends
end sMain
	
