;9.2
;   演示BIOS中断
;
;用户程序协议头
;   a. 4字节: 总长度
;   b. 2字节: 入口指令偏移地址
;   c. 4字节: 起始代码段地址
;   d. 2字节: 段重定位表项数量
;   e. N字节: 段重定位表
;   f.
;
;资料
;   参考《x86汇编语言从实模式到保护模式》第九章
;


;头段
[SECTION segHeader align=16 vstart=0]
sHeader:
    
    sLength dd sEndTrailer                                  ;总长度
    
    sOffset dw sBoot                                        ;偏移地址
    sSegment dd section.segBoot.start                       ;代码段地址
    
    sSegCount dw (sEndHeader - sSegBoot) / 04H              ;段重定位表项数量
    sSegBoot dd section.segBoot.start
    sSegFunc dd section.segFunc.start
    sSegData dd section.segData.start
    sSegStack dd section.segStack.start

sEndHeader:

;引导段
[SECTION segBoot align=16 vstart=0]
sBoot:
    mov dx, ss
    mov bp, sp                                              ;保存堆栈段
    mov bx, ds                                              ;保存数据段
    
        mov ax, ds:[sSegStack]                              ;设置程序内部堆栈段
        mov ss, ax
        mov sp, sEndStack
        mov ax, ds:[sSegData]                               ;设置程序内部数据段
        mov ds, ax

        push cs                                             ;保存入口地址
        push sEndBoot
        push word es:[sSegFunc]                             ;进入主函数
        push procMain
        retf
        

sEndBoot:
    mov ds, bx                                              ;恢复数据段
    mov ss, dx                                              ;恢复堆栈段
    mov sp, bp
        
    ;mov ax, 0x4c00
    ;int 21H
    
    retf


;功能段
[SECTION segFunc align=16 vstart=0]
    procMain:
            push bx
            push es
            push ax
                
                mov cx, (sEndSegData - m_iF8s)
                mov bx, m_iF8s
                
                sCharShow:
                        mov al, [bx]
                        mov ah, 0EH                         ;功能号0x0e
                        int 10H                             ;在屏幕光标处写字符, 并推进光标中断程序
                        inc bx
                    loop sCharShow
            
                sCharInput:
                        mov ah, 00H                         ;功能号0x00
                        int 16H                             ;从键盘获取输入字符中断程序
                                                            ;将al键盘字符显示出来
                        mov ah, 0EH                         ;功能号0x0e
                        int 10H                             ;在屏幕光标处写字符, 并推进光标中断程序
                    jmp short sCharInput
                
        sEndMain:
            pop ax
            pop es
            pop bx
        ret

;数据段
[SECTION segData align=16 vstart=0]
                                                            ;0x0d回车, 0x0a换行
    m_iF8s db 'For further information,', 0dH, 0aH
           db "follow 'iF8s' the offical account.", 0dH, 0aH
           db 0dH, 0aH
sEndSegData:

;堆栈段
[SECTION segStack align=16 vstart=0]
    resw 0100H                                              ;堆栈预留
sEndStack:

;尾段
[SECTION segTrailer align=16]

sEndTrailer: