;ASM
;15.4.15.1-2.b 在屏幕中间依次显示a~z, 在显示的过程中按下Esc键后改变显示的颜色
;
;资料
;

assume cs:msCode

  msStack segment
    db 80H dup (00H)
  msStack ends
  
  msData segment
    dw 0000H, 0000H
  msData ends
  
  msCode segment
sMain:

    mov ax, msStack
    mov ss, ax
    mov sp, 80H                           ;栈顶
    
    mov ax, msData                        ;中断向量段
    mov ds, ax
    
    mov ax, 00H
    mov es, ax
    
    push es:[09H * 04H + 00H]             ;保存原始9号中断ip值
    pop ds:[00H + 00H]
    push es:[09H * 04H + 02H]             ;保存原始9号中断cs值
    pop ds:[00H + 02H]
      
                                          ;设置模拟9号中断ip值
      mov word ptr es:[09H * 04H + 00H], offset func_Simulate_Call_Int9
      mov es:[09H * 04H + 02H], cs        ;设置模拟9号中断cs值

      mov ax, 0B800H                      ;字符显示地址
      mov es, ax
      
      mov ah, 'a'
      sChars:
        mov es:[0A0H * 0CH + 50H], ah     ;显示字符
        ;add di, 02H
        call func_Sleep
        inc ah                            ;下一字符
        cmp ah, 'z'
        jna sChars
      
    
    mov ax, 00H
    mov es, ax
    push ds:[00H + 00H]
    pop es:[09H * 04H + 00H]              ;恢复原始9号中断ip值
    push ds:[00H + 02H]
    pop es:[09H * 04H + 02H]              ;恢复原始9号中断cs值
    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_Simulate_Call_Int9:
        push ax
        push bx
        push es
                                          ;暂借寄存器
            
          in al, 60H                      ;读取键盘扫描码
            
          pushf                           ;保存标志寄存器
          
                                          ;进入中断例程后, IF和TF都已置0
          pushf                           ;准备设置标志寄存器9,8位
          pop bx
          and bh, 0FCH                    ;设置(IF)=0,(TF)=0
          push bx
          popf                            ;将设置的值送入标志寄存器
          
                                          ;push cs, push ip
          call dword ptr ds:[00H]         ;设置cs:ip=原始9号中断例程入口地址, 处理硬件细节
            
          cmp al, 01H                     ;与Esc键通码比较
          jne sEnd_Simulate_Call_Int9
          
          mov ax, 0B800H                  ;字符显示地址
          mov es, ax
          inc byte ptr es:[0A0H * 0CH + 50H +01H]
        
          sEnd_Simulate_Call_Int9:
            
                                          ;归还寄存器
        pop es
        pop bx
        pop ax
      iret                                ;中断调用的返回
    
    ;
    func_Sleep:
        push ax
        push dx
                                          ;暂借寄存器
        
          mov dx, 10H
          mov ax, 00H
          sDo_Sleep:
                                          ;执行
            sub ax, 01H                   ;*08000H
            sbb dx, 00H                   ;*10H
            
            cmp ax, 00H
            jne sDo_Sleep                 ;ax!=0
            cmp dx, 00H
            jne sDo_Sleep                 ;dx!=0
            
                                          ;归还寄存器
        pop dx
        pop ax
      ret
      
  msCode ends
end sMain
	
