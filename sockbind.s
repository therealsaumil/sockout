/* From socket to standard output
 * Loader stub to facilitate
 * transferring binaries into an
 * ARM target
 *
 * mimics the behaviour of:
 *
 * nc -l -p 4444
 *
 * by Saumil Shah
 *
 * Header inspired by Minimal ARM ELF binary
 * https://github.com/mydzor/tinyelf-arm
 */

.macro bump addr
.word \addr+0x200000
.endm

ehdr:                    /* Elf32_Ehdr                      */
    .byte   0x7F         /* e_ident                         */
    .ascii  "ELF"
    .word   1            /*                    |p_type      */
    .word   0            /*                    |p_offset    */
    .word   0x200000     /*                    |p_vaddr     */
    .word   0x280002     /* e_type & e_machine |p_paddr     */
    bump    main         /* e_version          |p_filesz    */
    bump    main         /* e_entry            |p_memsz     */
    .word   4            /* e_phoff            |p_flags     */

main:
    .code 32
    adr     r1, THUMB+1  /* e_shoff            |p_allign    */
    bx      r1           /* e_flags                         */
    .word   0x00200034   /* e_ehsize & e_phentsize          */
                         /* eoreq r0, r0, r4, lsr r0        */
    .word   0x00000001   /* e_phnum & e_shentsize           */
                         /* andeq r0, r0, r1                */

THUMB:
    .code 16
    // socket(2, 1, 0)
    mov     r0, #2
    mov     r1, #1
    eor     r2, r2, r2       // set r2 to null
    mov     r7, #200         // r7 = 281 (socket)
    add     r7, #81
    svc     #0               // r0 = host_sockid value
    mov     r4, r0           // save host_sockid in r4

    // bind(r0, &sockaddr, 16)
    adr     r1, SOCKADDR     // pointer to address, port
    mov     r2, #16          // struct address length
    add     r7, #1           // r7 = 282 (bind)
    svc     #0

    // listen(sockfd, 0)
    mov     r0, r4           // set r0 to saved host_sockid
    eor     r1, r1, r1
    add     r7, #2           // r7 = 284 (listen syscall number)
    svc     #0

    // accept(sockfd, NULL, NULL);
    mov     r0, r4           // set r0 to saved host_sockid
    eor     r2, r2, r2       // set r2 to null
    add     r7, #1           // r7 = 284+1 = 285 (accept syscall)
    svc     #0               // r0 = client socket
    mov     r4, r0           // save new client socket value to r4

    // set aside 1024 bytes of stack space for buffer
    mov     r3, #1
    lsl     r3, #10          // r3 = 1024
    mov     r1, sp           // r1 = buf
    sub     r1, r1, r3
    mov     sp, r1

READ_WRITE_LOOP:

    // read(sockfd, buf, 1024)
    mov     r0, r4           // r0 = socket
    mov     r2, r3           // count (1024)
    mov     r7, #3           // r7 = read
    svc     #0
    
    // write(STDOUT, buf, count)
    mov     r2, r0           // number of bytes read
    mov     r0, #1           // r0 = 1 (stdout)
    mov     r7, #4           // r7 = write
    svc     #0

    cmp     r2, #0           // did we any bytes?
    bgt     READ_WRITE_LOOP  // yes, read some more

    // close(sockfd)
    mov     r0, r4           // r0 = socket
    mov     r7, #6           // r7 = close
    svc     #0

    // exit(0)
    eor     r0, r0, r0
    mov     r7, #1           // r7 = exit
    svc     #0

.balign 4

SOCKADDR:
    .ascii "\x02\x00"        // AF_INET
    .ascii "\x11\x5c"        // port number 4444
    .word  0x00000000        // Bind to 0.0.0.0
