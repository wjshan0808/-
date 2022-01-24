;ASM
;13.3.13.1.2
;函数
;     编写安装7CH中断例程, 完成jmp near ptr指令的功能
;参数
;     (BX)=存放转移位移
;返回
;     无
;资料
; int指令功能                       iret指令功能       jmp near ptr指令功能
;   a.获取中断码N                     a.pop ip           a.(IP)=(IP)+16位位移
;   b.pushf                           b.pop cs
;   c.(TF)=0, (IF)=0                  c.popf
;   d.push cs
;   e.push ip
;   f.(IP)=(N*04), (CS)=(N*04+02)
; 

assume cs:msCode

  msData segment
    db 'conversation', 00H
  msData ends
  
  msCode segment
sMain:

    mov ax, 0000H             ;安装目标地址段
    mov es, ax
    mov di, 0200H             ;安装目标地址偏移
    
    mov ax, cs                ;程序源地址段
    mov ds, ax                ;程序源地址偏移
    mov si, offset func_jmp_near_ptr_Int7C
    
    cld                       ;正向复制代码至目标内存
    mov cx, (offset sEnd_jmp_near_ptr_Int7C - offset func_jmp_near_ptr_Int7C)
    rep movsb
    
                              ;注册中断向量表
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 0000H

                              ;测试
    mov ax, msData
    mov ds, ax
    mov si, 00H
    
    mov ax, 0B800H
    mov es, ax
    mov di, 0A0H * 0CH + 00H
    
    sIsZero:
      cmp byte ptr [si], 00H
      je sZero
      
      mov al, [si]
      mov es:[di], al
      inc si
      add di, 02H
      
      mov bx, (offset sIsZero - offset sZero)
      int 7CH
      
    sZero:
      
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_jmp_near_ptr_Int7C:
                                        ;暂借寄存器
      push bp
        
        mov bp, sp                      ;堆栈地址
        add [bp + 02H], bx              ;定位ip值进行位移
          
                                        ;归还寄存器
      pop bp
      
      iret                              ;结束
      sEnd_jmp_near_ptr_Int7C:
        nop
    
  msCode ends
end sMain
	
