##
##
## bfinterpretor Makefile
##
##

SRC		=	bfinterpretor.asm \
			my_strlen.asm \
			my_atoi.asm \
			exitErrors.asm \
			readFile.asm

OBJS	=	$(SRC:.asm=.o)

EXEC	=	bfinterpretor

all: $(EXEC)

$(EXEC): $(OBJS)
	ld -o $(EXEC) $(OBJS)

%.o: %.asm
	nasm -f elf64 $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(EXEC)

re: fclean all

.PHONY: all clean fclean re