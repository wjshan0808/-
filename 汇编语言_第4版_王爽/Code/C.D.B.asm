;ASM
;Course.Design.B 编写一个可以自行启动计算机, 不需要在现有操作系统中运行的程序
;     1) reset pc     ;重新启动计算机(考虑FFFF:0单元)
;     2) start system ;引导现有的操作系统(考虑C盘0道0面1扇区)
;     3) clock        ;进入时钟程序(循环读CMOS, 动态显示 年/月/日 时:分:秒, 按下F1改变颜色, 按下Esc返回菜单)
;     4) set clock    ;设置时钟(更改后返回主菜单)
;参数
;     无
;返回
;     功能1, 2, 4在DOSBox中没有效果
;注释
;     将程序分为三部分, 一部分为安装程序, 一部分为装载程序(需小于512字节), 一部分为执行程序
;资料
;     开机后, CPU自动进入到FFFF:0单元处执行, 此处有一条跳转指令, 
;     CPU执行该指令后, 转去执行BIOS中的硬件系统检测和初始化程序
;     初始化程序建立BIOS所支持的中断向量, 将BIOS提供的中断例程的入口地址登记在中断向量表中
;     硬件系统检测和初始化完成后, 调用int 19H进行操作系统的引导
;         a. 控制0号软驱, 读取软盘0面0道1扇区的内容到0000:7C00
;         b. 将CS:IP指向0000:7C00
;     如果0号软驱中没有软盘, 或发生I/O错误, 则int 19H读取硬盘C
;     3.5英寸的软盘:
;         a. 分为上下两面(磁头), 面号从0开始
;         b. 每面有80个磁道, 磁道号从0开始
;         c. 每个磁道有18个扇区, 扇区号从1开始
;         d. 每个扇区有512个字节
;     端口的数据访问用in/out指令, 访问8位端口用al, 16位端口用ax
;     对256~65535的端口进行读写时, 端口号放在dx中
;     CMOS RAM芯片有两个端口, 70H端口为地址端口, 71H为数据端口
;     时间存放单元年:9, 月:8, 日:7, 时:4, 分:3, 秒:0都为BCD码形式存放的1个字节值
;     BCD码是以4位二进制表示1位十进制的编码方式, 高4位表示十位, 低4位表示个位
;     按键产生扫描码送入60H端口, 若IF=1则CPU响应int 9H中断例程
;

assume cs:msCode, ds:msData

  msData segment
    sSuccess_Setup db 'S', 07H, 'e', 07H, 't', 07H, 'u', 07H, 'p', 07H, ' ', 07H, 'd', 07H, 'o', 07H, 'n', 07H, 'e', 07H, ',', 07H, ' ', 07H, 'S', 02H, 'u', 02H, 'c', 02H, 'c', 02H, 'e', 02H, 's', 02H, 's', 02H, '!', 07H, 00H
    sFailure_Setup db 'S', 07H, 'e', 07H, 't', 07H, 'u', 07H, 'p', 07H, ' ', 07H, 'd', 07H, 'o', 07H, 'n', 07H, 'e', 07H, ',', 07H, ' ', 07H, 'F', 04H, 'a', 04H, 'i', 04H, 'l', 04H, 'u', 04H, 'r', 04H, 'e', 04H, '!', 07H, 00H
    sResult_Setup dw sSuccess_Setup, sFailure_Setup
  msData ends
  
  msCode segment
sMain:
    
    ;计算字节
    mov ax, (offset sEnd_CDB_7C00 - offset sCDB_7C00)
    mov bx, (offset sEnd_CDB_7E00 - offset sCDB_7E00)
    
    ;测试
    ;jmp near ptr sCDB_7E00
    
    ;安装程序
    sCDB_Setup:
    
        ;初始化
        mov ax, msData
        mov ds, ax
        mov ax, cs
        mov es, ax
        
        ;
        mov bp, 00H                 ;执行结果
        
        ;
        mov dl, 00H                 ;驱动器号 A:00H, B:01H, C:80H, D:81H
        mov dh, 00H                 ;磁面号 0面
        mov ch, 00H                 ;磁道号 0道
        
        ;将es:bx内存地址的装载程序数据写入(A软盘0面0道1扇区)
        mov bx, offset sCDB_7C00
        mov cl, 01H                 ;扇区号 1扇区
        mov al, 01H                 ;读写扇区数(固定一扇区)
        mov ah, 03H                 ;功能号 02读, 03写
        int 13H                     ;BIOS访问磁盘的中断例程
        
        ;
        add bp, ax                  ;存储执行结果
        
        ;将es:bx内存地址的执行程序数据写入(A软盘0面0道1扇区)后
        mov bx, offset sCDB_7E00
        mov cl, 02H                 ;扇区号 2扇区
        mov al, 02H                 ;读写扇区数(由执行程序字节大小决定)
        mov ah, 03H                 ;功能号 02读, 03写
        int 13H                     ;BIOS访问磁盘的中断例程
        
        ;
        add bp, ax                  ;存储执行结果
        
        mov ax, 0B800H              ;设置屏幕段地址
        mov es, ax
        mov di, 0F00H               ;00A0H * 24行
        mov bx, 09EH
        
        sTrace_CDB_Setup:           ;逆序查找非空格字符
          cmp byte ptr es:[di + bx], 20H
          jne sEnd_Trace_CDB_Setup
          cmp bx, 00H
          je sNext_Trace_CDB_Setup
          sub bx, 02H               ;递减列地址
          jmp short sTrace_CDB_Setup
          
          sNext_Trace_CDB_Setup:
            sub di, 0A0H            ;递减行地址
            mov bx, 09EH
            jmp short sTrace_CDB_Setup
        
        sEnd_Trace_CDB_Setup:
          add di, 0A0H
          mov si, sResult_Setup[00H]
          cmp bp, (0001H + 0002H)   ;同正确的结果对比
          je sResult_CDB_Setup
          mov si, sResult_Setup[01H]
        
        sResult_CDB_Setup:
          cld
          mov cx, 28H
          rep movsb
        
    sEnd_CDB_Setup:
      nop
    
    ;
    mov ax, 4c00H                   ;安装程序结束
    int 21H
    
    
    
    ;装载程序(在0000:7C00内存地址处)(512字节)
    sCDB_7C00:
      jmp near ptr sDo_CDB_7C00
        load    db 'Loading'
        success db 'S', 02H, 'u', 02H, 'c', 02H, 'c', 02H, 'e', 02H, 's', 02H, 's', 02H
        failure db 'F', 84H, 'a', 84H, 'i', 84H, 'l', 84H, 'u', 84H, 'r', 84H, 'e', 84H
        iF8s    db 'For further information                                                    follow ''iF8s'' the offical account'
        infos   dw (offset load - offset sCDB_7C00) + 7C00H
                dw (offset success - offset sCDB_7C00) + 7C00H
                dw (offset failure - offset sCDB_7C00) + 7C00H
                dw (offset iF8s - offset sCDB_7C00) + 7C00H
      
      sDo_CDB_7C00:
        ;
        mov ax, 0B800H              ;设置屏幕段地址
        mov es, ax
                                    ;输出WC信息
        xor di, di
        xor bx, bx
        mov cx, (offset infos - offset iF8s)
        sLoop_iF8s_CDB_7C00:
            mov al, cs:[bx + (offset iF8s - offset sCDB_7C00) + 7C00H]
            mov es:[di + 3AH + 0A00H], al
            inc bx
            add di, 02H
          loop sLoop_iF8s_CDB_7C00
                                    ;输出加载信息
        xor di, di
        xor bx, bx
        mov cx, (offset success - offset load)
        sLoop_Load_CDB_7C00:
            mov al, cs:[bx + (offset load - offset sCDB_7C00) + 7C00H]
            mov es:[di + 4AH + 0780H], al
            inc bx
            add di, 02H
          loop sLoop_Load_CDB_7C00
        ;
        sRedo_CDB_7C00:
                                    ;清除结果
          mov di, (4AH + 08C0H)
          mov cx, 07H
          sLoop_Clear_Result_CDB_7C00:
              mov es:[di + 00H], word ptr 0700H
              add di, 02H
            loop sLoop_Clear_Result_CDB_7C00
            
                                    ;输出等待结果
          xor di, di
          xor bx, bx
          mov cx, 03H
          sLoop_Dot_CDB_7C00:
              mov byte ptr es:[di + 4EH + 08C0H], '.'
              inc bx
              add di, 02H
              call func_Loading
            loop sLoop_Dot_CDB_7C00
        
          mov ax, cs
          mov es, ax
          mov bx, (7C00H + 0200H)     ;执行程序es:bx内存地址
          
          ;将(A软盘0面0道1扇区)后的执行程序数据读取到es:bx内存地址
          mov dl, 00H                 ;驱动器号 A:00H, B:01H, C:80H, D:81H
          mov dh, 00H                 ;磁面号 0面
          mov ch, 00H                 ;磁道号 0道
          mov cl, 02H                 ;扇区号 2扇区
          mov al, 02H                 ;读写扇区数(由执行程序字节大小决定)
          mov ah, 02H                 ;功能号 02读, 03写
          int 13H                     ;BIOS访问磁盘的中断例程
        
        ;
        mov dx, 0B800H              ;设置屏幕段地址
        mov es, dx
          
                                    ;输出结果信息
        mov bx, (offset failure - offset sCDB_7C00) + 7C00H
        cmp ax, 02H
        jne sResult_CDB_7C00
        mov bx, (offset success - offset sCDB_7C00) + 7C00H
        
        sResult_CDB_7C00:
          xor di, di
          mov cx, 0EH
          sLoop_Result_CDB_7C00:
              mov dl, cs:[bx + di]
              mov es:[di + 4AH + 08C0H], dl
              inc di
            loop sLoop_Result_CDB_7C00
        
        call func_Loading
        
        cmp ax, 02H
        jne sRedo_CDB_7C00
        ;
        mov ax, 7E00H
        jmp ax                      ;跳转到执行程序
         
        
      ;休息
      func_Loading:
          push dx
          push ax
            
            mov dx, 8000H                             ;初始化循环4000H * 10000H次数
            mov ax, 0000H
            
            sDo_Loading:
              sub ax, 01H                             ;递减低16位
              sbb dx, 00H                             ;递减高16位
              
              cmp ax, 00H                             ;递减低16位完成
              jne sDo_Loading
              
              cmp dx, 00H                             ;递减高16位完成
              jne sDo_Loading
              
          pop ax
          pop dx
        ret                                           ;内部返回
        
      ;ret
    sEnd_CDB_7C00:
      ;db (offset sEnd_CDB_7C00 - offset sCDB_7C00 - 02H) dup (90H)
      db (0B0H) dup (90H)
      dw 0AA55H                     ;0x55, 0xAA
      nop
    
    
    
    ;执行程序(在0000:7E00内存地址处)
    sCDB_7E00:
      ;
      jmp near ptr sDo_CDB_7E00
        menuTip   db '1) reset pc', 00H
                  db '2) start system', 00H
                  db '3) clock', 00H
                  db '4) set clock', 01H                                         ;01H结束标识
        inputTip  db 'please input:', 00H
        tickTip   db 'press <Esc> back to menu. press <F1> color transform.', 00H
        editTip   db 'press <Esc> back to menu. press <Tab> make choise. press <Enter> apply changes.', 00H
        tips7E00  dw (offset menuTip - offset sCDB_7E00 + 7E00H)
                  dw (offset inputTip - offset sCDB_7E00 + 7E00H)
                  dw (offset tickTip - offset sCDB_7E00 + 7E00H)
                  dw (offset editTip - offset sCDB_7E00 + 7E00H)
        clockA    db 09H,      08H,      07H,      04H,      02H,      00H       ;时间单元地址 年,月,日,时,分,秒
        clockV    db 00H, '/', 00H, '/', 00H, ' ', 00H, ':', 00H, ':', 00H, '$'  ;时间单元值   年,月,日,时,分,秒
        func7E00  dw (offset func_Reset_PC - offset sCDB_7E00 + 7E00H)
                  dw (offset func_Start_System - offset sCDB_7E00 + 7E00H)
                  dw (offset func_Clock - offset sCDB_7E00 + 7E00H)
                  dw (offset func_Set_Clock - offset sCDB_7E00 + 7E00H)
        funcReset dd 0FFFF0000H                                                   ;计算机重置地址
        
      ;
      sDo_CDB_7E00:
        ;push ax
        ;push es
          
          ;
          mov ax, 0B800H                              
          mov es, ax                                      ;设置屏幕段地址
          ;
          mov ax, cs
          mov ds, ax                                      ;设置数据段
          mov ss, ax                                      ;设置栈段
          mov sp, 9000H                                   ;设置栈顶
          
          ;
          call func_Maintain
          jmp near ptr sDone_CDB_7E00                     ;执行结束
      
          ;主函数
          func_Maintain:
              push si
              push ax
              push bx
              push cx
                  
                sDo_Maintain:
                
                  call func_Clear_Screen                  ;清屏
                  call func_Show_Menu                     ;显示菜单
                  ;
                  mov si, 02H                             ;输入提示字符地址偏移量
                  call func_Show_Tip                      ;显示提示
                  
                  ;检查输入值
                  sInput_Maintain:
                    mov ax, 00H                           ;重置键盘码值
                    in al, 60H                            ;读取键盘输入
                    ;mov ah, 00H                          ;Int 16H的0号功能
                    ;int 16H                              ;读取键盘输入(ah=扫描码, al=ASCII码)
                    
                    cmp al, 02H                           ;和键1扫描码比较
                    jb sInput_Maintain                    ;小于时重新获取
                    cmp al, 05H                           ;和键4扫描码比较
                    ja sInput_Maintain                    ;大于时重新获取
                    
                    mov si, ax                            ;保存功能号
                  
                  ;在光标处显示值
                  mov ah, 09H                             ;Int 10H的9号功能
                  add al, 2FH                             ;显示的字符(功能号+2FH)
                  mov bl, 0AH                             ;显示的字符属性
                  mov bh, 00H                             ;第0页
                  mov cx, 01H                             ;重复数1个
                  int 10H                                 ;调用int 10H中断例程
                  
                  call func_Sleep                         ;等待一会儿
                  call func_Clear_Screen                  ;清屏
                  
                  sub si, 02H                             ;计算函数调用地址索引
                  add si, si
                  call word ptr ds:[func7E00 - offset sCDB_7E00 + 7E00H + si]
                  ;
                  jmp short sDo_Maintain                  ;循环操作
                  
              pop cx
              pop bx
              pop ax
              pop si
            ret                                           ;内部返回
          
          
          ;重新启动计算机
          func_Reset_PC:
              ;push ax
              
                ;mov ax, 0FFFFH
                ;mov cs, ax
                ;mov ax, 0000H
                ;mov ip, ax
                                                          ;重启计算机
                jmp dword ptr ds:[funcReset - offset sCDB_7E00 + 7E00H]
                
              ;pop ax
            ret                                           ;内部返回
          
          ;引导现有的操作系统
          func_Start_System:
              ;push ax
                
                ;用es:bx内存地址将(C磁盘0面0道1扇区)数据复制到(A软盘0面0道1扇区)
                mov ax, cs
                mov es, ax
                mov bx, 7C00H
                
                ;(C磁盘0面0道1扇区)
                mov dl, 80H                               ;驱动器号 A:00H, B:01H, C:80H, D:81H
                mov dh, 00H                               ;磁面号 0面
                mov ch, 00H                               ;磁道号 0道
                mov cl, 01H                               ;扇区号 1扇区
                mov al, 01H                               ;读写扇区数(固定一扇区)
                mov ah, 02H                               ;功能号 02读, 03写
                int 13H                                   ;BIOS访问磁盘的中断例程
                
                ;(A软盘0面0道1扇区)
                mov dl, 00H                               ;驱动器号 A:00H, B:01H, C:80H, D:81H
                mov dh, 00H                               ;磁面号 0面
                mov ch, 00H                               ;磁道号 0道
                mov cl, 01H                               ;扇区号 1扇区
                mov al, 01H                               ;读写扇区数(固定一扇区)
                mov ah, 03H                               ;功能号 02读, 03写
                int 13H                                   ;BIOS访问磁盘的中断例程
                
                                                          ;重启计算机
                jmp dword ptr ds:[funcReset - offset sCDB_7E00 + 7E00H]
                
              ;pop ax
            ret                                           ;内部返回
          
          ;进入时钟程序
          func_Clock:
              push si
              push ax
              push di
              push cx
              
                mov si, 04H                               ;时钟显示提示字符地址偏移量
                call func_Show_Tip                        ;显示提示
              
                sDo_Clock:
                  mov ax, 00H                             ;重置键盘码值
                  in al, 60H                              ;读取键盘输入
                  ;mov ah, 00H                            ;Int 16H的0号功能
                  ;int 16H                                ;读取键盘输入(ah=扫描码, al=ASCII码)
                  
                  cmp al, 01H                             ;和键Esc扫描码比较
                  je sEnd_Clock                           ;相等时退出时钟显示
                  
                  cmp al, 3BH                             ;和键F1扫描码比较
                  jne sClock_Tick                         ;不相等时跳过改变字符属性
                  
                  mov di, 01H                             ;设置字符属性起始地址索引
                  mov cx, 11H                             ;17个时钟字符串长度
                  sColor_Tick_Transform:
                      inc byte ptr es:[di + 0780H + 3CH]  ;改变字符属性值
                      add di, 02H                         ;下一个字符属性地址索引
                    loop sColor_Tick_Transform
                  
                  call func_Sleep                         ;休息一会儿
                
                sClock_Tick:
                  mov ah, 00H                             ;获取时钟单元值
                  call func_Maintain_Clock
                  call func_Stamp_Clock                   ;显示时钟单元值
                
                jmp short sDo_Clock                       ;循环时钟程序
                
            sEnd_Clock:
              pop cx
              pop di
              pop ax
              pop si
            ret                                           ;内部返回
          
          ;设置时钟
          func_Set_Clock:
              push si
              push ax
              push bx
              push dx
              
                mov si, 06H                               ;时钟设置提示号
                call func_Show_Tip                        ;操作提示
              
                mov ah, 00H                               ;获取时钟单元值
                call func_Maintain_Clock
                call func_Stamp_Clock                     ;显示时钟单元值
                
                sInit_Tab_Set_Clock:
                  mov bl, 00H                             ;初始化光标位置
                  jmp short sCursor_Set_Clock             ;移动光标
                
                sInput_Set_Clock:
                  mov ax, 00H                             ;重置键盘码值
                  in al, 60H                              ;读取键盘输入
                  ;mov ah, 00H                            ;Int 16H的0号功能
                  ;int 16H                                ;读取键盘输入(ah=扫描码, al=ASCII码)
                  
                  cmp al, 01H                             ;和键Esc扫描码比较
                  je sEnd_Set_Clock                       ;相等时退出时间修改
                  
                  cmp al, 0FH                             ;和键Tab扫描码比较
                  je sTab_Set_Clock                       ;切换时间单元编辑位置
                  
                  cmp al, 1CH                             ;和键Enter扫描码比较
                  je sEnter_Set_Clock                     ;相等时设置时间
                  
                  cmp al, 02H                             ;和键1~9扫描码比较
                  jb sInput_Set_Clock
                  cmp al, 0BH                             ;和键0扫描码比较
                  ja sInput_Set_Clock
                  dec al                                  ;匹配按键到时钟数字值(没有做时钟值合法性检测)
                  cmp al, 0AH                             ;0BH减一
                  jne sNumber_Set_Clock
                  mov al, 00H                             ;0AH表示值为0
                    
                  sNumber_Set_Clock:
                    call func_Digital_Clock               ;数字化时钟值
                    
                  call func_Stamp_Clock                   ;显示时钟
                  jmp short sInput_Set_Clock
                
                sEnter_Set_Clock:                         ;处理Enter按键
                  mov ah, 01H
                  call func_Maintain_Clock                ;维护时钟
                  jmp short sEnd_Set_Clock                ;退出时钟设置
                
                sTab_Set_Clock:                           ;处理Tab按键
                  inc bl                                  ;递增光标位置
                  
                  cmp bl, 11H                             ;当光标位置在结尾时
                  je sInit_Tab_Set_Clock                  ;初始化时钟单元地址位置
                  
                  cmp bl, 02H                             ;当光标在格式化位置时
                  je sNext_Cursor_Set_Clock
                  cmp bl, 05H                             ;当光标在格式化位置时
                  je sNext_Cursor_Set_Clock
                  cmp bl, 08H                             ;当光标在格式化位置时
                  je sNext_Cursor_Set_Clock
                  cmp bl, 0BH                             ;当光标在格式化位置时
                  je sNext_Cursor_Set_Clock
                  cmp bl, 0EH                             ;当光标在格式化位置时
                  je sNext_Cursor_Set_Clock
                  
                  jmp short sCursor_Set_Clock             ;移动光标
                  
                  sNext_Cursor_Set_Clock:
                    inc bl                                ;增加光标到时钟单元地址位置
                    jmp short sCursor_Set_Clock           ;移动光标
                
                sCursor_Set_Clock:                        ;移动光标
                  mov ah, 02H                             ;Int 10H的2号功能
                  mov bh, 00H                             ;第0页
                  mov dh, 0CH                             ;行号屏幕中间
                  mov dl, 1EH                             ;列号基值
                  add dl, bl                              ;列号偏移值
                  int 10H                                 ;调用Int 10H中断例程
                  
                  call func_Sleep                         ;休息一会儿
                
                jmp short sInput_Set_Clock
                
            sEnd_Set_Clock:
              pop dx
              pop bx
              pop ax
              pop si
            ret                                           ;内部返回
          
          
          ;时钟单元维护
          ;参数 (ah)=01H设置时钟, (ah)!=01H读取时钟
          func_Maintain_Clock:
              push bx
              push di
              push cx
              push ax
                
                mov bx, 00H                               ;初始化获取时钟单元地址索引
                mov di, 00H                               ;初始化获取时钟单元值索引
                mov cx, 06H                               ;初始化获取时钟单元数量
                sLoop_Maintain_Clock:
                                                          ;获取时钟单元地址值
                    mov al, ds:[clockA - offset sCDB_7E00 + 7e00H + bx]
                    out 70H, al                           ;向70H地址端口输入时钟单元地址
                    
                    cmp ah, 01H                           ;(ah)=1设置时钟单元值否则为获取时钟单元值
                    jne sLoop_Get_Maintain_Clock
                    
                  sLoop_Set_Maintain_Clock:
                                                          ;从时钟单元内存获取时钟单元值
                    mov al, ds:[clockV - offset sCDB_7E00 + 7e00H + di]
                    out 71H, al                           ;向71H数据端口输入时钟单元值
                    jmp short sLoop_Do_Maintain_Clock
                    
                  sLoop_Get_Maintain_Clock:
                    in al, 71H                            ;从71H数据端口输出时钟单元值
                                                          ;将时钟单元值输送到时钟单元内存
                    mov ds:[clockV - offset sCDB_7E00 + 7e00H + di], al
                    
                  sLoop_Do_Maintain_Clock:
                    inc bx                                ;定位下一个时钟单元地址
                    add di, 02H                           ;定位下一个时钟单元值地址
                    
                  loop sLoop_Maintain_Clock
              
              pop ax
              pop cx
              pop di
              pop bx
            ret                                           ;内部返回
            
          ;时钟戳
          func_Stamp_Clock:
              push bx
              push di
              push cx
              push ax
              
                mov bx, 00H                               ;初始化时钟单元值地址索引
                mov di, 00H                               ;初始化时钟单元显示地址索引
                mov cx, 06H                               ;6个时钟单元数量
                sLoop_Stamp_Clock:
                                                          ;从时钟单元内存中获取时钟单元值
                    mov al, ds:[clockV - offset sCDB_7E00 + 7e00H + bx + 00H]
                    call func_BCD_2_ASCII                 ;将BCD格式的时钟单元值转换为ASCII
                  
                    mov es:[di + 00H + 0780H + 3CH], ah   ;在屏幕中间输出时钟单元十位值
                    mov es:[di + 02H + 0780H + 3CH], al   ;在屏幕中间输出时钟单元个位值
                                                          ;从时钟单元内存中获取时钟单元格式化符值
                    mov al, ds:[clockV - offset sCDB_7E00 + 7e00H + bx + 01H]
                    mov es:[di + 04H + 0780H + 3CH], al   ;在屏幕中间输出时钟单元格式化符值
                    
                    add bx, 02H                           ;定位下一个时钟单元值地址索引
                    add di, 06H                           ;定位下一个时钟单元值显示地址索引
                    
                  loop sLoop_Stamp_Clock
              
              pop ax
              pop cx
              pop di
              pop bx
            ret                                           ;内部返回
          
          ;数字化时钟
          ;参数 (AL)数字值, (BL)光标位置
          func_Digital_Clock:
              push dx
              push ax
              push cx
              push bx
              
                mov dx, ax                                ;保存al副本
                
                mov ah, 00H
                mov al, bl                                ;光标是被除数
                mov cl, 03H                               ;3个字节一个组
                div cl                                    ;计算光标和数值索引关系
                  
                mov bx, 00H                               ;计算时钟字符位置
                add bl, al                                ;2倍商表示字节组起始偏移
                add bl, al
                
                cmp ah, 01H                               ;光标在时钟低4位
                je sLow4_Digital_Clock
                
                mov cl, 04H
                shl dl, cl                                ;光标在时钟高4位
                                                          ;保存数字值于高4位
                and byte ptr ds:[clockV - offset sCDB_7E00 + 7e00H + bx], 0FH
                or ds:[clockV - offset sCDB_7E00 + 7e00H + bx], dl
                jmp short sEnd_Digital_Clock
                
                sLow4_Digital_Clock:
                                                          ;保存数字值于低4位
                  and byte ptr ds:[clockV - offset sCDB_7E00 + 7e00H + bx], 0F0H
                  or ds:[clockV - offset sCDB_7E00 + 7e00H + bx], dl
                  
            sEnd_Digital_Clock:
              pop bx
              pop cx
              pop ax
              pop dx
            ret                                           ;内部返回
          
          
          ;菜单展示
          func_Show_Menu:
              push bx
              push di
              push bp
              push ax
                
                ;菜单首字符偏移地址
                mov bx, [offset menuTip - offset sCDB_7E00 + 7e00H + 00H]
                
                mov di, 3CH                               ;屏幕显示菜单首偏移列地址
                mov bp, 0640H                             ;屏幕显示菜单首偏移行地址
                
                sDo_Show_Menu:
                  mov al, [bx]                            ;获取菜单显示字符
                  inc bx                                  ;下一个菜单字符地址索引
                  
                  cmp al, 01H                             ;字符和单项菜单结束字符对比
                  je sEnd_Show_Menu                       ;菜单显示结束处理菜单选择
                  cmp al, 00H                             ;字符和整体菜单结束字符对比
                  jne sItem_Show_Menu                     ;是单项菜单结束符跳过菜单项换行
                  
                  mov di, 3CH                             ;屏幕显示菜单首偏移列地址
                  add bp, 0A0H                            ;递增显示菜单首偏移行地址
                  jmp short sDo_Show_Menu                 ;重复菜单字符显示
                  
                  sItem_Show_Menu:
                    mov es:[bp + di + 00H], al            ;在屏幕中间输出菜单字符
                    add di, 02H                           ;下一个字符地址索引
                    jmp short sDo_Show_Menu               ;重复菜单字符显示
                  
            sEnd_Show_Menu:
              pop ax
              pop bp
              pop di
              pop bx
            ret                                           ;内部返回
            
          ;操作提示
          ;参数 (SI)提示字符偏移量
          func_Show_Tip:
              push bx
              push dx
              push di
              push cx
              push ax
                
                ;提示字符偏移地址
                mov bx, ds:[tips7E00 - offset sCDB_7E00 + 7e00H + si]
                
                mov dl, 00H                               ;初始化提示字符数量提示字符后面
                mov dh, 18H                               ;初始化提示字符行号屏幕最底
                mov di, 00H                               ;初始化提示字符列号
                mov cx, 00H                               ;初始化CX值
                sDo_Show_Tip:
                  mov cl, [bx]                            ;获取提示字符
                  inc dl                                  ;统计提示字符数量
                  jcxz sIsHide_Cursor_Show_Tip            ;提示字符结束
                  
                  mov es:[di + 0A0H * 18H], cl            ;输出提示字符
                  add di, 02H                             ;下一个输出字符地址索引
                  inc bx                                  ;下一个提示字符地址索引
                  jmp short sDo_Show_Tip                  ;循环输出
                
                sIsHide_Cursor_Show_Tip:
                  cmp si, 02H                             ;如果是输入提示字符偏移量
                  je sCursor_Show_Tip                     ;则跳过将行号设置为屏幕最低行
                  inc dh                                  ;将行号设置为屏幕最低行
                
                sCursor_Show_Tip:                         ;设置光标
                  mov ah, 02H                             ;Int 10H的2号功能
                  mov bh, 00H                             ;第0页
                  mov dh, dh                              ;行号
                  mov dl, dl                              ;列号
                  int 10H                                 ;调用中断
                
              pop ax
              pop cx
              pop di
              pop dx
              pop bx
            ret                                           ;内部返回
          
          
          ;将(AL)的BCD码转换ASCII码
          ;返回 (AH)十位值, (AL)个位值
          func_BCD_2_ASCII:
              push cx
              ;push ax
                
                mov cl, 04H                               ;位移数大于1存放于cl中
                mov ah, al                                ;保存al副本
                
                shr ah, cl                                ;获取BCD码十位值
                and al, 0FH                               ;获取BCD码个位值
                
                add ax, 3030H                             ;转换为ASCII码
              
              ;pop ax
              pop cx
            ret                                           ;内部返回
          
          ;休息
          func_Sleep:
              push dx
              push ax
                
                mov dx, 4000H                             ;初始化循环4000H * 10000H次数
                mov ax, 0000H
                
                sDo_Sleep:
                  sub ax, 01H                             ;递减低16位
                  sbb dx, 00H                             ;递减高16位
                  
                  cmp ax, 00H                             ;递减低16位完成
                  jne sDo_Sleep
                  
                  cmp dx, 00H                             ;递减高16位完成
                  jne sDo_Sleep
                  
              pop ax
              pop dx
            ret                                           ;内部返回
           
          ;清屏
          func_Clear_Screen:
              push di
              push cx
                
                mov di, 00H                               ;初始化首字符地址索引
                mov cx, 07D0H                             ;一屏2000个字符2000个属性
                sClear_Screen:
                    mov es:[di + 00H], word ptr 0700H     ;在屏幕中写入空字符
                    add di, 02H                           ;下一字符地址索引
                  loop sClear_Screen
                  
              pop cx
              pop di
            ret                                           ;内部返回


          ;call func_AX_Debug
          ;call func_Sleep
          ;call func_Sleep
          ;call func_Sleep
          ;在屏幕调式输出(AX)
          func_AX_Debug:
              push ax
              push dx
              push cx
              
                mov es:[00H + 0A0H * 02H], byte ptr 'A'
                mov es:[02H + 0A0H * 02H], byte ptr 'X'
                mov es:[04H + 0A0H * 02H], byte ptr '='
                
                mov dx, ax
                mov cl, 04H
                
                shr ah, cl
                cmp ah, 0AH
                jae sB4_AH_37H
                
                add ah, 30H
                mov es:[06H + 0A0H * 02H], ah
                jmp short sEnd_B4_AH_37H
                sB4_AH_37H:
                  add ah, 37H
                  mov es:[06H + 0A0H * 02H], ah
                sEnd_B4_AH_37H:
                
                and dh, 0FH
                cmp dh, 0AH
                jae sA4_AH_37H
                
                add dh, 30H
                mov es:[08H + 0A0H * 02H], dh
                jmp short sEnd_A4_AH_37H
                sA4_AH_37H:
                  add dh, 37H
                  mov es:[08H + 0A0H * 02H], dh
                sEnd_A4_AH_37H:
                
                shr al, cl
                cmp al, 0AH
                jae sB4_AL_37H
                
                add al, 30H
                mov es:[0AH + 0A0H * 02H], al
                jmp short sEnd_B4_AL_37H
                sB4_AL_37H:
                  add al, 37H
                  mov es:[0AH + 0A0H * 02H], al
                sEnd_B4_AL_37H:
                
                and dl, 0FH
                cmp dl, 0AH
                jae sA4_AL_37H
                
                add dl, 30H
                mov es:[0CH + 0A0H * 02H], dl
                jmp short sEnd_A4_AL_37H
                sA4_AL_37H:
                  add dl, 37H
                  mov es:[0CH + 0A0H * 02H], dl
                sEnd_A4_AL_37H:
                
              pop cx
              pop dx
              pop ax
            ret
      
      ;
      sDone_CDB_7E00:
        ;pop es
        ;pop ax
      ;ret                                              ;内部返回
    sEnd_CDB_7E00:
      ;db (offset sEnd_CDB_7E00 - offset sCDB_7E00 - 00H) dup (90H)
      db (12H) dup (90H)
      nop
    
  msCode ends
end sMain
	
