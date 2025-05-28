bits 64

section .bss
    global bfarray
    bfarray: resb 30000

    global filecontent
    filecontent: resq 1

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
    extern allocateBuffer
    extern readFile
    extern closeFile
    extern printFile
    extern checkFileValidity

    extern interpretFile

    extern my_strlen ; returns value in rax, string argument in rdi, doesn't modifies anything else
    extern my_atoi ; returns val bue in rax, string argument in rdi, should not modify rsi as it's pushed then popped from the stack
    extern exitArgumentsError ; these functions exit the program so no need to keep in mind which registers are used

    _start:
        pop rdi ; pops value at top of stack into rdi, when program start, it's the argument count.
        cmp rdi, 2
        jne exitArgumentsError ; exits if argument count != 2

        pop rdi ; get the first argument, in a program first argument is the name of the program
        pop rdi ; get the second argument on the stack, provided by user. The stack is now empty

        call openFile
        call statFile
        call allocateBuffer
        call readFile
        call closeFile
        call checkFileValidity

        call interpretFile

    _exit:
        mov rdi, 0 ; exit code based on input
        mov rax, SYS_EXIT_64 ; syscall 60 for exiting correctly
        syscall