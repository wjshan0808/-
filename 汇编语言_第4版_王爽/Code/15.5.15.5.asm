;ASM
;15.5.15.5 安装int9号中断例程, 按下F1键后改变屏幕的颜色, 其他的键正常处理
;
;资料
;     一页25行80*2列
;

assume cs:msCode
  
  msCode segment
sMain:
    
    mov ax, 0000H
    mov es, ax
    mov di, offset sInt9_Entry_Screen_Int9
    mov ax, es:[09H * 04H + 00H]            ;获取原始Int9中断例程入口ip地址
    mov cs:[di + 00H], ax                   ;保存原始Int9中断例程入口ip地址
    mov ax, es:[09H * 04H + 02H]            ;获取原始Int9中断例程入口cs地址
    mov cs:[di + 02H], ax                   ;保存原始Int9中断例程入口cs地址
    
    mov ax, cs                              ;安装新的Int9中断例程
    mov ds, ax
    mov si, offset func_Screen_Int9
    mov di, 0200H
    mov cx, (offset sEnd_Screen_Int9 - offset func_Screen_Int9)
    cld
    rep movsb                               ;es:[di]=ds:[si]
    
    cli                                     ;保护设置
    mov word ptr es:[09H * 04H + 00H], 0200H;设置新的Int9中断例程入口ip地址
    mov word ptr es:[09H * 04H + 02H], 0000H;设置新的Int9中断例程入口cs地址
    sti                                     ;结束保护

    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_Screen_Int9:
        push ax
        push cx
        push es
        push di
                                            ;暂借寄存器
                                          
          jmp short sDo_Screen_Int9       ;转至程序执行代码
          
          sInt9_Entry_Screen_Int9:
            dw 02H dup (0000H)              ;保存原始int9中断例程入口地址
          
          sDo_Screen_Int9:
            in al, 60H                      ;读取键盘扫描码
          
            mov di, 0200H + (offset sInt9_Entry_Screen_Int9 - offset func_Screen_Int9)
            pushf
            call dword ptr cs:[di]          ;调用原始int9中断例程
            
            cmp al, 53H                     ;和F1键比较3BH
            jne sDone_Screen_Int9
            
            mov ax, 0B800H                  ;改变屏幕背景颜色
            mov es, ax
            mov di, 01H                     ;字符属性列
            mov cx, (19H * 50H)             ;屏幕行*列(字符属性)
            sBColor_Screen_Int9:
                inc byte ptr es:[di]        ;改变字符属性
                add di, 02H                 ;下一列字符属性
              loop sBColor_Screen_Int9
          
          sDone_Screen_Int9:
                                            ;归还寄存器
        pop di
        pop es
        pop cx
        pop ax
      iret                                  ;中断调用返回
    
    sEnd_Screen_Int9:
      nop
      
    
  msCode ends
end sMain
	
