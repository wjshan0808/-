;ASM
;12.12
;函数
;     编写0号中断处理程序
;参数
;     无
;返回
;     无
;资料
;     一般情况从0000:0200~0000:02FF的256个字节的空间所对应的中断向量表是空的
;

assume cs:msCode
  
  msCode segment
sMain:
    
    mov ax, 0000H                           ;安装代码段地址
    mov es, ax
    mov di, 0200H                           ;安装代码偏移地址    

    mov ax, cs                              ;安装代码起始段
    mov ds, ax
    mov si, offset func_Custom_Int0         ;安装代码起始偏移 
    
    cld                                     ;安装代码正向增长
                                            ;安装代码长度
    mov cx, offset sEnd_Code_Custom_Int0 - offset func_Custom_Int0
    rep movsb                               ;安装代码    
    
    mov word ptr es:[00H * 04H + 00H], 0200H;注册0号中断低2字节(IP)值
    mov word ptr es:[00H * 04H + 02H], 0000H;注册0号中断高2字节(CS)值
    
    int 00H
    ;call dword ptr es:[00H * 04H]
    ;
    mov ax, 4c00H
    int 21H
    
    func_Custom_Int0:
      push ax
      push ds
      push si
      push es
      push di
      push cx
        
        jmp sCode_Custom_Int0
        
        sData_Custom_Int0:
          db "Divide Error !!!"
        
          sCode_Custom_Int0:
            mov ax, cs                        ;数据段即为代码段
            mov ds, ax
                                              ;偏移jmp长度
            mov si, 0200H + (offset sData_Custom_Int0 - offset func_Custom_Int0)
            
            mov ax, 0B800H                    ;显存第一页
            mov es, ax                        ;中间位置
            mov di, 0A0H * 0CH + 0A0H / 02H - 10H   
            
            mov cx, 10H                       ;字符长度16
            sChar_Custom_Int0:
                mov ah, 02H                   ;字符颜色
                mov al, ds:[si]               ;字符值
                mov es:[di], ax
                inc si                        ;下一字符值
                add di, 02H                   ;下一字符显示地址
              loop sChar_Custom_Int0
        
      pop cx
      pop di
      pop es
      pop si
      pop ds
      pop ax
      iret
      
      sEnd_Code_Custom_Int0:
        nop
      
  msCode ends
end sMain
	
