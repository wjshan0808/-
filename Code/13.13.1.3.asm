;ASM
;13.13.1.3 分别在屏幕2, 4, 6, 8行显示4句英文诗
; 

assume cs:msCode
  
  msCode segment
    s1 : db 'Good,better,best,', '$'
    s2 : db 'Never let it rest,', '$'
    s3 : db 'Till good is better,', '$'
    s4 : db 'And better,best.', '$'
    s  : dw offset s1, offset s2, offset s3, offset s4
    row: db 2, 4, 6, 8
  
sMain:

    mov ax, cs
    mov ds, ax                  ;数据段=代码段
    mov bx, offset s            ;4行诗的偏移地址
    mov si, offset row          ;行号偏移地址
    mov cx, 4                   ;循环4次
    
    ok:
      ;mov bl, 0CAH              ;颜色
      mov bh, 0                 ;第0页
      mov dh, [si]              ;行号
      mov dl, 0                 ;列号
      mov ah, 2                 ;2号子程序设置光标位置
      int 10H                   ;和屏幕输出相关
      
      mov dx, [bx]              ;ds:dx指向以'$'结尾的字符串
      mov ah, 9                 ;9号子程序
      int 21H                   ;在光标位置显示字符串
      
      add bx, 02H               ;增加取字符串地址
      inc si                    ;增加取行号地址
      loop ok
      
    mov ax, 4c00H
    int 21H
    
  msCode ends
end sMain
	
