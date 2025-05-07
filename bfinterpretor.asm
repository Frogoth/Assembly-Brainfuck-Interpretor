bits 64
section .data ; used to declare const variables
    noFileError: db "ERROR no file detected", 10 ; string to print, 10 stands for '\n'
    noFileErrorLen: equ $-noFileError ; gives length of string, needed for prints

section .bss ; used to declare non-const variables
    bfarray resb 30000
    filepath resw 1
    ; bArr    resb    10     ; 10 element byte array
    ; wArr    resw    50     ; 50 element word array
    ; dArr    resd    100    ; 100 element double array
    ; qArr    resq    200    ; 200 element quad array

section .text
    global _start

    exitFileError:
        mov rax, 1 ; syscall 1 for printing
        mov rdi, 2 ; file descriptor, 2 for error
        mov rsi, noFileError ; noFileError variable to print
        mov rdx, noFileErrorLen ; noFileError variable length
        syscall
        mov rax, 60 ; syscall 60 for exit
        mov rdi, 1 ; error code
        syscall

    _start:
        mov rdi, [rsp]
        cmp rdi, 2
        jl exitFileError

        mov rsi, [rsp + 16]
        mov rdx, equ rsi
        mov rax, 1
        mov rdi, 1
        syscall

        mov rax, 60
        xor rdi, rdi
        syscall