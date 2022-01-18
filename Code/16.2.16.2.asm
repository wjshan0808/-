;ASM
;16.2.16.2 将data段中的a处的8个数据累加, 结果存储到b处的字中
;
;资料
;

assume cs:msCode, es:msData

  msData segment
    a db 1,2,3,4,5,6,7,8
    b dw 0
  msData ends
  
  msCode segment
sMain:
    
    mov ax, msData
    mov es, ax                ;assume es:msData

    mov si, 0
    mov cx, 8
    s:
      mov al, a[si]           ;mov ax, es:[si + 00H]
      mov ah, 0
      add b, ax               ;add es:[00H + 08H], ax
      inc si
      
      loop s

    ;
    mov ax, 4c00H
    int 21H
    
    
  msCode ends
end sMain
	
