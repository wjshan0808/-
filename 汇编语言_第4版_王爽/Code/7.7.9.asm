;ASM
;7.7.9 将段中的每个单词的前4个字母改为大写字母
;      

assume cs:msCode, ss:msStack, ds:msData
  
  msStack segment
    dw 0, 0, 0, 0, 0, 0, 0, 0
  msStack ends
	
  msData segment
    db '1. display      '
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
  msData ends

  msCode segment
sMain:

    mov ax, msStack
    mov ss, ax
    
    mov ax, msData
    mov ds, ax
    
    mov bx, 00H
    
    mov cx, 04H
    sRow:
        
        push cx
        mov di, 00H
        mov cx, 04H
        sCol:
            mov al, [bx + di + 03H]
            and al, 0DFH
            mov [bx + di + 03H], al
            inc di
          loop sCol
        pop cx
        
        add bx, 10H
      loop sRow
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
