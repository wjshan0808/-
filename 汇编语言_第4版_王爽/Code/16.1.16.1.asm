;ASM
;16.1.16.1 将code段中的a处的8个数据累加, 结果存储到b处的双字中
;
;资料
;

assume cs:msCode
  
  msCode segment
    a dw 1,2,3,4,5,6,7,8
    b dd 0
  
sMain:

    mov si, 0
    mov cx, 8
    s:
      mov ax, a[si]               ;mov ax, cs:[si + 00H]
      add word ptr b[00H], ax     ;add word ptr cs:[00H + 10H], ax
      adc word ptr b[02H], 0      ;adc word ptr cs:[02H + 10H], 00H
      add si, 02H
      
      loop s

    ;
    mov ax, 4c00H
    int 21H
    
    
  msCode ends
end sMain
	
