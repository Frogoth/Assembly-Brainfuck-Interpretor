global my_strlen

section .text

    my_strlen:
            xor rax, rax

        strlen_loop:
            cmp byte [rdi + rax], 0
            je done
            inc rax
            jmp strlen_loop

        done:
            ret