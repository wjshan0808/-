;ASM
;17.17 安装一个新的int 7CH中断例程, 实现通过逻辑扇区号对软盘进行读写
;
;参数
;     (ah)=表示功能号: 00H读, 01H写
;     (dx)=逻辑扇区号(00H~0B3FH)
;     es:bx=指向读取或写入的数据内存区
;返回
;     无
;
;资料
;     3.5英寸的软盘:
;         a. 分为上下两面(磁头), 面号从0开始
;         b. 每面有80个磁道, 磁道号从0开始
;         c. 每个磁道有18个扇区, 扇区号从1开始
;         d. 每个扇区有512个字节
;
;     逻辑扇区号 = (面号 * 50H + 磁道号) * 12H + (扇区号 - 01H)
;
;     int:取商
;     rem:取余
;
;     面号       = int(逻辑扇区号 / 05A0H)
;     磁道号     = int(rem(逻辑扇区号 / 05A0H) / 12H)
;     扇区号     = rem(rem(逻辑扇区号 / 05A0H) / 12H) + 01H
;

assume cs:msCode

  msData segment
    dw 10H dup (0000H) 
  msData ends
  
  msCode segment
sMain:
    
    mov ax, cs                                  ;ds:si
    mov ds, ax
    mov si, offset func_FD_Int7C

    mov ax, 00H                                 ;es:di
    mov es, ax
    mov di, 0200H
    
    cld
    mov cx, (offset sEnd_FD_Int7C - offset func_FD_Int7C)
    rep movsb                                   ;安装新的7CH号中断例程代码
    
    cli
    mov word ptr es:[7CH * 04H + 00H], 0200H    ;注册新的7CH号中断例程入口
    mov es:[7CH * 04H + 02H], es
    sti
    
    mov ax, msData
    mov es, ax
    mov bx, 00H
    mov ah, 00H
    mov dx, 10H
    int 7CH                                     ;调用新的7CH号中断例程
    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_FD_Int7C:
        jmp short sDo_FD_Int7C
        
          fun_AH  db 00H                        ;功能(02H读, 03H写)
          num_DL  db 00H                        ;驱动号(00H:A, 01H:B, 80H:C, 81H:D)
          num_DH  db 00H                        ;面号(00H~01H)
          num_CH  db 00H                        ;磁道号(00H~4FH) 
          num_CL  db 01H                        ;扇区号(01H~12H)
          num_AL  db 01H                        ;读写的扇区数
    
        sDo_FD_Int7C:
          pushf
          push dx
          push cx
          push bp
          
            cmp dx, 0B3FH                       ;验证逻辑扇区号范围
            ja sDone_FD_Int7C
            
            add ah, 02H                         ;验证功能号
            cmp ah, 02H                         ;读功能号
            jb sDone_FD_Int7C
            cmp ah, 03H                         ;写功能号
            ja sDone_FD_Int7C
            
            mov bp, offset fun_AH - offset func_FD_Int7C + 0200H
            mov cs:[bp], ah                     ;功能号
            
            mov bp, 05A0H
            mov ax, dx
            mov dx, 00H
            div bp                              ;计算(逻辑扇区号 / 05A0H)
            
            mov bp, offset num_DH - offset func_FD_Int7C + 0200H
            mov cs:[bp], al                     ;面号
            
            mov cl, 12H
            mov ax, dx
            div cl                              ;计算(rem(逻辑扇区号 / 05A0H) / 12H)
            
            mov bp, offset num_CH - offset func_FD_Int7C + 0200H
            mov cs:[bp], al                     ;磁道号
            
            add ah, 01H
            mov bp, offset num_CL - offset func_FD_Int7C + 0200H
            mov cs:[bp], ah                     ;扇区号
            
            mov bp, offset fun_AH - offset func_FD_Int7C + 0200H
            mov ah, cs:[bp]
            mov bp, offset num_DL - offset func_FD_Int7C + 0200H
            mov dl, cs:[bp]
            mov bp, offset num_DH - offset func_FD_Int7C + 0200H
            mov dh, cs:[bp]
            mov bp, offset num_CH - offset func_FD_Int7C + 0200H
            mov ch, cs:[bp]
            mov bp, offset num_CL - offset func_FD_Int7C + 0200H
            mov cl, cs:[bp]
            mov bp, offset num_AL - offset func_FD_Int7C + 0200H
            mov al, cs:[bp]
            int 13H                             ;调用13号中断例程
            
            sDone_FD_Int7C:
          
          pop bp
          pop cx
          pop dx
          popf
      iret
    sEnd_FD_Int7C:
      nop
    
  msCode ends
end sMain
	
