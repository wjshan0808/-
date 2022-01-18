;ASM
;11.7
;     两数相减
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
    dw 02H dup (0F1EH, 2D3CH, 005AH, 0000H)
    dw 02H dup (0FFEEH, 0DDCCH, 0000H, 0000H)
  msData ends
  
    msCode segment
  sMain:
      mov ax, 06H    ;测试
      mov bx, 04H
      mov si, 00H
      mov di, 10H
      mov dx, msData
      mov ds, dx
      mov es, dx
      call func_Bigger_Sub
      
      ;
      mov ax, 4c00H
      int 21H
      
      
      func_Bigger_Sub:
          pushf                            ;借用寄存器
          push dx
          push si
          push di
          push cx
          
            cmp ax, bx                     ;比较大小
            ja sBigger_Sub_Long            ;>
            jna sBigger_Sub_Short          ;<=
            
            sBigger_Sub_Long:              ;(AX)>(BX)              
              sub dx, dx                   ;重置标识符(CF)=0
              mov cx, bx                   ;最小相等长度数据相减
              
              sBigger_Sub_Long_Equal:
                  mov dx, es:[di]
                  sbb ds:[si], dx          ;值相减再减借位
                  inc si                   ;不影响(CF)值
                  inc si
                  inc di
                  inc di
                loop sBigger_Sub_Long_Equal
              
              sbb word ptr ds:[si], 0000H  ;高位值减再减借位  
              jmp short sBigger_Sub_End
            
            sBigger_Sub_Short:             ;(AX)<=(BX)              
              sub dx, dx                   ;重置标识符(CF)=0
              mov cx, ax                   ;最小相等长度数据相减
              
              sBigger_Sub_Short_Equal:
                  mov dx, es:[di]
                  sbb ds:[si], dx          ;值相减再减借位
                  mov dx, ds:[si]          ;值保存在长数据内存中
                  mov es:[di], dx
                  inc si                   ;不影响(CF)值
                  inc si
                  inc di
                  inc di
                loop sBigger_Sub_Short_Equal
              
              mov dx, es:[di]              ;保存高位值
              mov word ptr es:[di], 0000H  ;置高位值为0
              sbb es:[di], dx              ;高位值减再减借位  
              jmp short sBigger_Sub_End
            
            sBigger_Sub_End:            
          
          pop cx                           ;归还寄存器
          pop di
          pop si
          pop dx
          popf
        ret
        
    msCode ends
end sMain