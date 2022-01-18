;ASM
;13.4-7 BIOS中断例程应用
; 

assume cs:msCode

  msData segment
    db 'Welcome to masm', '$'
  msData ends
  
  msCode segment
sMain:
    
    mov ah, 02      ;置光标
    mov bh, 00H     ;第0页
    mov dh, 05H     ;dh中放行号
    mov dl, 0CH     ;dl中放列号
    
    int 10H
    
    mov ax, msData
    mov ds, ax
    mov dx, 00H
    
    mov ah, 09H
    int 21H
    
    ;mov ah, 09H      ;在光标位置显示字符
    ;mov al, 'a'      ;字符
    ;mov bl, 0CAH     ;颜色
    ;mov bh, 00H      ;第0页
    ;mov cx, 03H      ;字符重复个数
    ;
    ;int 10H
      
    ;
    mov ax, 4c00H
    int 21H
    
    
  msCode ends
end sMain
	
