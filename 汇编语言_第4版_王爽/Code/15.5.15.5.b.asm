;ASM
;15.5.15.5.b 安装int9号中断例程, 按下F1键后改变屏幕的颜色, 其他的键正常处理
;
;资料
;

assume cs:msCode
  
  msStack segment
    db 80H dup (00H)
  msStack ends
  
  msCode segment
sMain:
    
    mov ax, msStack
    mov ss, ax
    mov sp, 80H
    
    push cs
    pop ds
    
    mov ax, 00H
    mov es, ax
    
    mov si, offset func_Screen_Int9
    mov di, 0204H
    mov cx, offset sEnd_Screen_Int9 - offset func_Screen_Int9
    cld
    rep movsb
    
    push es:[09H * 04H + 00H]
    pop es:[200H]
    push es:[09H * 04H + 02H]
    pop es:[202H]
    
    cli
    mov word ptr es:[09H * 04H + 00H], 204H
    mov word ptr es:[09H * 04H + 02H], 0000H
    sti
    
    mov ax, 4c00H
    int 21H
    
    ;
    func_Screen_Int9:
        push ax
        push bx
        push cx
        push es
        
          in al, 60H
          
          pushf
          call dword ptr cs:[200H]
          
          cmp al, 3BH
          jne sDone_Screen_Int9
          
          mov ax, 0B800H
          mov es, ax
          mov bx, 01H
          mov cx, 07D0H
          sBColor_Screen_Int9:
              inc byte ptr es:[bx]
              add bx, 02H
            loop sBColor_Screen_Int9
        
          sDone_Screen_Int9:
        
        pop es
        pop cx
        pop bx
        pop ax
      iret
      
    sEnd_Screen_Int9:
      nop
    
  msCode ends
end sMain
	
