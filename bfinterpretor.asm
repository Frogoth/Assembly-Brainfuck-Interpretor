bits 64
section .data ; used to declare const variables
    noFileError: db "ERROR no file detected", 10 ; string to print, 10 stands for '\n'
    noFileErrorLen: equ $-noFileError   ; $ represent the current address in the memory, meaning noFileErrorLen
    ; $-noFileError tells the compiler to compute the length between noFileError and noFileErrorLen, giving noFileErrorLen its value
    invalidInputError: db "ERROR invalid input", 10
    invalidInputErrorLen: equ $-invalidInputError

section .bss ; used to declare non-const variables
    bfarray resb 30000
    filepath resw 1
    ; bArr resb 10 ; 10 element byte array
    ; wArr resw 50 ; 50 element word array
    ; dArr resd 100 ; 100 element double array
    ; qArr resq 200 ; 200 element quad array

; define section for frequently used hardcoded values
%define SYS_WRITE_64 1
%define SYS_READ_64 0
%define SYS_EXIT_64 60

%define STDIN 0
%define STDOUT 1
%define STDERR 2


    ; function calling convention
    ; first 6 parameters in RDI, RSI, RDX, RCX (R10 if system call), R8, R9
    ; return value in RAX (on system call, error RAX = -errno)

section .text
    global _start
    extern my_strlen ; returns value in rax, string argument in rdi, doesn't modifies anything else
    extern my_atoi ; returns value in rax, string argument in rdi, modifies rsi

    exitFileError:
        mov rsi, noFileError ; noFileError variable to print
        mov rdx, noFileErrorLen ; noFileError variable length
        jmp exitError

    exitInputError:
        mov rsi, invalidInputError
        mov rdx, invalidInputErrorLen
        jmp exitError

    exitError:
        mov rax, SYS_WRITE_64
        mov rdi, STDERR
        syscall
        mov rax, SYS_EXIT_64
        mov rdi, 1
        syscall

    _start: ; checks if argument count is equal to 2
        ; mov rdi, [rsp] ; rsp is the stack pointer, [rsp] can check the top value, this instruction puts the top value into rdi
        pop rdi ; pops value at top of stack into rdi, when program start, it's the argument count.
        cmp rdi, 2
        jne exitFileError ; exits if argument count != 2
        ; mov rdi, [rsp + 8]    ; we could access the arguments like this without modifying the stack, [rsp] being the name of the program
                                ; [rsp + 8] is the first argument provided by user, [rsp + 16] the second, [rsp + 24]...

        pop rdi ; get the first argument, in a program first argument is the name of the program
        pop rdi ; get the second argument on the stack, provided by user. The stack is now empty

        call my_strlen ; call strlen

        mov rdx, rax ; get length from my_strlen in rdx
        mov rsi, rdi ; put string contained in rdi in rsi
        mov rax, SYS_WRITE_64
        mov rdi, STDOUT
        syscall

        mov rdi, rsi ; puts string back in rdi to call atoi
        call my_atoi
        cmp rax, -1
        je exitInputError

    _exit:
        mov rdi, rax ; exit code based on input
        mov rax, SYS_EXIT_64 ; syscall 60 for exiting correctly
        syscall