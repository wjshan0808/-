;ASM
;10.10.12.10.1
;函数
;     在指定的位置, 用指定的颜色显示一个以0结束的字符串
;参数
;     (dh)=行号(0~24),
;     (dl)=列号(0~79),
;     (cl)=颜色,
;     ds:si=字符串首地址
;返回
;     无
;资料
;     页码          偏移地址
;       00     0B8000~0B8F9F
;       01     0B8FA0~0B9F3F
;       02     0B9F40~0BAEDF
;          ...
;       07     0BED60~0BFCFF
;     行号          偏移地址
;       00         0000~009F
;       01         00A0~013F
;       02         0140~01DF
;            ...
;       24         0F00~0F9F
; 每行160字节, 一列占用2个字节, 低字节存储字符, 高字节存储属性
;     属性
;        7   6  5  4     3   2  1  0
;     闪烁  红 绿 蓝  高亮  红 绿 蓝
;             背景            前景
;

assume cs:msCode
  
  msData segment
    db 'Welcome to masm!', 00H
  msData ends
  
  msCode segment    
sMain:
    
    mov dh, 01H     ;测试
    mov dl, 46H
    mov cl, 02H
    mov ax, msData
    mov ds, ax
    mov si, 00H
    call func_String_Show
    
    ;
    mov ax, 4c00H
    int 21H
    
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
	
