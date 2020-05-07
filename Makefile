TARGETS = sockbind \
          sockbind_nothumb \
          sockconnect \
          sockconnect_nothumb

all: $(TARGETS)

$(TARGETS): % : %.s
	as $< -o $@.o
	objcopy $@.o -O binary $@
	chmod +x $@
	./convert_to_printf.sh $@ | tee $@.cmds

clean:
	rm -f *.o *.cmds $(TARGETS)
