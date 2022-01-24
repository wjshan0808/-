;ASM
;15.4.15.1-2 在屏幕中间依次显示a~z, 在显示的过程中按下Esc键后改变显示的颜色
;
;资料
;

assume cs:msCode

  msStack segment
    dw 10H dup (0000H)
  msStack ends
  
  msCode segment
sMain:

    mov ax, msStack
    mov ss, ax
    mov sp, 20H                           ;栈顶
    
    mov ax, 0000H                         ;中断向量段
    mov ds, ax
    
    push ds:[09H * 04H + 02H]             ;保存原始9号中断cs值
    push ds:[09H * 04H + 00H]             ;保存原始9号中断ip值
      
      cli                                 ;屏蔽中断(保护9号入口地址设置正确)
                                          ;设置模拟9号中断ip值
      mov word ptr ds:[09H * 04H + 00H], offset func_Simulate_Call_Int9
      mov ds:[09H * 04H + 02H], cs        ;设置模拟9号中断cs值
      sti                                 ;恢复中断

      mov ax, 0B800H                      ;字符显示地址
      mov es, ax
      
      ;mov dh, 01H                         ;字符属性
      mov dl, 'a'
      sChars:
        mov es:[0A0H * 0CH + 40H + 00H], dl;显示字符
        call func_Sleep
        
        inc dl                            ;下一字符
        cmp dl, 'z'
        jna sChars
      
    
    cli                                   ;屏蔽中断(保护9号入口地址设置正确)
    pop ds:[09H * 04H + 00H]              ;恢复原始9号中断ip值
    pop ds:[09H * 04H + 02H]              ;恢复原始9号中断cs值
    sti                                   ;恢复中断
    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_Simulate_Call_Int9:
        push ax
        ;push bx
                                          ;暂借寄存器
            
          in al, 60H                      ;读取键盘扫描码
            
          pushf                           ;保存标志寄存器
                                          ;进入中断例程后, IF和TF都已置0
          ;pushf                           ;准备设置标志寄存器9,8位
          ;pop bx
          ;and bx, 0FCFFH                  ;设置(IF)=0,(TF)=0
          ;push bx
          ;popf                            ;将设置的值送入标志寄存器
          
                                          ;push cs, push ip
          call dword ptr ss:[20H - 04H]   ;设置cs:ip=原始9号中断例程入口地址, 处理硬件细节
          
          cmp al, 01H                     ;与Esc键通码比较
          jne sEnd_Simulate_Call_Int9
          inc byte ptr es:[0A0H * 0CH + 40H + 01H] ;改变字符属性
        
          sEnd_Simulate_Call_Int9:
            
                                          ;归还寄存器
        ;pop bx
        pop ax
      iret                                ;中断调用的返回
    
    ;
    func_Sleep:
        push ax
        push dx
                                          ;暂借寄存器
        
          mov dx, 08H
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
	
