section .data
hex: db "0123456789ABCDEF" 

section .text   
use16
  org  100h

start: 
	mov ax,0040h
	mov fs,ax		;segment to access

loop:
	mov bx,[fs:001Ah]	;address of buffer head
	mov si,[fs:001Ch]	;address of buffer tail
	cmp bx,si 		;empty buf if head = tail
	je loop
	cmp bx,003Ch		;overflow
	je clear
	sub si,2
	mov ax,[fs:si]		;fs:si - address of last key info in buf
	cmp ah,01  		;check esc scan
    	je end 
     
   	push ax   
    	push ax
    	push ax
    	push ax

    	mov dl,al		;print symbol itself 
    	mov ah,02h      
    	int 21h 
    	call space  

    	pop ax    		;print ascii
    	shr al,4    
    	call digit
    	pop ax
    	and al,0Fh
    	call digit
    	call space
        
    	pop ax   		;print scancode
    	xchg ah,al    
    	shr al,4
    	call digit
    	pop ax
    	xchg ah,al
    	and al,0Fh
    	call digit
    	call space   

clear:				;clear buf
	mov ax,0C00h	
	int 21h 
    	jmp loop
              
digit:
    	lea bx,[hex]
    	xlat 
    	mov dl,al
    	mov ah,02h     
    	int 21h
    	ret

space:
    	mov dl,' ' 
    	mov ah,02h      
    	int 21h
    	ret

end:
    	mov ah,4ch    		;exit
    	int 21h
