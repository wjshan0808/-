;ASM
;16.3.2 编写子程序, 计算sin(x), x={0, 30, 60, 90, 120, 150, 180}度
;
;参数
;     (ax)=角度
;
;
;资料
;     麦克劳林公式计算Sin(x), x=角度
;                          1           1
;   Sin(x)= sin(y) => y - --- * y^3 + --- * y^5
;                          3!          5!
;                    x
;               y = --- * 3.1415926
;                   180
;

assume cs:msCode
  
  msCode segment
sMain:

    mov ax, 182
    call func_Sin_Show
    
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Sin_Show:
        jmp short sDo_Sin_Show
                    ;0       1       2       3       4       5       6
                    ;01      23      45      67      89      ab      cd
          degs    dw deg000, deg030, deg060, deg090, deg120, deg150, deg180   ;offset deg*
          deg000  db '0.0', 00H
          deg030  db '0.5', 00H
          deg060  db '0.866', 00H
          deg090  db '1.0', 00H
          deg120  db '0.866', 00H
          deg150  db '0.5', 00H
          deg180  db '0', 00H
        
        sDo_Sin_Show:
          push bx
          push es
          push di
                                          ;暂借寄存器
            mov bx, 0B800H
            mov es, bx
            mov di, 0A0H * 0CH + 50H
            
            mov ah, 00H                   ;角度(被除数)
            
            cmp al, 0B4H                  ;大于180度结束
            ja sEnd_Sin_Show
            
            mov bl, 1EH                   ;30度(除数)
            div bl
            
            cmp ah, 00H                   ;余数不等于0结束
            jne sEnd_Sin_Show
            
            mov bl, al                    ;偏移索引(商)
            mov bh, 00H
            add bx, bx
            mov bx, degs[bx]              ;值首偏移地址
            
            sValue_Sin_Show:
              mov ah, cs:[bx]
              cmp ah, 00H                 ;结束显示
              je sEnd_Sin_Show
              mov es:[di], ah             ;显示字符
              inc bx                      ;下一字符
              add di, 02H
              jmp short sValue_Sin_Show
            
        sEnd_Sin_Show:
                                          ;归还寄存器
          pop di
          pop es
          pop bx
      ret
      
  msCode ends
end sMain
	
