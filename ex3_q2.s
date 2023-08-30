.text
.global main
main:
    j receive

receive:
    # get the first serial port status
    lw $3, 0x70003($0)
    # check if the RDR bit is set
    andi $3, $3, 0x1
    # if not, loop and try again
    beqz $3, receive
    # serial port now has a character.
    # get it into $2
    lw $2, 0x70001($0)
    slti $4, $2, 'a'
    sgti $6, $2, 'z'
    bnez $6, change
    bnez $4, change
    j transmit

change:
    lw $2, star($0)
    j transmit

transmit:
     # get the first serial port status
    lw $5, 0x70003($0)
    # check if the TDS bit is set
    andi $5, $5, 0x2
    # if not, loop and try again
    beqz $3, transmit
    # serial port is now ready so
    # transmit character
    sw $2, 0x70000($0)

    j receive

.data
star:
    .word '*'
    