section .data
hex:   db   "0123456789ABCDEF" 
beg_mes db "Begin", 13, 10, '$'
err_mes db "Error", 13, 10, '$'
end_mes db "End", 13, 10, '$'
ln db ' ',13,10,'$'
filename db "hw.com", 0
align 16
psp db 0CFh, 
	times 255 db 0
buf times 256 db 0

section .text   
use16
  org  100h 

start:
	mov dx,beg_mes	
	mov ah,09h
	int 21h

	mov ax,0 	;replace original int 1		
	mov es, ax	
	mov bx, int01h	 
	mov [es:4],bx	
	mov [es:6],cs	

	mov ax,3D00h		;open hw.com
	mov dx,filename
	int 21h
	jc error
	mov bx,ax
	mov ah,3Fh			;read to buf
	mov cx,255
	mov dx,buf
	int 21h
	jc error
	mov ah,3Eh			;close 
	int 21h
	jc error

	mov cx,psp			;psp - program segment prefix
	shr cx,4 			;(adress of psp)/16	
	mov dx,cs		
	add cx,dx				
	mov ds,cx 			;hw program start adress		

	pushf
	push cs 			;main cs	
	mov ax,exit			
	push ax 			;ip to return			
	push 0				;for ret in hw
	pushf 				 
	pop ax			
	or ax,100h			;set TF = 1
	push ax			
	push cx				;hw cs
	push 100h 			;hw offset
	iret				;goto cx:100h = buff

int01h:
	push bp	
	mov bp,sp
	add bp,2		;bp = ip	
	pusha			
	push ds
	push cs 
	pop ds 								
	mov ax,word [bp] 
	call print	
	pop ds
	popa			
	pop bp		
	iret			

exit:
	push cs
	pop ds
	mov dx,end_mes
	mov ah,09h
	int 21h
    int 20h

error:
	mov dx,err_mes
	mov ah,09h
	int 21h
	int 20h

print: 	
	push ax
	shr	ax,12
	call digit 
	pop	ax
	push ax
	shr ax,8
	and ax,0Fh
	call digit
	pop ax
	push ax
	shr ax,4
	and ax,0Fh
	call digit
	pop ax
	push ax
	and ax,0Fh
	call digit
	pop ax
	pusha
    mov dx,ln
    mov ah,09h      
    int 21h
    popa
	ret

digit:
	pusha
    mov bx,hex 
    xlat 
    mov dl,al
    mov ah,02h     
    int 21h
    popa
    ret
