;8
;   可执行程序加载器
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


                                                    ;定义全局常量
gc_LBA_EXE equ 100                                  ;存储程序的起始LBA值


;
[SECTION segLoader align=16 vstart=0x7c00]          ;程序加载段定义(主引导扇区位置)
    jmp short sMain

    m_LoadExe dd 0x00010000                         ;程序物理加载地址

sMain:

    mov ax, 00H
    mov ss, ax                                      ;栈初始化
    xor sp, sp
    
    mov ax, cs:[00H + m_LoadExe]                    ;(被除数)
    mov dx, cs:[02H + m_LoadExe]                    ;程序物理加载地址
    mov bx, 10H                                     ;(除数)
    div bx                                          ;右移4位
    mov ds, ax                                      ;(商)
    mov es, ax                                      ;设置存储程序数据基段地址
    
    xor bx, bx                                      ;存储程序数据起始偏移地址
    xor di, di                                      ;存储程序数据起始LBA号
    mov si, gc_LBA_EXE
    call procReadDiskLBA
    
                                                    ;解析
    mov ax, [bx + 00H]                              ;(被除数)
    mov dx, [bx + 02H]                              ;程序总长度
    mov bx, 0200H                                   ;扇区大小(除数)
    div bx                                          ;计算扇区数量
    
    cmp dx, 0000H
    je sNextLBA                                     ;不为0(余数)
    inc ax                                          ;计算总扇区数
    
    sNextLBA:
        dec ax                                      ;剩余待读扇区数
    
        cmp ax, 00H                                 ;是否读完所有扇区
        je sDoneLBA
                                                    ;用递增基段地址代替递增偏移地址(0)
            mov bx, ds
            add bx, 0020H
            mov ds, bx                              ;下一个扇区数据存储段地址
                                                    ;
            add si, 01H
            adc di, 00H                             ;递增LBA号
            call procReadDiskLBA
            
            jmp near sNextLBA
        
    sDoneLBA:
        mov ax, es
        mov ds, ax                                  ;恢复程序加载初始段地址
    
                                                    ;解析
    mov ax, [06H]                                   ;程序起始代码段地址
    mov dx, [08H]                                   ;+
    add ax, cs:[00H + m_LoadExe]                    ;程序物理加载地址
    adc dx, cs:[02H + m_LoadExe]                    ;=
                                                    ;程序入口代码起始物理地址

                                                    ;计算程序入口代码逻辑段地址
    ror dx, 04H                                     ;高16位右移4位
    and dx, 0F000H                                  ;因为8086处理器只有20位有效地址, 所以dx的低4位与ax为有效位
    shr ax, 04H                                     ;低16位右移4位
    or ax, dx                                       ;合并形成程序入口代码逻辑段地址
    mov [06H], ax                                   ;覆盖保存
    
                                                    ;解析
    mov cx, [0AH]                                   ;段重定位表项数量
    mov bx, 0CH                                     ;段重定位表偏移量
    sSegsLoop:
            mov ax, [bx + 00H]                      ;表中代码段地址
            mov dx, [bx + 02H]                      ;+
            add ax, cs:[00H + m_LoadExe]            ;程序物理加载地址
            adc dx, cs:[02H + m_LoadExe]            ;=
                                                    ;程序代码段起始物理地址
            
            ror dx, 04H                             ;高16位右移4位
            and dx, 0F000H                          ;因为8086处理器只有20位有效地址, 所以dx的低4位与ax为有效位
            shr ax, 04H                             ;低16位右移4位
            or ax, dx                               ;合并形成程序入口代码逻辑段地址
            
            mov [bx], ax                            ;覆盖保存
            add bx, 04H                             ;表中下一个代码段
        loop sSegsLoop
    
    
    call far [04H]                                  ;执行用户程序代码
    
    
    mov ax, 0x4c00                                  ;退出
    int 21H
    
    
    ;以LBA方式读硬盘数据
    ;   (DI):(SI)设置起始LBA号
    ;   (BX)设置存放数据于DS段中的偏移地址
    ;注:每次读一个扇区(512)字节
    procReadDiskLBA:
            push ax
            push dx
            push cx
            push bx
                                            ;设置读写扇区数量(每成功读取一个扇区数量值减一)
                mov al, 01H                 ;扇区数量(若为0值, 则表示256个扇区)
                mov dx, 01F2H               ;0x01F2端口
                out dx, al

                                            ;设置读写起始LBA扇区号(4字节28位有效扇区号, 依次写入0x01F3~6端口)
                mov ax, si                  ;扇区号[00 ~ 07]位
                mov dx, 01F3H               ;0x01F3端口
                out dx, al                  ;
                
                mov al, ah                  ;扇区号[08 ~ 15]位
                inc dx                      ;0x01F4端口
                out dx, al                  ;
                
                mov ax, di                  ;扇区号[16 ~ 23]位
                inc dx                      ;0x01F5端口
                out dx, al                  ;
                
                mov al, ah                  ;扇区号[24 ~ 27]位
                and al, 0FH
                or al, 0A0H                 ;置高4位(B5:B7:01H)
                or al, 00H                  ;设置主(B4:00H), 从(B4:10H)硬盘
                or al, 40H                  ;设置CHS(B6:00H), LBA(B6:40H)模式
                inc dx                      ;0x01F6端口
                out dx, al                  ;
                
                                            ;设置读写数据请求
                mov al, 20H                 ;读数据(20H), 写数据(30H)
                mov dx, 01F7H               ;0x01F7端口
                out dx, al
                
                                            ;循环获取读写状态(B0:01H)有错误, (B3:08H)已准备, (B7:80H)工作中
                mov dx, 01F7H               ;0x01F7端口
                sStatusReadDiskLBA:
                    in al, dx
                    and al, 89H             ;获取状态
                    
                    cmp al, 01H             ;有错误
                    je sErrorReadDiskLBA
                    
                    cmp al, 80H             ;工作中
                    je sStatusReadDiskLBA
                    
                                            ;连续读取数据
                mov cx, 0200H               ;一扇区(512)字节
                mov dx, 01F0H               ;0x01F0端口
                sReadLoop:
                        in ax, dx
                        mov [bx], ax        ;存储于DS段的bx偏移量中
                        add bx, 02H         ;下一个字地址
                    loop sReadLoop
                
                jmp near sEndReadDiskLBA    ;结束读取
                
                                            ;获取错误原因
                sErrorReadDiskLBA:
                    mov dx, 01F1H           ;0x01F1端口
                    in ax, dx
                
        sEndReadDiskLBA:
            pop bx
            pop cx
            pop dx
            pop ax
        ret                                 ;结束以LBA方式读硬盘数据

    ;
    times 510 - ($ - $$) nop                ;尾部填充
    db 55H, 0AAH