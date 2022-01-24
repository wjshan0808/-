;ASM
;11.3.11.1
;
;资料
;

assume cs:msCode
  
  msData segment
    db 10H (00H)
  msData ends
  
  msCode segment    
sMain:
    
                    ;ZF   PF    SF     
    sub al, al      ;ZR   PE    PL
    mov al, 01H     ;-
    push ax         ;-
    pop bx          ;-
    add al, bl      ;NZ   PO    PL
    add al, 0AH     ;NZ   PE    PL
    mul al          ;NZ   PE    PL
    
      
    ;
    mov ax, 4c00H
    int 21H
    
      
  msCode ends

end sMain
	
