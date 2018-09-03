	.model tiny
	.386
	.code
	org 100h

start:
	lea dx,msg
	mov ah,09h
	int 21h
	ret
msg db "Hello",13,10,'$'
end start