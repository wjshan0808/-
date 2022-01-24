;ASM
;17.2.17.1 编程接收用户键盘输入
;           "r"=将屏幕字符设置为红色
;           "g"=将屏幕字符设置为绿色
;           "b"=将屏幕字符设置为蓝色
;
;参数
;
;资料
;       7   6  5  4   3   2  1  0
;       BL  R  G  B   I   R  G  B
;      闪烁   背景  高亮   前景
;

assume cs:msCode
  
  msCode segment
sMain:
    
    mov ah, 00H                         ;读取键盘输入
    int 16H                             ;(ah)=扫描码 (al)=ASCII码
    
    mov ah, 01H
    cmp al, 'b'                         ;比较输入字符
    je sBlue_FColor
    cmp al, 'r'
    je sRed_FColor
    cmp al, 'g'
    je sGreen_FColor
    
    jmp short sEnd_FColor               ;结束
    
    sRed_FColor:
      shl ah, 01H
    sGreen_FColor:
      shl ah, 01H
    
    sBlue_FColor:
      mov bx, 0B800H
      mov es, bx
      mov di, 01H                         ;字符地址
      mov cx, 07D0H
      sFColor_Screen:
          and byte ptr es:[di], 0F8H
          or byte ptr es:[di], ah
          add di, 02H
        loop sFColor_Screen

    sEnd_FColor:
      
    ;
    mov ax, 4c00H
    int 21H
    
    
  msCode ends
end sMain
	
