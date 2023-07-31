.data
SameCharacters: .asciiz 
		.space 100
		
arrayString1: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
arrayString2: .word 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Message1: .asciiz "sinhvien"
Message2: .asciiz "sssh"
Message3: .asciiz "commonCharacterCount(s1, s2) =  "
Message4: .asciiz "So ki tu khac nhau la: "
	  .space 100



.text
#Get 2 Arrays address and save it in registers $s1, $s2
	la $s1, arrayString1
	la $s7, arrayString1
	la $s2, arrayString2
	la $s6, arrayString2
	
	la $s5, SameCharacters
	
#Working with Message1
Message1_Processing:
	la $t1, Message1
	li $s3, 0
###########################################################
Message1_task:
	lw $t2, 0($t1)
	andi $t3, $t2, 0x000000ff #Extracting the character at the 1st byte
	beq $t3, $zero, Message2_Porcessing # If $t3 = 0, which mean $t3 read string terminator, then move on to process the 
					    # Message2 string
	addi $s3, $s3, 1
	subi $t3, $t3, 97 #Subtract $t3 with 97 in order to get the index value of the character in the array.
	
	add $t3, $t3, $t3
	add $t3, $t3, $t3  # Caculate $t3 = $t3 * 4
	
	add $s1, $s1, $t3 # Move to the array element which has the index value = $t3. For example with character 'a' then the index
			  # value will be 0. With chracter 'b' then the index value will be 1. The same with other 24 characters.
	lw $t4, 0($s1) # Load the value at address $s1
	addi $t4, $t4, 1 # Add 1 to the $t4.
	sw $t4, 0($s1) # Save $t4 into the address $s1
	sub $s1, $s1, $t3 # Move the address of $s1 back to beginning of the array.
###########################################################
	
	andi $t3, $t2, 0x0000ff00 #Extracting the character at the 2nd byte
	srl $t3, $t3, 8 #Shift left 8 bits in order to move the character at the 2nd byte into the character at the 1st byte.
	beq $t3, $zero, Message2_Porcessing
	
	addi $s3, $s3, 1
	subi $t3, $t3, 97
	
	add $t3, $t3, $t3
	add $t3, $t3, $t3
	
	add $s1, $s1, $t3
	lw $t4, 0($s1)
	addi $t4, $t4, 1
	sw $t4, 0($s1)
	sub $s1, $s1, $t3
###########################################################

	andi $t3, $t2, 0x00ff0000 #Extract the character at the 3rd byte.
	srl $t3, $t3, 16
	beq $t3, $zero, Message2_Porcessing
	
	addi $s3, $s3, 1
	subi $t3, $t3, 97
	
	add $t3, $t3, $t3
	add $t3, $t3, $t3
	
	add $s1, $s1, $t3
	lw $t4, 0($s1)
	addi $t4, $t4, 1
	sw $t4, 0($s1)
	sub $s1, $s1, $t3
###########################################################
	
	andi $t3, $t2, 0xff000000 # Extract the character at the 4th byte.
	srl $t3, $t3, 24
	beq $t3, $zero, Message2_Porcessing
	
	addi $s3, $s3, 1
	subi $t3, $t3, 97
	
	add $t3, $t3, $t3
	add $t3, $t3, $t3
	
	add $s1, $s1, $t3
	lw $t4, 0($s1)
	addi $t4, $t4, 1
	sw $t4, 0($s1)
	sub $s1, $s1, $t3
	
	addi $t1, $t1, 4 #Move the address of $t1 to the next data segment.
	j Message1_task
###########################################################

#Working with Message2
Message2_Porcessing:
	li $s4, 0
	la $t2, Message2
	sub $t3, $t2, $t1
	sub $t2, $t2, $t3
	beq $t3, 1, task2
	nop
	beq $t3, 2, task3
	nop
	beq $t3, 3, task4
	
# Explaination:
# In some situation, the data segment that cointain Message2 will have the null value at the first, the second and the third
# byte. This is the null character of Message1. For that reason, the beginning address of Message2 will not be a number that can
# be divisible with 4. If the null value is at the first byte, then the offset will be 1, we will subtract the value of $t2, which
# is the value of Message2' address, with $t1, which is the value of the last data segment that contain Message1 characters.
# The result, which is save in $t3 will be the offset between the Message1 and Message2 address. We then take the value of $t2, 
# subtract with the result $t3, and we will obtain the data segment address value, which contain Message2 and can be divisble with 4.
# For the offset = 1, we will start extracting Message2 from the second byte. The same approach with offset = 2 and = 3.

###########################################################
Message2_task:
	lw $t3, 0($t2)
task1: 
	andi $t4, $t3, 0x000000ff
	beq $t4, $zero, ArrayComparing
	
	addi $s4, $s4, 1
	subi $t4, $t4, 97
	
	add $t4, $t4, $t4
	add $t4, $t4, $t4
	
	add $s2, $s2, $t4
	lw $t5, 0($s2)
	addi $t5, $t5, 1
	sw $t5, 0($s2)
	sub $s2, $s2, $t4
###########################################################
task2:
	lw $t3, 0($t2)
	andi $t4, $t3, 0x0000ff00
	srl $t4, $t4, 8
	beq $t4, $zero, ArrayComparing
	
	addi $s4, $s4, 1
	subi $t4, $t4, 97
	
	add $t4, $t4, $t4
	add $t4, $t4, $t4
	
	add $s2, $s2, $t4
	lw $t5, 0($s2)
	addi $t5, $t5, 1
	sw $t5, 0($s2)
	sub $s2, $s2, $t4
###########################################################
task3:
	lw $t3, 0($t2)
	andi $t4, $t3, 0x00ff0000
	srl $t4, $t4, 16
	beq $t4, $zero, ArrayComparing
	
	addi $s4, $s4, 1
	subi $t4, $t4, 97
	
	add $t4, $t4, $t4
	add $t4, $t4, $t4
	
	add $s2, $s2, $t4
	lw $t5, 0($s2)
	addi $t5, $t5, 1
	sw $t5, 0($s2)
	sub $s2, $s2, $t4
###########################################################
task4:
	lw $t3, 0($t2)
	andi $t4, $t3, 0xff000000
	srl $t4, $t4, 24
	beq $t4, $zero, ArrayComparing
	
	addi $s4, $s4, 1
	subi $t4, $t4, 97
	
	add $t4, $t4, $t4
	add $t4, $t4, $t4
	
	add $s2, $s2, $t4
	lw $t5, 0($s2)
	addi $t5, $t5, 1
	sw $t5, 0($s2)
	sub $s2, $s2, $t4
	
	addi $t2, $t2, 4
	j Message2_task
###########################################################

ArrayComparing:
	li $t3, 0 #The sum value, which is the number of the common characters.
	li $t4, 0 #Count the number of time the loop has run. $t4 must be <= 25. If larger then the loop is terminated.
	
comparingLoop:
	slti  $t5, $t4, 26 #Compare if $t4 is < 26 then $t5 = 1. If not then $t5 = 0
	beq $t5, $zero, End #If $t5 = 0 then the loop is terminated.
	
	lw $t1, 0($s1) #load the value at address $s1 and $s2.
	lw $t2, 0($s2)
	bne $t1, $zero, test$t2 #Check if $t1 = 0. If yes then move on to the next element in array.
				#If not then check $t2.
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $t4, $t4, 1
	j comparingLoop
	
test$t2:
	bne $t2, $zero, continueLoop	#Check if $t2 = 0. If yes then move on to the next element in array.
					#If not then continue the current loop.
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $t4, $t4, 1
	j comparingLoop

continueLoop:
	sub $t5, $t2, $t1
	bne $t5, $zero, difference #Check if $t1 = $t2 --> $t5 = 0. If $t5 = 0 then add $t3 = $t3 + $t1 and move on to the next loop
				   #If $t5 != 0 then move to difference.
	add $t3, $t3, $t1
	
	sub $t7, $s1, $s7
	lw $t8, 0($s5)
	div $t7, $t7, 4
	addi $t8, $t7, 97
	sw $t8, 0($s5)
	addi $s5, $s5, 4
	
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $t4, $t4, 1
	j comparingLoop
	nop

difference:
	slt $t6, $t5, $zero #Check if $t5 is less than zero. If yes that mean $t2 < $t1 then $t6 = 1.
	beq $t6, $zero, larger
	add $t3, $t3, $t2 #If $t6 = 1, which mean $t2 < $t1 then we add $t3 = $t3 + $t2.
	
	sub $t7, $s1, $s7
	lw $t8, 0($s5)
	div $t7, $t7, 4
	addi $t8, $t7, 97
	sw $t8, 0($s5)
	addi $s5, $s5, 4
	
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $t4, $t4, 1
	j comparingLoop
	
larger:
	add $t3, $t3, $t1 #If $t6 = 0, which mean $t2 > $t1 then we add $t3 = $t3 + $t1.
	
	sub $t7, $s1, $s7
	lw $t8, 0($s5)
	div $t7, $t7, 4
	addi $t8, $t7, 97
	sw $t8, 0($s5)
	addi $s5, $s5, 4
	
	addi $s1, $s1, 4
	addi $s2, $s2, 4
	addi $t4, $t4, 1
	j comparingLoop

End:
	li $v0, 56
	la $a0, Message3
	add $a1, $a1, $t3
	syscall
	
	sub $s3, $s3, $t3
	sub $s4, $s4, $t3
	add $s4, $s3, $s4
	li $v0, 56
	la $a0, Message4
	add $a1, $s4, $zero
	syscall
	
	la $s5, SameCharacters
PrintCharacters:
	lw $t1, 0($s5)
	beq $t1, $zero, EndPrint
	li $v0, 11
	add $a0, $zero, $t1
	syscall
	addi $s5, $s5, 4
	j PrintCharacters
	
EndPrint: