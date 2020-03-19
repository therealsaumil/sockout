all: sockout sockout_nothumb

sockout:
	as sockout.s -o sockout.o
	ld sockout.o -o sockout
	strip sockout
	objcopy --remove-section .ARM.attributes sockout
	./truncate_elf.sh sockout
	./convert_to_printf.sh sockout
	chmod +x sockout

sockout_nothumb:
	as sockout_nothumb.s -o sockout_nothumb.o
	ld sockout_nothumb.o -o sockout_nothumb
	strip sockout_nothumb
	objcopy --remove-section .ARM.attributes sockout_nothumb
	./truncate_elf.sh sockout_nothumb
	./convert_to_printf.sh sockout_nothumb
	chmod +x sockout_nothumb

clean:
	rm -f sockout.o sockout sockout_nothumb.o sockout_nothumb

