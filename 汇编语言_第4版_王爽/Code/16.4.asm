;ASM
;16.4 安装新的int 7CH中断例程, 为显示输出提供如下功能子程序
;     (0) 清屏: 设置显存中当前屏幕中的字符为空格
;     (1) 设置前景色:  设置显存中当前屏幕中奇地址的属性字节的0,1,2位
;     (2) 设置背景色:  设置显存中当前屏幕中奇地址的属性字节的4,5,6位
;     (3) 向上滚动一行: 依次将n+1行的内容复制到第n行, 最后一行为空
;
;参数
;     (ah)=传递功能号
;     (al)=传递颜色值={0,1,2,3,4,5,6,7}
;
;资料
;

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, cs
    mov ds, ax
    mov si, offset func_Call_Int7C
    mov ax, 00H
    mov es, ax
    mov di, 0200H
    
    cld                                 ;复制新的中断例程程序
    mov cx, (offset sEnd_Call_Int7C - offset func_Call_Int7C)
    rep movsb

                                        ;注册新的Int 7C中断例程
    cli
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 00H
    sti

    mov ax, 0320H
    ;call func_Call_Int7C
    int 7CH
    
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Call_Int7C:
        jmp short sDo_Call_Int7C
                                                                   ;
          funcs dw (offset func00_Int7C - offset func_Call_Int7C) + 0200H  ;01
                dw (offset func01_Int7C - offset func_Call_Int7C) + 0200H  ;23
                dw (offset func02_Int7C - offset func_Call_Int7C) + 0200H  ;45
                dw (offset func03_Int7C - offset func_Call_Int7C) + 0200H  ;67
          
        sDo_Call_Int7C:
          pushf
          push ax
          push bx
          push cx
                                                  ;暂借寄存器
            
            cmp ah, 04H                           ;功能号不大于04
            ja sDone_Call_Int7C
            
            mov bx, 0B800H                        ;当前屏幕
            mov es, bx
            mov cx, 07D0H                         ;2000个字符
            
            mov bh, 00H                           ;(功能号)*02
            mov bl, ah
            add bl, bl
            
                                                  ;代码段功能号入口地址
            call word ptr cs:[offset funcs - offset func_Call_Int7C + bx + 0200H]
            jmp short sDone_Call_Int7C            ;结束
            
            func03_Int7C:
                push ds
                push di
                push si
                push bx
                  mov bx, es
                  mov ds, bx
                  cld                             ;正向
                  mov di, 00H                     ;第n行
                  mov si, 0A0H                    ;第n+1行
                  rep movsw                       ;es:[di]=ds:[si]
                pop bx
                pop si
                pop di
                pop ds
              ret
            
            func02_Int7C:
                push ax
                push di
                  and al, 70H                     ;取背景颜色值
                  mov di, 01H                     ;字符属性地址
                  sBColor_01_Int7C:
                      mov byte ptr es:[di], al    ;字符属性
                      add di, 02H                 ;下一字符属性
                    loop sBColor_01_Int7C
                pop di
                pop ax
              ret
            
            func01_Int7C:
                push ax
                push di
                  and al, 07H                     ;取前景颜色值
                  mov di, 01H                     ;字符属性地址
                  sFColor_01_Int7C:
                      mov byte ptr es:[di], al    ;字符属性
                      add di, 02H                 ;下一字符属性
                    loop sFColor_01_Int7C
                pop di
                pop ax
              ret
            
            func00_Int7C:
                push di
                  mov di, 00H                     ;字符属性地址
                  sClr_01_Int7C:
                      mov word ptr es:[di], 00H   ;清屏
                      add di, 02H                 ;下一字符
                    loop sClr_01_Int7C
                pop di
              ret
        
        sDone_Call_Int7C:
                                                  ;归还寄存器
          pop cx
          pop bx
          pop ax
          popf
      iret                                        ;中断返回
      
    sEnd_Call_Int7C:
      nop
    
  msCode ends
end sMain
	
