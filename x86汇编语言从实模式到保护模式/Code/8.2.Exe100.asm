;8
;   可执行程序
;
;用户程序协议头
;   a. 4字节: 总长度
;   b. 2字节: 入口指令偏移地址
;   c. 4字节: 起始代码段地址
;   d. 2字节: 段重定位表项数量
;   e. N字节: 段重定位表
;   f.
;   
;


;
[SECTION segHeader align=16 vstart=0]                       ;程序头段

    m_Length dd sEndSegTrailer                              ;程序长度
    
    m_Entry dw sBoot                                        ;程序入口指令偏移地址
    m_Segment dd section.segBoot.start                      ;程序起始代码段地址
    
    m_SegCount dw (sEndSegHeader - m_SegBoot) / 0x04        ;段重定位表项数量
    m_SegBoot dd section.segBoot.start                      ;Boot项
    m_SegFunc dd section.segFunc.start                      ;Func项
    m_SegData dd section.segData.start                      ;Data项
    m_SegStack dd section.segStack.start                    ;Stack项

sEndSegHeader:                                              ;程序头段结束

;
[SECTION segBoot align=16 vstart=0]                         ;程序引导段
sBoot:
    mov dx, ss                                              ;保存栈段
    mov bp, sp                                              ;保存栈顶

        mov ax, ds:[m_SegStack]                             ;设置程序内部栈段地址
        mov ss, ax
        mov sp, sEndSegStack
        
        mov ax, ds:[m_SegData]                              ;设置程序内部数据段地址
        mov ds, ax
        
        push cs                                             ;压入CS值(为函数中的retf服务)
        push sEndBoot                                       ;压入IP值(为函数中的retf服务)
        ;call far procStringShow                            ;调用函数
        push word es:[m_SegFunc]                            ;压入CS值(为retf服务)
        push procStringShow                                 ;压入IP值(为retf服务)
        retf
        
sEndBoot:    
    mov ax, es
    mov ds, ax                                              ;恢复数据段
    mov ss, dx                                              ;恢复栈段
    mov sp, bp                                              ;恢复栈顶
    
    ;mov ax, 0x4c00                                          ;退出程序引导
    ;int 21H
    
    retf

;
[SECTION segFunc align=16 vstart=0]                         ;程序功能段
    
    ;字符串显示
    procStringShow:
            push bx
            push cx
            
                xor bx, bx                                  ;初始化字符索引
                
                sNextCharShow:
                    mov cl, [bx]                            ;获取字符
                    or cl, cl                               ;是否结束符(\0)
                    jz sEndStringShow
                
                    call procCharShow                       ;字符显示
                    
                    inc bx                                  ;下一个字符
                    jmp sNextCharShow
                
        sEndStringShow:
            pop cx
            pop bx
        retf
    
    ;字符显示
    ;   (CL)字符值
    procCharShow:
            push bx
            push es
            push ax
            
                mov bx, 0B800H                              ;显存段地址
                mov es, bx
        
                call procGetCursorPosition                  ;获取当前光标位置(AX)
                mov bx, ax                                  ;保存当前光标位置
                
                cmp cl, 0DH                                 ;回车符, 移动光标到当前行的行首
                jz sCRChar
                cmp cl, 0AH                                 ;换行符, 移动光标到当前行的下一行
                jz sLFChar
                
                sChar:
                    shl bx, 01H                             ;光标位置乘以2计算字符偏移地址
                    mov es:[bx], cl                         ;显示字符
                    inc ax                                  ;设置下一字符光标位置
                    
                    jmp short sCheckCursor
                    
                sLFChar:
                    add ax, 80                              ;光标位置增加一行
                    
                    jmp short sCheckCursor
                
                sCRChar:
                    mov bl, 80                              ;光标位置除以每行80个字符
                    div bl                                  ;计算当前行的行号(AL)
                    mul bl                                  ;计算当前行的行首光标值(AX)
                    
                    jmp short sMoveCursor
                    
                sCheckCursor:
                    cmp ax, 2000                            ;屏幕是否已满
                    jb sMoveCursor
                    
                    call procUpRollScreen                   ;屏幕上滚一行
                
                sMoveCursor:
                    call procSetCursorPosition              ;设置光标位置(AX)
                    
                
        sEndCharShow:
            pop ax
            pop es
            pop bx
        ret

    ;设置光标位置
    ;   (AH)光标位置高8位值
    ;   (AL)光标位置低8位值
    procSetCursorPosition:
            push bx
            push dx
            push ax
            
                mov bx, ax                                  ;保存原始光标值
            
                mov dx, 03d4H                               ;显卡索引寄存器端口号0x03D4
                mov al, 0eH                                 ;指定0x0E光标高8位寄存器
                out dx, al
                mov dx, 03d5H                               ;显卡数据寄存器端口号0x03D5
                mov al, bh                                  ;设置光标高8位寄存器值
                out dx, al
                
                mov dx, 03d4H                               ;显卡索引寄存器端口号0x03D4
                mov al, 0fH                                 ;指定0x0F光标低8位寄存器
                out dx, al
                mov dx, 03d5H                               ;显卡数据寄存器端口号0x03D5
                mov al, bl                                  ;设置光标低8位寄存器值
                out dx, al
                
        sEndSetCursorPosition:
            pop ax
            pop dx
            pop bx
        ret

    ;获取光标位置
    ;   (AH)光标位置高8位值
    ;   (AL)光标位置低8位值
    procGetCursorPosition:
            push dx
            ;push ax
            
                mov dx, 03d4H                               ;显卡索引寄存器端口号0x03D4
                mov al, 0eH                                 ;指定0x0E光标高8位寄存器
                out dx, al
                mov dx, 03d5H                               ;显卡数据寄存器端口号0x03D5
                in al, dx                                   ;读取光标高8位寄存器值
                mov ah, al
                
                mov dx, 03d4H                               ;显卡索引寄存器端口号0x03D4
                mov al, 0fH                                 ;指定0x0F光标低8位寄存器
                out dx, al
                mov dx, 03d5H                               ;显卡数据寄存器端口号0x03D5
                in al, dx                                   ;读取光标低8位寄存器值
                
        sEndGetCursorPosition:
            ;pop ax
            pop dx
        ret

    ;屏幕上滚动一行
    ;   (AH)光标位置高8位值
    ;   (AL)光标位置低8位值
    procUpRollScreen:
            push ax
            push es
            push ds
            push si
            push di
            push cx
                
                mov ax, 0B800H                              ;显存段地址
                mov es, ax
                mov ds, ax
                
                mov si, 00A0H                               ;设置源地址偏移量
                mov di, 0000H                               ;设置目的地址偏移量
                
                cld
                mov cx, (80 * 24)                           ;字符数量
                rep movsw
                
                shl di, 01H
                mov cx, 80                                  ;清除最后一行
                sCleanBottomLine:
                        mov word es:[di], 0720H             ;空格值
                        add di, 02H
                    loop sCleanBottomLine
                
        sEndUpRollScreen:
            pop cx
            pop di
            pop si
            pop ds
            pop es
            pop ax
        ret

sEndSegFunc:                                                ;函数段尾


;
[SECTION segData align=16 vstart=0]                         ;程序数据段
                                                            ;0x0d回车, 0x0a换行
    m_iF8s db 'For further information,', 0dH, 0aH
           db "follow 'iF8s' the offical account.", 0dH, 0aH
           db 00H

sEndSegData:                                                ;数据段尾

;
[SECTION segStack align=16 vstart=0]                        ;程序栈段
    resb 0x200                                              ;预留空间

sEndSegStack:                                               ;栈段尾
   
;
[SECTION segTrailer]                                        ;程序尾段
sEndSegTrailer:                                             ;程序尾