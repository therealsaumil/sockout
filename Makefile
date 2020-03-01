all: sockout

sockout:
	as sockout.s -o sockout.o
	ld sockout.o -o sockout
	strip sockout
	objcopy --remove-section .ARM.attributes sockout
	./truncate_elf.sh sockout
	./convert_to_printf.sh sockout
	chmod +x sockout

clean:
	rm -f sockout.o sockout
