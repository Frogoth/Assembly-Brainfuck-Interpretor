bits 64

section .bss ; used to declare non-const variables
    bfarray resb 30000

    global filecontent ; declares it as global to use it in e
    filecontent: resb 256
    ; bArr resb 10 ; 10 element byte array
    ; wArr resw 50 ; 50 element word array
    ; dArr resd 100 ; 100 element double array
    ; qArr resq 200 ; 200 element quad array
    global statbuff
    statbuff: resb 144

; define section for frequently used hardcoded values

%define SYS_WRITE_64 1
%define SYS_EXIT_64 60

%define STDIN 0
%define STDOUT 1
%define STDERR 2

    ; function calling convention
    ; first 6 parameters in RDI, RSI, RDX, RCX (R10 if system call), R8, R9
    ; return value in RAX (on system call, error RAX = -errno)

section .text
    global _start

    extern openFile
    extern statFile
    extern readFile
    extern closeFile
    extern printFile

    extern my_strlen ; returns value in rax, string argument in rdi, doesn't modifies anything else
    extern my_atoi ; returns val bue in rax, string argument in rdi, should not modify rsi as it's pushed then popped from the stack
    extern exitArgumentsError ; these functions exit the program so no need to keep in mind which registers are used
    extern exitInputError
    extern exitInvalidFileError
    extern exitFileEmptyError

    _start: ; checks if argument count is equal to 2
        ; mov rdi, [rsp] ; rsp is the stack pointer, [rsp] can check the top value, this instruction puts the top value into rdi
        pop rdi ; pops value at top of stack into rdi, when program start, it's the argument count.
        cmp rdi, 2
        jne exitArgumentsError ; exits if argument count != 2
        ; mov rdi, [rsp + 8]    ; we could access the arguments like this without modifying the stack, [rsp] being the name of the program
                                ; [rsp + 8] is the first argument provided by user, [rsp + 16] the second, [rsp + 24]...

        pop rdi ; get the first argument, in a program first argument is the name of the program
        pop rdi ; get the second argument on the stack, provided by user. The stack is now empty

        call openFile
        call statFile
        call readFile
        call closeFile
        call printFile

        ; call my_strlen ; call strlen

        ; mov rdx, rax ; get length from my_strlen in rdx
        ; mov rsi, rdi ; put string contained in rdi in rsi
        ; mov rax, SYS_WRITE_64
        ; mov rdi, STDOUT
        ; syscall

        ; mov rdi, rsi ; puts string back in rdi to call atoi
        ; call my_atoi
        ; cmp rax, -1
        ; je exitInputError

    _exit:
        mov rdi, 0 ; exit code based on input
        mov rax, SYS_EXIT_64 ; syscall 60 for exiting correctly
        syscall