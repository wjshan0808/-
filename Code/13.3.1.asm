;ASM
;13.3.1
;函数
;     编写安装7CH中断例程, 完成loop指令的功能
;参数
;     (CX)=存放循环次数
;     (BX)=存放ip位移
;返回
;     无
;资料
; int指令功能                       iret指令功能       loop指令功能
;   a.获取中断码N                     a.pop ip           a.(CX)=(CX)-1
;   b.pushf                           b.pop cs           b.(CX)!=0 转至标号处执行
;   c.(TF)=0, (IF)=0                  c.popf               (CX)==0 执行下一条指令
;   d.push cs
;   e.push ip
;   f.(IP)=(N*04), (CS)=(N*04+02)
; 

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, 0000H             ;安装目标地址段
    mov es, ax
    mov di, 0200H             ;安装目标地址偏移
    
    mov ax, cs                ;程序源地址段
    mov ds, ax                ;程序源地址偏移
    mov si, offset func_Loop_Int7C
    
    cld                       ;正向复制代码至目标内存
    mov cx, (offset sEnd_Loop_Int7C - offset func_Loop_Int7C)
    rep movsb
    
                              ;注册中断向量表
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 0000H

                              ;测试
    mov ax, 0B800H
    mov es, ax
    mov di, 0A0H * 0CH + 00H
    
    mov cx, 50H
    mov bx, (offset sDo_Loop - offset sDone_Loop)
    sDo_Loop:
      mov byte ptr es:[di], '!'
      add di, 02H
      int 7CH
      sDone_Loop:
        nop
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Loop_Int7C:
                                        ;暂借寄存器
      push bp
        
        dec cx                          ;递减cx
        jcxz sDone_Loop_Int7C
        
        mov bp, sp                      ;堆栈地址
        add ss:[bp + 02H], bx           ;定位ip值进行位移
          
        sDone_Loop_Int7C:
                                        ;归还寄存器
      pop bp
      
      iret                              ;结束
      sEnd_Loop_Int7C:
        nop
    
  msCode ends
end sMain
	
