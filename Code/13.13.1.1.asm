;ASM
;13.13.1.1
;函数
;     编写安装7CH中断例程, 显示一个用0结束的字符串
;参数
;     (dh)=行号
;     (dl)=列号
;     (cl)=颜色
;     ds:si=指向字符串首地址
;返回
;     无
;资料
; 

assume cs:msCode
  
  msData segment
    db 'Welcome to masm!', 00H
  msData ends
  
  msCode segment
sMain:

    mov ax, 0000H             ;安装目标地址段
    mov es, ax
    mov di, 0200H             ;安装目标地址偏移
    
    mov ax, cs                ;程序源地址段
    mov ds, ax                ;程序源地址偏移
    mov si, offset func_Show_Int7C
    
    cld                       ;正向复制代码至目标内存
    mov cx, (offset sEnd_Show_Int7C - offset func_Show_Int7C)
    rep movsb
    
                              ;注册中断向量表
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 0000H

                              ;测试
    mov dh, 0AH
    mov dl, 0AH
    mov cl, 02H
    mov ax, msData
    mov ds, ax
    mov si, 00H
    int 7CH
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Show_Int7C:
                                        ;暂借寄存器
      push ax
      push es
      push di
      push si
        
        mov ax, 0B800H                  ;字符段地址
        mov es, ax
        
        mov di, 00H
        mov al, dh                      ;字符行偏移量
        mov ah, 0A0H
        mul ah
        add di, ax
        
        mov ah, 00H                     ;字符列偏移量
        mov al, dl
        add di, ax
        
        mov ah, cl                      ;字符属性
        sDo_Show_Int7C:
          mov al, ds:[si]
          cmp al, 00H                   ;字符是否结束
          je sDone_Show_Int7C
          
          mov es:[di], ax               ;显示字符
          inc si                        ;下一字符
          add di, 02H
          jmp short sDo_Show_Int7C
        
        sDone_Show_Int7C:
                                        ;归还寄存器
      pop si
      pop di
      pop es
      pop ax
      
      iret                              ;结束
      sEnd_Show_Int7C:
        nop
    
  msCode ends
end sMain
	
