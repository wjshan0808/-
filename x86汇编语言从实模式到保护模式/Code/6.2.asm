;6.2
;   以下有符号数中, 正数和负数各有多少？
;   data1 db 0x05, 0xff, 0x80, 0xf0, 0x97, 0x30
;   data2 dw 0x90, 0xfff0, 0xa0, 0x1235, 0x2f, 0xc0, 0xc5bc
;
;资料
;   8位字节
;       正数: [00000000 ~ 01111111]B, [0  ~  127]D, [0x00 ~ 0x7F]H
;       负数: [10000000 ~ 11111111]B, [-128 ~ -1]D, [0x80 ~ 0xFF]H
;   16位字节
;       正数: [0000000000000000 ~ 0111111111111111]B, [0  ~  32767]D, [0x0000 ~ 0x7FFF]H
;       负数: [1000000000000000 ~ 1111111111111111]B, [-32768 ~ -1]D, [0x8000 ~ 0xFFFF]H
;


;起始地址
[GLOBAL sMain]

jmp short sMain


;数据段
[SECTION msData]

    sByteData db 0x05, 0xff, 0x80, 0xf0, 0x97, 0x30
    sWordData dw 0x90, 0xfff0, 0xa0, 0x1235, 0x2f, 0xc0, 0xc5bc
    

;代码段
[SECTION msCode]

sMain:

    mov ax, 0x07c0                          ;数据段地址
    mov ds, ax

    xor si, si                              ;正数统计值
    xor di, di                              ;负数统计值
    
    mov bx, sByteData                       ;Byte数据地址
    mov cx, 06H                             ;6个Byte值
    
    sByteLoop:
            mov al, [bx]                    ;当前Byte值
            cmp al, 00H                     ;和00比较
            
            jl sNegativeByte                ;跳转到负数
            
            sPositiveByte:
                inc si                      ;增加正数统计
                jmp short  sNextByte     ;跳转到下一个数
            
            sNegativeByte:
                inc di                      ;增加负数统计
            
            sNextByte:
                inc bx                      ;下一个Byte值地址
        loop sByteLoop
        
    
    mov bx, sWordData                       ;Word数据地址
    mov cx, 07H                             ;7个Word值
    
    sWordLoop:
            mov ax, [bx]                    ;当前Word值
            cmp ax, 0000H                   ;和0000比较
            
            jl sNegativeWord                ;跳转到负数
            
            sPositiveWord:
                inc si                      ;增加正数统计
                jmp short  sNextWord     ;跳转到下一个数
            
            sNegativeWord:
                inc di                      ;增加负数统计
            
            sNextWord:
                add bx, 02H                 ;下一个Word值地址
        loop sWordLoop
    
    
    mov ax, 0x4c00                          ;退出
    int 21H
    