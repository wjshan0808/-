;ASM
;9.9 在屏幕中间分别显示绿色, 绿底红色, 白底蓝色的字符串'welcome to masm!'
;    

assume cs:msCode
  
  msData segment
    db 'welcome to masm!'
    ;第12行0780H, 第13行0820H, 第14行08C0H, 
    ;每行开始写数据的偏移量40H
  msData ends

  msCode segment    
sMain:

    mov ax, msData
    mov ds, ax
    mov ax, 0B800H    ;第一页段
    mov es, ax
    
    ;
    mov di, 00H
    mov si, 00H
    mov cx, 10H
    sLine12:
        mov al, [di + 00H]
        mov es:[si + 00H + 40H + 0780H], al        
        mov byte ptr es:[si + 01H + 40H + 0780H], 02H
        inc di
        add si, 02H
      loop sLine12
      
    ;
    mov di, 00H
    mov si, 00H
    mov cx, 10H
    sLine13:
        mov al, [di + 00H]
        mov es:[si + 00H + 40H + 0820H], al
        mov byte ptr es:[si + 01H + 40H + 0820H], 24H
        inc di
        add si, 02H
      loop sLine13
      
    ;
    mov di, 00H
    mov si, 00H
    mov cx, 10H
    sLine14:
        mov al, [di + 00H]
        mov es:[si + 00H + 40H + 08C0H], al
        mov byte ptr es:[si + 01H + 40H + 08C0H], 71H
        inc di
        add si, 02H
      loop sLine14
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends

end sMain
	
