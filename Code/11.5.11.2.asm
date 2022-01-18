;ASM
;11.5.11.2
;
;资料
;

assume cs:msCode
  
  msData segment
    db 10H (00H)
  msData ends
  
  msCode segment    
sMain:
    
                    ;OF   SF   ZF   PF   CF 
    sub al, al      ;NV   PL   ZR   PE   NC
    
    mov al, 10H
    add al, 90H     ;NV   NG   NZ   PE   NC
    
    mov al, 80H
    add al, 80H     ;OV   PL   ZR   PE   CY
    
    mov al, 0FCH
    add al, 05H     ;NV   PL   NZ   PO   CY
    
    mov al, 7DH
    add al, 0BH     ;OV   NG   NZ   PE   NC
    
      
    ;
    mov ax, 4c00H
    int 21H
    
      
  msCode ends

end sMain
	
