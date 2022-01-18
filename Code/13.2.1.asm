;ASM
;13.2.1
;函数
;     编写安装7CH中断例程, 求word型数据的平方
;参数
;     (AX)=word型数据
;返回
;     (AX)=结果的低16位
;     (DX)=结果的高16位
;资料
;
;

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, 0000H             ;安装目标地址段
    mov es, ax
    mov di, 0200H             ;安装目标地址偏移
    
    mov ax, cs                ;程序源地址段
    mov ds, ax                ;程序源地址偏移
    mov si, offset func_Square_Int7C
    
    cld                       ;正向复制代码至目标内存
    mov cx, (offset sEnd_Square_Int7C - offset func_Square_Int7C)
    rep movsb
    
                              ;注册中断向量表
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 0000H

                              ;测试
    mov ax, 0D80H             
    int 7CH
    
    add ax, ax                ;结果*2
    adc dx, dx
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Square_Int7C:
      mul ax                  ;word型数据的平方
      
      iret
      sEnd_Square_Int7C:
        nop
    
  msCode ends
end sMain
	
