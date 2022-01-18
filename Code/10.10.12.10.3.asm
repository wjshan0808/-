;ASM
;10.10.12.10.3
;函数
;     将word型数据转变为以十进制表示的以0结尾的字符串
;参数
;     (ax)=word型数据,
;     ds:si=指向字符串的首地址
;返回
;     无
;资料
;     字符'0'~'9'对应ASCII码30H~39H
;     用word型数据除0AH余数取得十进制数每位的值, 商为0时结束
;

assume cs:msCode
  
  msData segment
    db 10 dup (01H)
  msData ends
  
  msCode segment    
sMain:
    
    mov ax, 12666     ;测试
    mov bx, msData
    mov ds, bx
    mov si, 00H
    call func_Word_2_String
    
    mov dh, 08H
    mov dl, 03H
    mov cl, 02H
    call func_String_Show
    
    ;
    mov ax, 4c00H
    int 21H
    
    func_Word_2_String:
        push bx                           ;借用寄存器
        push dx
        push di
        push cx
          
          mov di, 00H                     ;初始化word数据字符位数
          mov bx, 0AH                     ;设置除数
          
          sWord_2_Char_Push:
            mov dx, 00H                   ;重置被除数高16位
            div bx
          
            push dx                       ;保存余数(从word数据低位开始的字符)
            inc di                        ;增加字符位数
            
            mov cx, ax                    ;判断商值是否为0
            jcxz sWord_2_Char_Done
            
            ;mov ax, ax                   ;设置被除数低16位
            jmp short sWord_2_Char_Push   ;循环取字符过程
          
          sWord_2_Char_Done:
            mov cx, di                    ;设置取字符次数
            mov bx, 00H                   ;设置写入字符地址偏移索引
            sWord_2_Char_Pop:
                pop dx                    ;取保存的字符(从word数据高位开始的字符)
                mov dh, 00H               ;清除字符高16位值
                add dl, 30H               ;转换字符为ASCII码
                mov ds:[bx + si], dl      ;在地址处写入字符
                inc bx                    ;递增写入字符地址偏移索引
              loop sWord_2_Char_Pop
            
            mov byte ptr ds:[bx + si], 00H;在地址处写入0值字符
          
        pop cx                            ;归还寄存器
        pop di
        pop dx
        pop bx
      ret
        
  msCode ends

end sMain
	
