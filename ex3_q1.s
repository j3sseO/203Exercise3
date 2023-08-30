.text
.global main
main:
    addi $1, $0, 'a'
    addi $2, $0, 'A'
    j lowercase

check: 
    # get the second serial port status
    lw $3, 0x71003($0)
    # check if the TDS bit is set
    andi $3, $3, 0x2
    # if not, loop and try again
    beqz $3, check
    jr $ra

lowercase:
   jal check
    # serial port is now ready so
    # transmit character
    sw $1, 0x71000($0)
    # progress through alphabet
    addi $1, $1, 1
    # sets to 1 if alphabet is below '{'
    slti $4, $1, '{'
    # jumps back to beginning until the end of lowercase alphabet is reached
    bnez $4, lowercase

uppercase:
    jal check
    # serial port is now ready so
    # transmit character
    sw $2, 0x71000($0)
    # progress through alphabet
    addi $2, $2, 1
     # sets to 1 if alphabet is below '['
    slti $4, $2, '['
    # jumps back to beginning until the end of uppercase alphabet is reached
    bnez $4, uppercase







