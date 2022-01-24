;ASM
;C.5.3 超简单的printf函数, 只简单支持'%c’, '%d'即可
;
;

assume cs:msCode
  
  msData segment
    dw 20H dup (0000H) 
  msData ends
  
  msCode segment
sMain:

    mov ax, msData                    ;设置段
    mov ds, ax
    mov ss, ax
    mov sp, 40H                       ;初始化栈顶

                                      ;输入已知参数("d=%d, c=%c", 0x0d, 0x63)(需非解析字符为成对)
    mov ax, 63H
    push ax
    mov ax, 0DH
    push ax
    mov ax, '%c'
    push ax
    mov ax, 'c='
    push ax
    mov ax, ', '
    push ax
    mov ax, '%d'
    push ax
    mov ax, 'd='
    push ax
    mov ax, 05H                       ;字符串长度05(Word)
    push ax

    ;
    call func_Simple_Printf
    
    ;
    mov ax, 4c00H
    int 21H
    

    func_Simple_Printf:
        push bp
        push ax
        push es
        push di
        push si
        push cx
        push bx
        push dx
        
          mov bp, sp
          add bp, 10H                               ;函数内部push数量
          add bp, 02H                               ;定位参数位置
          
          mov ax, 0B800H                            ;屏幕位置
          mov es, ax
          mov di, 0640H
          
          xor si, si
          mov cx, [bp + si]                         ;栈中字符数量
          
          mov bx, cx                  
          add bx, bx
          add bx, bp
          add bx, 02H                               ;栈中参数偏移量
          sLoop_Simple_Printf:
              add si, 02H
              mov ax, [bp + si]
              
              cmp ax, '%c'
              je s2C_Loop_Simple_Printf
              cmp ax, '%d'
              je s2D_Loop_Simple_Printf
              jmp short sChar_Loop_Simple_Printf
              
              ;%d解析
              s2D_Loop_Simple_Printf:
                  mov ax, ss:[bx]                   ;取栈中参数
                  add bx, 02H
                  mov dl, 0AH
                  ;循环打印
                  sDo_2D_Loop_Simple_Printf:
                    div dl
                    
                    cmp al, 00H                     ;商是否为0
                    je sEnd_2D_Loop_Simple_Printf
                    
                    mov es:[di], al                 ;打印商
                    add byte ptr es:[di], 30H
                    add di, 02H
                    
                    ;shr ax, 08H
                    mov al, ah
                    and ax, 0FH
                    jmp short sDo_2D_Loop_Simple_Printf
                  
                  ;结束
                  sEnd_2D_Loop_Simple_Printf:
                    mov es:[di], ah                 ;打印余数
                    add byte ptr es:[di], 30H
                    add di, 02H
                  
                jmp short sEnd_Loop_Simple_Printf
              
              ;%c解析
              s2C_Loop_Simple_Printf:
                  mov ax, ss:[bx]                   ;取栈中参数
                  add bx, 02H
                  mov es:[di], al
                  add di, 02H
                jmp short sEnd_Loop_Simple_Printf
              
              ;正常字符
              sChar_Loop_Simple_Printf:
                mov es:[di], ah
                add di, 02H
                mov es:[di], al
                add di, 02H
              
          sEnd_Loop_Simple_Printf:
            loop sLoop_Simple_Printf
        
        pop dx
        pop bx
        pop cx
        pop si
        pop di
        pop es
        pop ax
        pop bp
      ret 10H                         ;恢复调用函数之前的堆栈(8个push16字节)
      
    
  msCode ends
end sMain
	
