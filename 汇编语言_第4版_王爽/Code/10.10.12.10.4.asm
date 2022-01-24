;ASM
;10.10.12.10.4
;函数
;     将dword型数据转变为以十进制表示的以0结尾的字符串
;参数
;     (ax)=dword型数据的低16位,
;     (dx)=dword型数据的高16位,
;     ds:si=指向字符串的首地址
;返回
;     无
;资料
;     字符'0'~'9'对应ASCII码30H~39H
;     用dword型数据除0AH余数取得十进制数每位的值, 商为0时结束
;
;     标识              描述            范围
;        X            被除数   [0, FFFFFFFF]
;        N              除数       [0, FFFF]
;        H    被除数的高16位       [0, FFFF]
;        L    被除数的低16位       [0, FFFF]
;    int()      描述运算取商    int(38/10)=3
;    rem()      描述运算取余    rem(38/10)=8
;公式
;     X/N = int(H/N) * 10000H + (rem(H/N) * 10000H + L) / N
;技巧
;     公式中(* 10000H)意味着低16位值变为高16位值
;     公式中( + )意味着高16位值与低16位值的组合
;

assume cs:msCode
  
  msData segment
    db 10 dup (01H)
  msData ends
  
  msCode segment    
sMain:
    
    mov ax, 4240H     ;测试
    mov dx, 000FH
    mov bx, msData
    mov ds, bx
    mov si, 00H
    call func_DWord_2_String
    
    mov dh, 08H
    mov dl, 03H
    mov cl, 02H
    call func_String_Show
    
    ;
    mov ax, 4c00H
    int 21H
    
    func_DWord_2_String:
        push di                             ;借用寄存器
        push si
        push bx
        push ax
        push dx
        push cx
          
          mov di, 00H                       ;初始化dword数据字符位数
          mov si, 0AH                       ;设置除数
            
          sDWord_2_Char_Push:
            mov bx, ax                     ;保存被除数低16位
            mov ax, dx                     ;设置被除数低16位根据公式(H/N)
            mov dx, 00H                    ;设置被除数高16位
            div si                         ;计算公式(H/N)
            ;mov dx, dx                    ;余数为新被除数的高16位
              push ax                      ;商保存为下一轮的数据的高16位
                mov ax, bx                 ;设置新被除数低16位根据公式(rem(H/N) * 10000H + L)
                div si                     ;新的商为下一轮的数据的低16位
                mov bx, dx                 ;余数为dword数据从低位开始的字符
              pop dx                       ;还原下一轮的数据的高16位
            
            push bx                        ;保存dword数据从低位开始的字符
            inc di                         ;增加字符位数
            
            mov bx, 00H                    ;判断商值是否为0
            or bx, dx
            or bx, ax
            mov cx, bx
            jcxz sDWord_2_Char_Done 
            
            jmp short sDWord_2_Char_Push   ;循环取字符过程
            
          sDWord_2_Char_Done: 
            mov cx, di                     ;设置取字符次数
            mov si, 00H                    ;设置写入字符地址偏移索引
            sDWord_2_Char_Pop:  
                pop dx                     ;取保存dword数据从低位开始的字符
                mov dh, 00H                ;清除字符高16位值
                add dl, 30H                ;转换字符为ASCII码
                mov ds:[si], dl            ;在地址处写入字符
                inc si                     ;递增写入字符地址偏移索引
              loop sDWord_2_Char_Pop  
              
            mov byte ptr ds:[bx + si], 00H ;在地址处写入0值字符
            
        pop cx                             ;归还寄存器
        pop dx
        pop ax
        pop bx
        pop si
        pop di
      ret
      
  msCode ends

end sMain
	
