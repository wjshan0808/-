;ASM
;17.3.17.1 编写接收字符串输入的子程序
;
;参数
;     (ah)=功能号
;     (al)=字符值
;     (dh)=字符串在屏幕上显示的行
;     (dl)=字符串在屏幕上显示的列
;     ds:si=字符串存储空间以0结尾
;资料
;
;问题
;     a. 没有输入换行
;     b. 没有程序开始位置做输入点
;

assume cs:msCode

  msData segment
    db 04A0H dup (00H)
  msData ends
  
  msCode segment
sMain:

    mov ax, msData
    mov ds, ax
    mov si, 00H

    mov dh, 18H                             ;行号
    mov dl, 00H                             ;列号
    call func_String_Input
    
    ;
    mov ax, 4c00H
    int 21H
    
    ;
    func_String_Input:
        push ax
        
            ;mov al, 20H ;-
          sString_Input:
            mov ah, 00H                     ;获取键盘输入
            int 16H
            
            cmp al, 20H                     ;ASCII码>=20H
            jb sCtrl_Input
            
            mov ah, 00H                     ;字符输入
            call func_Char_Input
            ;dec al ;-
            ;mov ah, 0EH ;-
            jmp short sString_Input         ;循环
          
            sCtrl_Input:
              cmp ah, 0EH                   ;Backspace键扫描码
              je sBackspace_Key
              cmp ah, 1CH                   ;Enter键扫描码
              je sEnter_Key
              
              jmp short sString_Input       ;循环
          
              ;
              sBackspace_Key:
                mov ah, 01H                 ;删除字符
                call func_Char_Input
                jmp short sString_Input     ;循环
              
              ;
              sEnter_Key:
                mov al, 00H                 ;以0结束字符区
                mov ah, 00H
                call func_Char_Input        ;
              
        pop ax
      ret
    
    ;
    func_Char_Input:
        jmp short sDo_Char_Input
        
        funcs dw func01_Add, func23_Del, func45_Show
        input dw 00H                                ;输入字符地址
        rows  db 00H                                ;光标行(dh)
        cols  db 00H                                ;光标列(dl)
        
        sDo_Char_Input:
          push ax
          push bx
          push dx
          push es
          push di
          
            cmp ah, 02H
            ja sJA_Shot                             ;功能号<=02H
            
            mov bh, 00H
            mov bl, ah
            add bx, bx
            jmp word ptr funcs[bx]                  ;功能执行
            
            sJA_Shot:
              jmp near ptr sEnd_Char_Input
            
            ;
            func01_Add:
                                                    ;超过一行
                mov bx, input
                mov ds:[bx + si], al                ;添加字符
                
                inc input                           ;前移输入
                inc cols                            ;前移光标
                
                push dx
                  mov ah, 02H                       ;光标功能
                  mov bh, 00H                       ;第0页
                  add dh, rows                      ;dh行号
                  add dl, cols                      ;dl列号
                  int 10H
                pop dx
                
                jmp short func45_Show               ;显示
                
            ;
            func23_Del:
                cmp input, 00H                      ;没有字符
                je sEnd_Char_Input
                
                dec input                           ;后移输入
                dec cols                            ;后移光标
                
                push dx
                  mov ah, 02H                       ;光标功能
                  mov bh, 00H                       ;第0页
                  add dh, rows                      ;dh行号
                  add dl, cols                      ;dl列号
                  int 10H
                pop dx
                
                jmp short func45_Show               ;显示
                
            ;
            func45_Show:
                mov bx, 0B800H
                mov es, bx
                
                mov ah, 00H
                mov al, 0A0H
                mul dh                              ;计算字符显示行(AX)
                mov di, ax
                
                mov dh, 00H
                add dl, dl                          ;计算字符显示列(DX)
                add di, dx
                
                mov bx, 00H
                sChar_Show:
                  cmp bx, input
                  jb sThe_Char_Show
                  
                  mov byte ptr es:[di], ' '         ;光标处设置空格
                  jmp short sEnd_Char_Input
                  
                  sThe_Char_Show:
                    mov al, ds:[bx + si]
                    mov es:[di], al                 ;显示字符区内容
                    add di, 02H
                    inc bx
                    jmp sChar_Show
                  
                jmp short sEnd_Char_Input
              
    
        sEnd_Char_Input:
          pop di
          pop es
          pop dx
          pop bx
          pop ax
      ret
    
  msCode ends
end sMain
	
