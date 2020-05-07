TARGETS = sockconnect \
          sockconnect_nothumb \
          sockbind \
          sockbind_nothumb

all: $(TARGETS)

$(TARGETS): % : %.s
	as $< -o $@.o
	ld $@.o -o $@
	strip $@
	objcopy --remove-section .ARM.attributes $@
	./truncate_elf.sh $@
	./convert_to_printf.sh $@ | tee $@.cmds

clean:
	rm -f *.o *.cmds $(TARGETS)
