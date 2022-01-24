;ASM
;15.5.15.15 安装int9号中断例程, 按下A键后, 除非不再松开, 如果松开就显示满屏A, 其他的键正常处理
;
;资料
;       断码 = 通码 + 80H
;

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, 0000H
    mov es, ax
    
    mov bx, offset sInt9_Entry_A_Screen_Int9      ;保存原始9号中断例程入口地址
    mov ax, es:[09H * 04H + 00H]
    mov cs:[bx + 00H], ax                         ;ip
    mov ax, es:[09H * 04H + 02H]
    mov cs:[bx + 02H], ax                         ;cs
    
    mov ax, cs
    mov ds, ax
    mov si, offset func_A_Screen_Int9
    mov di, 0200H
    mov cx, (offset sEnd_A_Screen_Int9 - offset func_A_Screen_Int9)
    cld                                           ;es:[di]=ds:[si]
    rep movsb                                     ;安装新的9号中断例程
    
    cli
    mov word ptr es:[09H * 04H + 00H], 0200H      ;注册新的9号中断例程入口到中断向量表
    mov es:[09H * 04H + 02H], es
    sti
    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_A_Screen_Int9:
        push ax
        push di
        push es
        push cx
                                                  ;借用寄存器
          jmp short sDo_A_Screen_Int9             ;执行程序代码
            
          sInt9_Entry_A_Screen_Int9:
            dw 0000H, 0000H                       ;原始9号中断例程入口地址
              
          sDo_A_Screen_Int9:
            
            in al, 60H                            ;读取键盘码
            
            mov di, 0200H + (offset sInt9_Entry_A_Screen_Int9 - offset func_A_Screen_Int9)
            pushf
            call dword ptr cs:[di]                ;调用原始9号中断例程
            
            cmp al, (1EH + 80H)                   ;键A松开码
            jne sDone_A_Screen_Int9
          
            mov ax, 0B800H                        ;第0页
            mov es, ax
            mov di, 00H                           ;字符列
            mov cx, (19H * 50H)                   ;行*列(字符)
            sFull_A_Screen_Int9:
                mov byte ptr es:[di], 'A'         ;显示字符
                add di, 02H                       ;下一字符列
              loop sFull_A_Screen_Int9
        
          sDone_A_Screen_Int9:
                                                  ;归还寄存器
        pop cx
        pop es
        pop di
        pop ax
      iret                                        ;中断返回
    
    sEnd_A_Screen_Int9:
      nop
    
  msCode ends
end sMain
	
