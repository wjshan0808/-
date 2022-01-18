;ASM
;10.10.12.10.2
;函数
;     进行不会产生溢出的除法运算, 被除数(dword类型), 除数(word类型), 商(dword类型), 余数(word类型)
;参数
;     (ax)=被除数的低16位,
;     (dx)=被除数的高16位,
;     (cx)=除数
;返回
;     (ax)=商的低16位,
;     (dx)=商的高16位,
;     (cx)=余数
;资料
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
  
  msCode segment    
sMain:
    
    mov ax, 4240H     ;测试
    mov dx, 000FH
    mov cx, 0AH
    call func_Div_No_Overflow    
    
    ;
    mov ax, 4c00H
    int 21H
    
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
    
  msCode ends

end sMain
	
