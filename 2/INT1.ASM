	.model tiny
	.386
	.code
	org 100h
_:
	jmp start

start:
	lea dx,beg_mes	
	mov ah,09h
	int 21h

	lea ax, int01h
	mov di,0		
	mov es, di		 
	mov es:[4],ax		;put int01h at 0:4
	push cs
	pop ax
	mov es:[4]+2,ax	

	mov ax,3D00h		;open hw.com
	lea dx,filename
	int 21h
	jc error
	mov bx,ax
	mov ah,3Fh		;read 
	mov cx,255
	lea dx,buf
	int 21h
	jc error
	mov ah,3Eh		;close 
	int 21h
	jc error

	lea ax,psp
	shr ax,4 		;(adress of psp)/16	
	mov dx,cs		
	add ax,dx				
	mov ds,ax 		;ds = cs + psp/16 -	hw code segment	
	
	lea cx,retaddr		;back to main code segment 

	pushf
	push cs 		;save main cs			
	push cx 		;retaddr			
	push 0			;for int 20h (exit)	
	mov cx,ax		;cx = hw code segment
	pushf 
	pop ax			
	or ax,100h		;set TF = 1
	push ax			
	push cx			
	push 100h 		
	iret			;cx:100h = buff(hw)

int01h:
	push bp	
	mov bp,sp
	add bp,2		;bp = ip	
	pusha			;save stuff
	push ds
	push cs 
	pop ds 			;get correct data segment						
	mov ax,word ptr [bp] 
	call print	
	pop ds
	popa			
	pop bp		
	iret				

retaddr:
	push cs
	pop ds
	lea dx,end_mes
	mov ah,09h
	int 21h
	int 20h

error:
	lea dx,err_mes
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
    	lea dx,ln
    	mov ah,09h      
    	int 21h
    	popa
	ret

digit:
	pusha
    	lea bx,hex 
    	xlat 
    	mov dl,al
    	mov ah,02h     
    	int 21h
    	popa
   	ret

beg_mes db "Begin", 13, 10, '$'
err_mes db "Error", 13, 10, '$'
end_mes db "End", 13, 10, '$'
ln db ' ',13,10,'$'
filename db "hw.com", 0
hex db "0123456789ABCDEF"
align 16
psp db 0CFh, 255 dup(0)
buf db 256 dup(0)

end _

