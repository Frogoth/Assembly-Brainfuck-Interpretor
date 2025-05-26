section .data ; used to declare const variables
    wrongArgumentsError: db "ERROR wrong number of arguments, != 2", 10 ; string to print, 10 stands for '\n'
    wrongArgumentsErrorLen: equ $-wrongArgumentsError   ; $ represent the current address in the memory, meaning noFileErrorLen
    ; $-noFileError tells the compiler to compute the length between noFileError and noFileErrorLen, giving noFileErrorLen its value
    invalidInputError: db "ERROR invalid input", 10
    invalidInputErrorLen: equ $-invalidInputError

    invalidFileError: db "ERROR file does not exist", 10
    invalidFileErrorLen: equ $-invalidFileError

    fileEmptyError: db "ERROR file empty", 10
    fileEmptyErrorLen: equ $-fileEmptyError

%define SYS_WRITE_64 1
%define SYS_EXIT_64 60
%define STDERR 2

section .text
    global exitArgumentsError
    global exitInputError
    global exitInvalidFileError
    global exitFileEmptyError

    exitArgumentsError:
        mov rsi, wrongArgumentsError ; wrongArgumentsError variable to print
        mov rdx, wrongArgumentsErrorLen ; wrongArgumentsError variable length
        jmp exitError

    exitInputError:
        mov rsi, invalidInputError
        mov rdx, invalidInputErrorLen
        jmp exitError

    exitInvalidFileError:
        mov rsi, invalidFileError
        mov rdx, invalidFileErrorLen
        jmp exitError

    exitFileEmptyError:
        mov rsi, fileEmptyError
        mov rdx, fileEmptyErrorLen
        jmp exitError

    exitError:
        mov rax, SYS_WRITE_64
        mov rdi, STDERR
        syscall
        mov rax, SYS_EXIT_64
        mov rdi, 1
        syscall