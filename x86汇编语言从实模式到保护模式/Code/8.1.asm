;8.1
;   nasm编译器段定义练习
;
;资料
;   
;



times 0x60 nop


;
[SECTION data1 align=16 vstart=0]
    lba db 0x55, 0xf0
;
[SECTION data2 align=16 vstart=0]
    lbb db 0x00, 0x90
    lbc dw 0xf000
;
[SECTION data3 align=16]
    lbd dw 0xfff0, 0xfffc
    

sMain:

    mov ax, section.data1.start             ;0x60
    mov ax, section.data2.start             ;0x70
    mov ax, section.data3.start             ;0x80
    
    mov ax, lba                             ;0x00
    mov ax, lbc                             ;0x02
    mov ax, lbd                             ;0x80
    
    mov ax, 0x4c00                          ;退出
    int 21H
    