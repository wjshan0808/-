;ASM
;13.2.2
;函数
;     编写安装7CH中断例程, 将一个全是字母以0结尾的字符串转为大写
;参数
;     ds:si=指向字符串的首地址
;返回
;     无
;资料
;     字符转换大写 and al, 0DFH
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
    mov si, offset func_Char_2_Upper_Int7C
    
    cld                       ;正向复制代码至目标内存
    mov cx, (offset sEnd_Char_2_Upper_Int7C - offset func_Char_2_Upper_Int7C)
    rep movsb
    
                              ;注册中断向量表
    mov word ptr es:[7CH * 04H + 00H], 0200H
    mov word ptr es:[7CH * 04H + 02H], 0000H

                              ;测试
    mov ax, msData
    mov ds, ax
    mov si, 00H
    int 7CH
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Char_2_Upper_Int7C:
                                          ;暂借寄存器
      push cx
      push si
        
        sDo_Char_2_Upper_Int7C:
          mov cl, ds:[si]                 ;取字符值
          mov ch, 00H
          jcxz sDone_Char_2_Upper_Int7C
          
          and cl, 0DFH                    ;转换字符大写
          mov ds:[si], cl
          
          inc si                          ;下一字符
          jmp short sDo_Char_2_Upper_Int7C
        
        sDone_Char_2_Upper_Int7C:
        
                                          ;归还寄存器
      pop si                              
      pop cx
      
      iret                                ;结束
      sEnd_Char_2_Upper_Int7C:
        nop
    
  msCode ends
end sMain
	
