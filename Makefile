##
##
## bfinterpretor Makefile
##
##

SRC		=	src/bfinterpretor.asm \
			src/my_strlen.asm \
			src/my_atoi.asm \
			src/exitErrors.asm \
			src/readFile.asm \
			src/interpretFile.asm

OBJS	=	$(SRC:.asm=.o)

EXEC	=	bfinterpretor

FLAGS	=	-f elf64

all: $(EXEC)

$(EXEC): $(OBJS)
	ld -o $(EXEC) $(OBJS)

%.o: %.asm
	nasm $(FLAGS) $< -o $@

debug:	FLAGS+=-g -F dwarf
debug:	all

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(EXEC)

re: fclean all

.PHONY: all clean fclean re