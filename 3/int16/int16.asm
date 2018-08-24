section .data
hex:   db   "0123456789ABCDEF" 

section .text   
use16
  org  100h

loop:
    mov ah,00h  
    int 16h             ;read buffer
    cmp ah,01           ;check esc scan
    je end
    
    push ax             ;save symbol info on top of stack
    push ax
    push ax
    push ax

    mov dl,al           ;print symbol itself 
    mov ah,02h      
    int 21h 
    call space  

    pop ax              ;print ascii
    shr al,4    
    call digit
    pop ax
    and al,0Fh
    call digit
    call space
        
    pop ax              ;print scancode
    xchg ah,al    
    shr al,4
    call digit
    pop ax
    xchg ah,al
    and al,0Fh
    call digit
    call space   

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
    mov ah,4ch          ;exit
    int 21h
