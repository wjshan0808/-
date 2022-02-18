;7.2
;   计算1到1000的累加和
;
;资料
;   adc
;


;起始地址
[GLOBAL sMain]

jmp short sMain


;数据段
[SECTION msData]
    

;代码段
[SECTION msCode]

sMain:

    xor ax, ax                              ;初始化低16位值
    xor dx, dx                              ;初始化高16位值

    mov cx, 1000                            ;1000次
    sACCLoop:
            add ax, cx                      ;累加数值
            adc dx, 0000H                   ;累加进位值
        loop sACCLoop
    
    mov ax, 0x4c00                          ;退出
    int 21H
    