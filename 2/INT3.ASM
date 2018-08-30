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

	lea ax, int03h
	mov di,0		
	mov es, di		 
	mov es:[12],ax		;put int03h at 0:12
	push cs
	pop ax
	mov es:[12]+2,ax	

	mov ax,3D00h		;open hw.com
	lea dx,filename
	int 21h
	jc error
	mov bx,ax
	mov ah,3Fh			;read 
	mov cx,255
	lea dx,buf
	int 21h
	jc error
	mov ah,3Eh			;close 
	int 21h
	jc error

	lea ax,psp
	shr ax,4 			;(adress of psp)/16	
	mov dx,cs		
	add ax,dx				
	mov ds,ax 			;ds = cs + psp/16 -	hw code segment
		
	lea cx,retaddr
	pushf
	push cs
	push cx
	push 0
	mov al,ds:[breakpoint+100h]
	mov original_byte,al
	
	mov ax, word ptr [al]
	call print	
	
	mov ds:[100h+breakpoint], 0CCh	;set breakpoint 

	pushf 		
	push ds		
	push 100h 		
	iret				;cx:100h = buff(hw)



int03h:
	push bp	
	mov bp,sp
	add bp,2			
	dec word ptr [bp]	

	pusha				;save stuff
	push ds
	push cs 
	pop ds 				;get correct data segment						
	mov ax,word ptr [bp] 
	call print
	
	;mov al,original_byte	;get command back
	;mov xz poka kuda,al	

	pop ds
	popa			
	pop bp		
	int 20h ;tut iret no ne segodnia

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

breakpoint	equ 03h	
original_byte db 09h
beg_mes db "Begin", 13, 10, '$'
err_mes db "Error", 13, 10, '$'
end_mes db "End", 13, 10, '$'
ln db ' ',13,10,'$'
filename db "hw.com", 0
hex	db	"0123456789ABCDEF"
align 16
psp db 0CFh, 255 dup(0)
buf db 256 dup(0)

end _	

