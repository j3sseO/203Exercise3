.text
.global main
main:
    subui $sp, $sp, 2           # Allocate space on stack
    sw $ra, 1($sp)              # Save $ra to stack
    la $12, values              # Load address of value label into $12

firstcall:
    jal serial_job              # Jump and link to serial_job label

secondcall:
    jal parallel_job            # Jump and link to parallel_job label

back:
    j firstcall                 # Jump to firstcall label

serial_job:
    lw $3, 0x70003($0)          # Get the first serial port status
    andi $3, $3, 0x1            # Check if the RDR bit is set
    beqz $3, secondcall         # If not, jump to next label
    lw $2, 0x70001($0)          # Serial port now has a character so get it into $2
    slti $4, $2, 'a'            # Set $4 to 1 if value in $2 < 'a'
    sgti $6, $2, 'z'            # Set $6 to 1 if value in $2 > 'z'
    bnez $6, change             # Jump to change label if 1
    bnez $4, change             # Jump to change label if 1

continue:
    j transmit                  # Jump to transmit label

change:
    lw $2, 0($12)               # Load from .data into $2
    j continue                  # Jump to continue label

transmit:
    lw $5, 0x70003($0)          # Get the first serial port status
    andi $5, $5, 0x2            # Check if the TDS bit is set
    beqz $3, transmit           # If not, loop and try again
    sw $2, 0x70000($0)          # Serial port is now ready so transmit character

    jr $ra                      # Jump to address stored in $ra

parallel_job:
    addi $7, $0, 0              # Initialise loop counter for invert label
    addi $8, $0, 1              # Initialise value to mask from

    lw $11, 0x73001($0)         # Loads value from buttons into $11
    beqz $11, back              # If no buttons have been clicked, loop back
    lw $3, 0x73000($0)          # Loads switch values into $3
    andi $2, $11, 1             
    bnez $2, secondcall         # If first button was clicked, loop back
    srli $11, $11, 1            # Shifts button value 1 to the right
    andi $2, $11, 1
    bnez $2, invert             # If second button was clicked, jump to invert label
    srli $11, $11, 1            # Shifts button value 1 to the right
    andi $2, $11, 1
    bnez $2, exit               # If third button was clicked, jump to exit label

invert:
    sll $9, $8, $7              # Shift contents of $8 left by the value stored in $7
    xor $3, $3, $9              # Exclusive OR of value in $3 and $9
    addi $7, $7, 1              # Increment loop counter
    slti $6, $7, 16             # Check if we are at the end of the binary value
    bnez $6, invert             # If not, loop back

    remi $4, $3, 4              # Loads remainder of $3 and 4 into $4
    beqz $4, lights             # If the modified value is a multiple of 4, jump to lights label

    sw $0, 0x7300A($0)          # Turn off leds
    j display                   # Jump to display label

go:
    j back                      # Jump back to main label

lights:
    lw $4, 1($12)                # Loads value from .data into $4
    sw $4, 0x7300A($0)          # Saves the contents of $4 into the led register, turning them all on

    j display                   # Jump to display label

display:                        # Displays binary value as hex value on SSD
    sw $3, 0x73009($0)          
	srli $3, $3, 4
	sw $3, 0x73008($0)
	srli $3, $3, 4
	sw $3, 0x73007($0)
	srli $3, $3, 4
	sw $3, 0x73006($0)

    jr $ra                      # Jump to address stored in $ra

exit:
    lw $ra, 1($sp)              # Load value from stack to $ra
    addui $sp, $sp, 1           # Remove space from the stack

    sw $4, 0($sp)               # Set value at top of stack to non-zero value to 'exit'

.data
values:
    .word '*'
    .word 65535
    
