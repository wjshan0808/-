;ASM
;11.6
;     两数相加
;参数
;     (ax)=第一个数的字单元个数,
;     (bx)=第二个数的字单元个数,
;     ds:si=指向第一个数的内存空间,
;     es:di=指向第二个数的内存空间
;返回
;     结果存放于字单元个数大的内存空间中, 
;     若字单元个数相同存放于第二个数的内存空间中
;
assume cs:msCode

  msData segment
    dw 02H dup (0F1EH, 2D3CH, 4B5AH, 0000H)
    dw 01H dup (0FFEEH, 0DDCCH, 0BBAAH, 6978H)
  msData ends
  
    msCode segment
  sMain:
      mov ax, 03H    ;测试
      mov bx, 04H
      mov si, 00H
      mov di, 10H
      mov dx, msData
      mov ds, dx
      mov dx, msData
      mov es, dx
      call func_Bigger_Add
      
      ;
      mov ax, 4c00H
      int 21H
      
      
      func_Bigger_Add:
          pushf                         ;借用寄存器
          push dx
          push ds
          push es
          push si
          push di
          push cx
          
            cmp ax, bx                  ;保证(AX)>(BX), 向es:di地址存结果
            ja sBigger_Add_Long              ;>
            
            mov dx, ax                  ;(AX)<=(BX)交换数据长度
            mov ax, bx
            mov bx, dx
            jmp short sBigger_Add_Init            
            sBigger_Add_Long:           ;(AX)>(BX)
              mov dx, ds                ;交换数据段地址
              mov cx, es
              mov ds, cx
              mov es, dx
              mov dx, si                ;交换数据偏移地址
              mov si, di
              mov di, dx
              jmp short sBigger_Add_Init
            
            sBigger_Add_Init:
              sub dx, dx                ;重置标识符(CF)=0
            
            mov cx, bx                  ;最小相等长度数据相加
            sBigger_Add_Equal:
                mov dx, ds:[si]
                adc es:[di], dx         ;值相加再加进位
                inc si                  ;不影响(CF)值
                inc si
                inc di
                inc di
              loop sBigger_Add_Equal
            
            adc word ptr es:[di], 0000H ;最高位值加再加进位
            
          
          pop cx                        ;归还寄存器
          pop di
          pop si
          pop es
          pop ds
          pop dx
          popf
        ret
        
    msCode ends
end sMain