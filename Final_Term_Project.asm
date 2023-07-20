#This program simulate how RAID 5 works by storing an input string in 3 virtual disks
.data
    #Storing input string
    input: .space 100
    #Prompt
    prompt: .asciiz "Enter a string(type 'stop' to exit): "
    error_message: .asciiz "Error: The length of input string must be a multiple of 8\nPlease enter a new string: "
    valid: .asciiz "Valid input string\n"
    #Output
    Disk: .asciiz "     Disk 1                Disk 2                Disk 3     \n"
    Upperline: .asciiz " --------------        --------------        -------------- \n"
    first_half: .space 8
    second_half: .space 8
    xor_part1: .space 4
    xor_part2: .space 4
    xor_part3: .space 4
    xor_part4: .space 4
    stop: .asciiz "stop\n"
    comma: .asciiz ","
    frame_first_part_data: .asciiz "|     "
    frame_second_part_data: .asciiz "     |"
    space_between_column: .asciiz "      "
    frame_first_part_xor: .asciiz "[[ "
    frame_second_part_xor: .asciiz "]]"
    #Convert integer to hexadecimal ascii code
    hexadecimal_code: .asciiz 
    "00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
    "10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
    "20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
    "30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
    "40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
    "50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
    "60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
    "70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
    "80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
    "90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
    "A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
    "B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
    "C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
    "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
    "E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
    "F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
    
.text
prompt_to_enter:
    li $v0, 4
    la $a0, prompt
    syscall
read:
    li $v0, 8
    la $a0, input
    li $a1, 100
    syscall
check_if_repeat:
    #Load addresses of strings into registers
    la $t0, input
    la $t1, stop
    #Compare strings
    loop:
        # Load a character from user input stop 
        lb $t2, ($t0)
        # Load a character from stored string "stop"
        lb $t3, ($t1)
        # Compare characters, if not equal, jump to continue
        bne $t2, $t3, init_count
        # Characters are equal, check if the end of strings is reached. If reached end, jump to exit
        beqz $t2, check_end
        # Increment input pointer
        addi $t0, $t0, 1
        # Increment "stop" string pointer
        addi $t1, $t1, 1        
        j loop
    check_end:
    	beqz $t3, exit

init_count:
    la $s0, input
    li $s1, 0
count:
    #Check if the length of input string is a multiple of 8
    lb $t1, ($s0)
    #Branch if encounter newline or null
    beq $t1, '\n', check_mul_of_8
    beqz $t1, check_mul_of_8
    #Else continue counting
    addi $s0, $s0, 1
    addi $s1, $s1, 1
    j count
check_mul_of_8:
    andi $s2, $s1, 7
    beqz $s2, init_disk
    j error
init_disk:
    li $v0, 4
    la $a0, valid
    syscall
    j print_Disk

error:
    li $v0, 4
    la $a0, error_message
    syscall
    j read

print_Disk:
    li $v0, 4
    la $a0, Disk
    syscall

print_Upperline:
    li $v0, 4
    la $a0, Upperline
    syscall

load_the_input:
    la $t9, input
    li $t6, 3

working_with_input:
    lw $t1, 0($t9)
    lw $t2, 4($t9)
    sw $t1, first_half
    sw $t2, second_half
    addi $t9, $t9, 8
    and $s1, $t1, 0xFF
    beq $s1, '\n', print_Downline
    
working_with_xor:
    xor $t3, $t1, $t2
    
    andi $t4, $t3, 0x000000FF
    sw $t4, xor_part4
    srl $t3, $t3, 8
    
    andi $t4, $t3, 0x000000FF
    sw $t4, xor_part3
    srl $t3, $t3, 8
    
    andi $t4, $t3, 0x000000FF
    sw $t4, xor_part2
    srl $t3, $t3, 8
    
    sw $t3, xor_part1

check_t8_value:
    beq $t6, 3, if_t8_equal_3

    beq $t6, 2, if_t8_equal_2

    beq $t6, 1, if_t8_equal_1

###################################################################################################
if_t8_equal_3:
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, first_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 4
    la $a0, space_between_column
    syscall
#################################################
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, second_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 4
    la $a0, space_between_column
    syscall
#################################################
    li $v0, 4
    la $a0, frame_first_part_xor
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part4
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part3
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall
    
    la $t8, hexadecimal_code
    lb $t7, xor_part2
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part1
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, frame_second_part_xor
    syscall

    li $v0, 11
    li $a0, '\n'
    syscall

    subi	$t6, $t6, 1			# $t8 = $t8 - 1
    j working_with_input

#################################################
if_t8_equal_2:
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, first_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 4
    la $a0, space_between_column
    syscall
#################################################
    li $v0, 4
    la $a0, frame_first_part_xor
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part1
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part2
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall
    
    la $t8, hexadecimal_code
    lb $t7, xor_part3
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part4
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, frame_second_part_xor
    syscall

	li $v0, 4
    la $a0, space_between_column
    syscall
#################################################
    
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, second_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 11
    li $a0, '\n'
    syscall

    subi	$t6, $t6, 1			# $t8 = $t8 - 1
    j working_with_input
#################################################

if_t8_equal_1:
    li $v0, 4
    la $a0, frame_first_part_xor
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part1
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part2
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall
    
    la $t8, hexadecimal_code
    lb $t7, xor_part3
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, comma
    syscall

    la $t8, hexadecimal_code
    lb $t7, xor_part4
    add $s1, $t7, $t7
    add $t7, $s1, $t7
    add $t8, $t8, $t7
    li $v0, 4
    add $a0, $zero, $t8
    syscall

    li $v0, 4
    la $a0, frame_second_part_xor
    syscall
    
    li $v0, 4
    la $a0, space_between_column
    syscall

#################################################
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, first_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 4
    la $a0, space_between_column
    syscall
#################################################
    li $v0, 4
    la $a0, frame_first_part_data
    syscall

    li $v0, 4
    la $a0, second_half
    syscall

    li $v0, 4
    la $a0, frame_second_part_data
    syscall

    li $v0, 4
    la $a0, space_between_column
    syscall

    li $v0, 11
    li $a0, '\n'
    syscall

    addi	$t6, $t6, 2			# $t8 = $t8 + 2
    j working_with_input
#################################################

print_Downline:
	li $v0, 4
    la $a0, Upperline
    syscall
    j reset
   
reset:
    #Erase data in all string
    la $s0, input
    jal erase_data
    nop
    la $s0, first_half
    jal erase_data
    nop
    la $s0, second_half
    jal erase_data
    nop
    la $s0, xor_part1
    jal erase_data
    nop
    la $s0, xor_part2
    jal erase_data
    nop
    la $s0, xor_part3
    jal erase_data
    nop
    la $s0, xor_part4
    jal erase_data
    nop
    j prompt_to_enter
    erase_data:
        li $t0, 0
        sb $t0, ($s0)
        addi $s0, $s0, 1
        lb $t0, ($s0)
        bne $t0, $zero, erase_data
        jr $ra
exit:
    li $v0, 10
    syscall