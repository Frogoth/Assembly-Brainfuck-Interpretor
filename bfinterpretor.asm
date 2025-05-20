bits 64
section .data ; used to declare const variables
    noFileError: db "ERROR no file detected", 10 ; string to print, 10 stands for '\n'
    noFileErrorLen: equ $-noFileError ; gives length of string, needed for prints

section .bss ; used to declare non-const variables
    bfarray resb 30000
    filepath resw 1
    ; bArr resb 10 ; 10 element byte array
    ; wArr resw 50 ; 50 element word array
    ; dArr resd 100 ; 100 element double array
    ; qArr resq 200 ; 200 element quad array

    ; function calling convention
    ; first 6 parameters in RDI, RSI, RDX, RCX (R10 if system call), R8, R9
    ; return value in RAX (on system call, error RAX = -errno)

section .text
    global _start
    extern my_strlen

    exitFileError:
        mov rax, 1 ; syscall 1 for write
        mov rdi, 2 ; file descriptor, 2 for error
        mov rsi, noFileError ; noFileError variable to print
        mov rdx, noFileErrorLen ; noFileError variable length
        syscall
        mov rax, 60 ; syscall 60 for exit
        mov rdi, 1 ; error code
        syscall

    _start: ; checks if argument count is equal to 2
        mov rdi, [rsp] ; loads value at top of stack into rdi, when program start, it's the argument count.
        cmp rdi, 2
        jl exitFileError ; exists if argument count != 2

        mov rsi, [rsp + 16] ; to access the arguments, [rsp] is still used but with + 8, + 16..etc, [rsp + 8 == argv[0]]
        call my_strlen ; call strlen
        mov rax, 1 ; syscall 1 for write
        mov rdi, 1 ; output fd
        mov rdx, rcx ; get rsi length to print it
        syscall

        mov rax, 60 ; syscall 60 for exiting correctly
        xor rdi, rdi ; exit code (0)
        syscall