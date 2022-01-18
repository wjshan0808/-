;ASM
;14.4.14.1 在屏幕中间显示CMOS RAM中存储的时间信息格式"年/月/日 时:分:秒"
;
;资料
;     CMOS RAM中长度各为一个字节的时间单元
;       秒:0 分:2 时:4 日:7 月:8 年:9 
;     值是BCD码表示高4位表示十位, 低4位表示个位
;     BCD码每4个二进制表示一个十进制
;

assume cs:msCode
  
  msData segment
    db 09H, '/', 08H, '/', 07H, ' ', 04H, ':', 02H, ':', 00H, 00H
  msData ends
  
  msCode segment
sMain:

    mov ax, msData
    mov ds, ax
    
    mov ax, 0B800H                ;字符显示段地址
    mov es, ax
    mov di, 0A0H * 0CH + 40H      ;字符显示偏移地址
    
    mov si, 00H
    mov cx, 06H
    sUnintAddress:
    
        mov al, byte ptr ds:[si + 00H]
        call func_Read_Byte_CMOS_RAM  ;获取BCD码       
        call func_BCD_2_ASCII         ;获取ASCII码
            
        mov bh, 02H                   ;字符属性
        
        mov bl, ah                    ;显示字符
        mov es:[di + 00H], bx
        mov bl, al
        mov es:[di + 02H], bx
        
        mov bl, byte ptr ds:[si + 01H];显示字符
        mov es:[di + 04H], bx
        
        add di, 06H
        add si, 02H
        
      loop sUnintAddress
    
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_BCD_2_ASCII:
        push cx
        
          mov ah, al         ;保存副本
          
          and al, 0FH        ;获取低4位值
          add al, 30H        ;转换为ASCII码
          
          mov cl, 04H
          shr ah, cl         ;获取高4位值
          add ah, 30H        ;转换为ASCII码
          
        pop cx
      ret
    
    func_Read_Byte_CMOS_RAM:
        ;mov al, 00H          ;向地址端口写入al号单元数据地址
        out 70H, al
        in al, 71H           ;从数据端口读取al号单元值
      ret
      
  msCode ends
end sMain
	
