;ASM
;17.4 将当前屏幕的内容保存在磁盘
;
;

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, 00H
    mov es, ax
    mov bx, 0200H          ;es:bx=接收数据的内存区
    
    mov ah, 02H            ;读扇区功能
    mov al, 01H            ;扇区数
    mov cl, 01H            ;扇区号从1开始
    mov ch, 00H            ;磁道号
    mov dh, 00H            ;面(磁头号)
    mov dl, 00H            ;驱动器号(0:软驱A, 1:软驱B, 80H:硬盘C, 81H:硬盘D )
    int 13H                ;返回成功(ah)=0, (al)=读入的扇区数
                           ;返回失败(ah)=错误码
    
    mov ax, 0B800H
    mov es, ax
    mov bx, 00H            ;es:bx=写入数据的内存区
    
    mov ah, 03H            ;写扇区功能
    mov al, 08H            ;扇区数
    mov cl, 01H            ;扇区号从1开始
    mov ch, 00H            ;磁道号
    mov dh, 00H            ;面(磁头号)
    mov dl, 00H            ;驱动器号(0:软驱A, 1:软驱B, 80H:硬盘C, 81H:硬盘D )
    int 13H                ;返回成功(ah)=0, (al)=写入的扇区数
                           ;返回失败(ah)=错误码
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
end sMain
	
