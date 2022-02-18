;9.1
;   通过RTC的定期中断, 在屏幕上显示时钟
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
;BUG
;   跑原书程序也是这个效果, 可能是其他因素问题
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
                
                cli                                         ;禁止中断
                
                mov bx, 0x0000                              ;终端表所在的段地址
                mov es, bx
                mov bx, 70H                                 ;从片0引脚中断号0x70
                shl bx, 02H                                 ;中断号0x70入口地址
                mov word es:[bx + 00H], procInt70
                mov es:[bx + 02H], cs
                
                ;设置周期性中断
                ;mov al, 0AH
                ;or al, 80H
                ;out 70H, al
                ;in al, 71H
                ;or al, 0FH                                  ;RTC索引A寄存器(产生2秒周期中断信号)
                ;out 71H, al
                
                                                            ;设置更新周期结束中断
                mov al, 0BH                                 ;RTC索引B寄存器
                or al, 80H                                  ;阻断NMI
                out 70H, al                                 ;写入索引端口0x70
                
                mov al, 12H                                 ;写入B寄存器00010010B(禁周期中断,闹钟;允许更新周期结束中断,采用24时制BCD编码)
                out 71H, al                                 ;数据端口0x71
                
                mov al, 0CH                                 ;RTC索引C寄存器
                out 70H, al                                 ;写入索引端口0x70(同时打开NMI)
                in al, 71H                                  ;读取数据端口0x71索引B寄存器(使开始产生中断信号)
                
                in al, 0A1H                                 ;读取8259从片的IMR寄存器
                and al, 0FEH                                ;允许RTC中断(B0位置0)
                out 0A1H, al                                ;回写
                
                sti                                         ;恢复中断
                
                sIDLE:
                        hlt                                 ;休眠
                    jmp short sIDLE
            
        sEndMain:
            pop ax
            pop es
            pop bx
        retf
        
    procInt70:
            push ax
            push es
                
                sUIP:
                    mov al, 0AH                             ;RTC索引A寄存器
                    or al, 80H                              ;阻断NMI
                    out 70H, al                             ;写入索引端口0x70
                    in al, 71H                              ;读取数据端口0x71索引A寄存器
                    test al, 80H                            ;测试UIP位是否为0(可以安全访问CMOS RAM)
                    jnz sUIP
                
                xor al, al                                  ;COMS RAM0号单元
                or al, 80H
                out 70H, al                                 ;访问0号单元数据
                in al, 71H
                push ax                                     ;保存0号单元数据
                
                mov al, 02H                                 ;COMS RAM2号单元
                or al, 80H
                out 70H, al                                 ;访问2号单元数据
                in al, 71H
                push ax                                     ;保存2号单元数据
                
                mov al, 04H                                 ;COMS RAM4号单元
                or al, 80H
                out 70H, al                                 ;访问4号单元数据
                in al, 71H
                push ax                                     ;保存4号单元数据
                
                
                mov al, 0CH                                 ;RTC索引C寄存器
                out 70H, al                                 ;写入索引端口0x70(同时打开NMI)
                in al, 71H                                  ;读取数据端口0x71索引B寄存器(使开始产生中断信号)
                
                mov ax, 0B800H
                mov es, ax
                
                pop ax                                      ;时
                call procBCD2ASCII
                mov es:[160 * 12 + 36 * 02 + 00], ah
                mov es:[160 * 12 + 36 * 02 + 02], al
                mov byte es:[160 * 12 + 36 * 02 + 04], ':'
                not byte es:[160 * 12 + 36 * 02 + 05]
                
                pop ax                                      ;分
                call procBCD2ASCII
                mov es:[160 * 12 + 39 * 02 + 00], ah
                mov es:[160 * 12 + 39 * 02 + 02], al
                mov byte es:[160 * 12 + 39 * 02 + 04], ':'
                not byte es:[160 * 12 + 39 * 02 + 05]
                
                pop ax                                      ;秒
                call procBCD2ASCII
                mov es:[160 * 12 + 42 * 02 + 00], ah
                mov es:[160 * 12 + 42 * 02 + 02], al
                mov byte es:[160 * 12 + 42 * 02 + 04], ' '
                not byte es:[160 * 12 + 42 * 02 + 05]
                
                mov al, 20H                                 ;中断结束命令0x20
                out 20H, al                                 ;向主片发送
                out 0A0H, al                                ;向从片发送
                
        sEndInt70:
            pop es
            pop ax
        iret                                                ;中断返回
    
    ;BCD码转ASCII码
    ;   al接收BCD码
    ;   ax传出ASCII码
    procBCD2ASCII:
            ;push
                
                mov ah, al                                  ;复制
                shr ah, 04H                                 ;高位
                and al, 0FH                                 ;低位
                add ax, 3030H
                
        sEndBCD2ASCII:
            ;pop 
        ret

;数据段
[SECTION segData align=16 vstart=0]


;堆栈段
[SECTION segStack align=16 vstart=0]
    resw 0100H                                              ;堆栈预留
sEndStack:

;尾段
[SECTION segTrailer align=16]

sEndTrailer: