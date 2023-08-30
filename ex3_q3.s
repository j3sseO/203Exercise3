.text
.global main
main:
    subui $sp, $sp, 1           # Allocate space on stack
    sw $ra, 0($sp)              # Save $ra to stack

jump:
    addi $7, $0, 0              # Initialise loop counter for invert label
    addi $8, $0, 1              # Initialise value to mask from
    
button:
    lw $11, 0x73001($0)         # Loads value from buttons into $11
    beqz $11, button            # If no buttons have been clicked, loop back
    lw $3, 0x73000($0)          # Loads switch values into $3
    andi $2, $11, 1             
    bnez $2, button             # If first button was clicked, loop back
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
    jal display                 # Jump to display label
    
    j jump                      # Jump back to main label

lights:
    lw $4, values($0)           # Loads value from .data into $4
    sw $4, 0x7300A($0)          # Saves the contents of $4 into the led register, turning them all on

    jal display                 # Jump to display label

    j jump                      # Jump back to main label

display:                        # Displays binary value as hex value on SSD
    sw $3, 0x73009($0)          
	srli $3, $3, 4
	sw $3, 0x73008($0)
	srli $3, $3, 4
	sw $3, 0x73007($0)
	srli $3, $3, 4
	sw $3, 0x73006($0)

    jr $ra

exit:
    lw $ra, 0($sp)              # Load value from stack to $ra
    addui $sp, $sp, 1           # Remove space from the stack

    jr $ra                      # 'exit'

.data
values:
    .word 65535
