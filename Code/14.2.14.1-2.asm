;ASM
;14.2.14.1-2 编程读写COMOS RAM的2号单元内容 
;
;资料
;     CMOS RAM芯片有两个端口
;       a.70H端口是地址端口
;       b.71H端口是数据端口
;     在in和out指令中
;       a.访问8位端口用al存放读写的数据
;       b.访问16位端口用ax存放读写的数据
;       c.对256~65535端口的读写时用dx存放端口号
;

assume cs:msCode
  
  msCode segment
sMain:
    
    ;mov dx, 70H         ;地址端口
    mov al, 02H          ;2号单元地址值
    out 70H, al          ;向地址端口送入2号单元地址值    
    ;mov dx, 71H         ;数据端口
    in al, 71H           ;从数据端口读取2号单元地址的数据
    
    
    ;mov dx, 70H         ;地址端口
    mov al, 02H          ;2号单元地址值
    out 70H, al          ;向地址端口送入2号单元地址值
    ;mov dx, 71H         ;数据端口
    mov al, 00H          ;数据值
    out 71H, al          ;向数据端口的2号单元地址写入值
    
    
    ;
    mov ax, 4c00H
    int 21H
    
  msCode ends
end sMain
	
