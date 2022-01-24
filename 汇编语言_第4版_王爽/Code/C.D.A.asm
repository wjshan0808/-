;ASM
;Course Design A
;     将实验7的数据按照表格格式在屏幕显示
;       年份      收入      人数        人均
;       1975        16         3           5
;                        ...
;
;资料
; 每行显示80个字符, 每列占用20个字符
;

assume cs:msCode
  
  msTable segment
    ;年份
    db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982'
    db '1983', '1984', '1985', '1986', '1987', '1988', '1989', '1990'
    db '1991', '1992', '1993', '1994', '1995'
    ;收入
    dd 16, 22, 382, 1356, 2390, 8000, 16000, 24486
    dd 50065, 97479, 140417, 197514, 345980, 590827, 803530, 1183000
    dd 1843000, 2759000, 3753000, 4649000, 5937000
    ;人数
    dw 3, 7, 9, 13, 28, 38, 130, 220
    dw 476, 778, 1001, 1442, 2258, 2793, 4037, 5635
    dw 8226, 11542, 14430, 15257, 17800
  msTable ends
  
  msData segment
    db 10H (00H)
  msData ends
  
  msCode segment    
sMain:
    
    mov ax, msTable
    mov es, ax
    mov ax, msData
    mov ds, ax
    
    
    mov dh, 02H                     ;(dh)=行号(0~24),
    mov dl, 02H                     ;(dl)=列号(0~79),
    mov si, 00H                     ;ds:si=字符串首地址
    mov bp, 00H                     ;目标字符串首地址
    mov cx, 15H                     ;循环21次
    sYear_Display:
        push cx       
          mov cl, 02H                 ;设置字符属性
          mov ch, 00H
          
          mov ax, es:[bp + 00H]       ;将年份字符串转化为以0结尾的格式
          mov ds:[00H], ax
          mov ax, es:[bp + 02H]
          mov ds:[02H], ax
          
          call func_String_Show        
          add bp, 04H                 ;递增目标地址
          add dh, 01H                 ;递增行号
        pop cx
      loop sYear_Display
        
    
    mov dh, 02H                     ;(dh)=行号(0~24),
    mov dl, 0EH                     ;(dl)=列号(0~79),
    mov si, 00H                     ;ds:si=字符串首地址
    mov bp, 00H                     ;目标字符串首地址
    mov cx, 15H                     ;循环21次
    sRevenue_Display:
        push cx       
          mov cl, 02H                 ;设置字符属性
          mov ch, 00H
            push dx
            
              mov ax, es:[bp + 00H + 54H] ;取收入数据
              mov dx, es:[bp + 02H + 54H]
              call func_DWord_2_String
            
            pop dx
          call func_String_Show        
          add bp, 04H                 ;递增目标地址
          add dh, 01H                 ;递增行号
        pop cx
      loop sRevenue_Display
      
      
    mov dh, 02H                     ;(dh)=行号(0~24),
    mov dl, 1AH                     ;(dl)=列号(0~79),
    mov si, 00H                     ;ds:si=字符串首地址
    mov bp, 00H                     ;目标字符串首地址
    mov cx, 15H                     ;循环21次
    sPeople_Display:
        push cx       
          mov cl, 02H                 ;设置字符属性
          mov ch, 00H
            push dx
            
              mov ax, es:[bp + 00H + 54H + 54H] ;取人数
              call func_Word_2_String
            
            pop dx
          call func_String_Show        
          add bp, 02H                 ;递增目标字符串地址
          add dh, 01H                 ;递增行号
        pop cx
      loop sPeople_Display
      
      
    mov dh, 02H                     ;(dh)=行号(0~24),
    mov dl, 22H                     ;(dl)=列号(0~79),
    mov si, 00H                     ;ds:si=字符串首地址
    mov bp, 00H                     ;目标字符串首地址
    mov bx, 00H                     ;目标字符串首地址
    mov cx, 15H                     ;循环21次
    sAvg_Display:
        push cx       
          mov cl, 02H                 ;设置字符属性
          mov ch, 00H
            push dx
            push cx
              
              mov ax, es:[bx + 00H + 54H] ;取收入数据
              mov dx, es:[bx + 02H + 54H]            
              mov cx, es:[bp + 00H + 54H + 54H] ;取人数
              call func_Div_No_Overflow    
              
              call func_DWord_2_String
            
            pop cx
            pop dx
          call func_String_Show        
          add bx, 04H                 ;递增目标地址
          add bp, 02H                 ;递增目标地址
          add dh, 01H                 ;递增行号
        pop cx
      loop sAvg_Display
      
    ;
    mov ax, 4c00H
    int 21H
    
    
;参数
;   (ax)=被除数的低16位,
;   (dx)=被除数的高16位,
;   (cx)=除数
;返回
;   (ax)=商的低16位,
;   (dx)=商的高16位,
;   (cx)=余数    
    func_Div_No_Overflow:
        push bx               ;借用BX寄存器
          
          push ax             ;保存原始 被除数的低16位
          
            push dx           ;保存原始 被除数的高16位
            mov dx, 0000H     ;构造 新被除数的高16位
            pop ax            ;构造 新被除数的低16位 公式(H/N)中将参数(DX)给(AX)
            
            div cx            ;计算公式(H/N)
            mov bx, ax        ;保存公式(H/N)的商于(BX)即公式(int(H/N) * 10000H)的值
            
            ;mov dx, dx       ;公式(H/N)的余数在(DX)中隐含实现了(rem(H/N) * 10000H)(再个新被除数的高16位)
          pop ax              ;取出原始 被除数的低16位 存放于 (再个新被除数的低16位(AX)中)
            div cx            ;计算公式((rem(H/N) * 10000H + L) / N)
          
            mov cx, dx        ;取公式((rem(H/N) * 10000H + L) / N)余数于(CX)中返回
            ;mov ax, ax       ;取公式((rem(H/N) * 10000H + L) / N)的商于(AX)中做返回的商的低16位(已隐含实现)
            mov dx, bx        ;取(BX)值做返回的商的高16位
          
        pop bx                ;归还BX寄存器
      ret
    
    
;参数
;   (ax)=word型数据,
;   ds:si=指向字符串的首地址    
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
        
    
;参数
;   (ax)=dword型数据的低16位,
;   (dx)=dword型数据的高16位,
;   ds:si=指向字符串的首地址    
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
      
    
;参数    
;   (dh)=行号(0~24),
;   (dl)=列号(0~79),
;   (cl)=颜色,
;   ds:si=字符串首地址
    func_String_Show:
        push ax                     ;借用寄存器
        push es
        push bx
        push cx
        push si
      
          mov ax, 0B800H            ;默认显存第一页
          mov es, ax
          
          mov al, 0A0H              ;设置每行行偏移量
          mul dh                    ;字符行首地址(AX)=(AL)*(DH)
          mov bx, ax                ;暂存行首地址
          
          mov al, 02H
          mul dl                    ;字符行偏移地址(AX)=(AL)*(DL)
          
          add bx, ax                ;字符显示起始地址(BX)
          
          mov ah, cl                ;设置高8位字符属性
          
          mov ch, 00H               ;重置字符高8位
          sChar_String:
            mov cl, [si]            ;获取字符
            jcxz sEnd_Char_String   ;若(CX)=0则字符获取完毕
            inc si                  ;递增遍历字符索引
            
            mov al, cl              ;设置低8位字符值
            mov es:[bx], ax         ;将字符输出到显存
            add bx, 02H             ;递增下一字符输出显存地址索引
            
            jmp short sChar_String  ;若(CX)!=0则继续读取字符
            sEnd_Char_String:
        
        pop si                      ;归还寄存器
        pop cx
        pop bx
        pop es
        pop ax
      ret
      
      
  msCode ends

end sMain
	
