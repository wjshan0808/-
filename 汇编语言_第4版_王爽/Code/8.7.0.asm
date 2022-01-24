;ASM
;8.7.0 将段中的数据格式化写入表中, 并计算人均收入
;      

assume cs:msCode, ds:msData
  
  msData segment
    ;年份
    db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982'
    db '1983', '1984', '1985', '1986', '1987', '1988', '1989', '1990'
    db '1991', '1992', '1993', '1994', '1995'
    ;收入
    dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486
    dd 50065, 97479, 140417, 197514, 345980, 590827, 803530, 1183000
    dd 1843000, 2759000, 3753000, 4649000, 5937000
    ;人数
    dw 3, 7, 9, 13, 28, 38, 130, 220
    dw 476, 778, 1001, 1442, 2258, 2793, 4037, 5635
    dw 8226, 11542, 14430, 15257, 17800
  msData ends
  
  msTable segment
    db 21 dup ('year summ ne ?? ')
  msTable ends

  msCode segment
sMain:
    
    mov ax, msData
    mov ds, ax
    
    mov ax, msTable
    mov es, ax
    
    ;
    mov di, 00H
    mov si, 00H
    mov bp, 00H
    
    mov cx, 15H
    sLine:
        
        ;loop[di + 00H]
        mov bl, [di + 00H + 00H]
        mov es:[bp + 00H], bl
        mov bl, [di + 01H + 00H]
        mov es:[bp + 01H], bl
        mov bl, [di + 02H + 00H]
        mov es:[bp + 02H], bl
        mov bl, [di + 03H + 00H]
        mov es:[bp + 03H], bl
        
        ;loop[di + 54H]
        mov ax, [di + 00H + 54H]
        mov es:[bp + 05H], ax
        mov dx, [di + 02H + 54H]
        mov es:[bp + 07H], dx
        
        ;[si + 54H + 54H]
        mov bx, [si + 54H + 54H]
        mov es:[bp + 0aH], bx
        
        div word ptr [si + 54H + 54H]
        mov es:[bp + 0dH], ax
        
        add di, 04H
        add si, 02H
        add bp, 10H
        
      loop sLine
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
