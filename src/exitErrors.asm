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

    invalidReadError: db "ERROR could not read from file", 10
    invalidReadErrorLen: equ $-invalidReadError

    allocateError: db "ERROR could not allocate memory for filecontent", 10
    allocateErrorLen: equ $-allocateError

    unknownSymbolError: db "ERROR symbol not recognized"
    unknownSymbolErrorLen: equ $-unknownSymbolError

    closingMissingLoopError: db "ERROR closing a non existing loop, cannot proceed", 10
    closingMissingLoopErrorLen: equ $-closingMissingLoopError

    unclosedLoopError: db "ERROR unclosed loop at end of file, cannot proceed", 10
    unclosedLoopErrorLen: equ $-unclosedLoopError

    outOfBoundPointer: db "ERROR pointer went out of bound", 10
    outOfBoundPointerLen: equ $-outOfBoundPointer

%define SYS_WRITE_64 1
%define SYS_EXIT_64 60
%define STDERR 2

section .text
    global exitArgumentsError
    global exitInputError
    global exitInvalidFileError
    global exitFileEmptyError
    global exitInvalidReadError
    global exitAllocateError
    global exitUnknownSymbolError
    global exitClosingMissingLoopError
    global exitUnclosedLoopError
    global exitOutOfBoundPointer

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

    exitInvalidReadError:
        mov rsi, invalidReadError
        mov rdx, invalidReadErrorLen
        jmp exitError

    exitAllocateError:
        mov rsi, allocateError
        mov rdx, allocateErrorLen
        jmp exitError

    exitUnknownSymbolError:
        mov rsi, unknownSymbolError
        mov rdx, unknownSymbolErrorLen
        jmp exitError

    exitClosingMissingLoopError:
        mov rsi, closingMissingLoopError
        mov rdx, closingMissingLoopErrorLen
        jmp exitError

    exitUnclosedLoopError:
        mov rsi, unclosedLoopError
        mov rdx, unclosedLoopErrorLen
        jmp exitError

    exitOutOfBoundPointer:
        mov rsi, outOfBoundPointer
        mov rdx, outOfBoundPointerLen
        jmp exitError

    exitError:
        mov rax, SYS_WRITE_64
        mov rdi, STDERR
        syscall
        mov rax, SYS_EXIT_64
        mov rdi, 1
        syscall