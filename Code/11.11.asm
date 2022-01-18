;ASM
;11.11
;函数
;     将以0结尾的字符串中的小写字母转变成大写字母
;参数
;     ds:si=指向字符串首地址
;返回
;     无
;资料
;     小写字母a(61H)~z(7AH)
;     大写字母A(41H)~Z(5AH)
;     转小写字母 or  al, 020H(00100000B)
;     转大写字母 and al, 0DFH(11011111B)
;

assume cs:msCode

  msData segment
    db "Beginner's All-purpose Symbolic Instruction Code.", 00H
  msData ends
  
  msCode segment    
sMain:
    
    mov ax, msData     ;测试
    mov ds, ax
    mov si, 00H
    call func_Letter_2_Upper
    
    ;
    mov ax, 4c00H
    int 21H
    
    
    func_Letter_2_Upper:
        pushf                                     ;借用寄存器
        push cx
        push si
        
          sChar_Letter_2_Upper:
              mov cl, ds:[si]                     ;取字符
              mov ch, 00H
              
              jcxz sEnd_Char_Letter_2_Upper       ;遇到字符串结尾
              
              inc si                              ;假定比较跳转
              cmp cx, 61H                         ;和小写字母a比较
              jb sChar_Letter_2_Upper
              cmp cx, 7AH                         ;和小写字母z比较
              ja sChar_Letter_2_Upper
              
              dec si                              ;抵消比较的不跳转
              and cl, 0DFH                        ;转换大写字母
              mov ds:[si], cl
              inc si                              ;下一字符
              
              jmp short sChar_Letter_2_Upper
            
          sEnd_Char_Letter_2_Upper:
    
        pop si                                    ;归还寄存器
        pop cx
        popf
      ret
    
      
  msCode ends

end sMain
	
