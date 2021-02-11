.data
	# To enter the paragraph
	inputParagraph: .asciiz "Please enter a paragraph: \n"
	
	# Choice of functions 
	functions: .asciiz "\n Enter option you want:\n 1- Make the paragraph in lower case \n 2- Make the paragraph in upper case \n 3- Capitalize each word \n 4- Join 2 strings\n 5- Search on a specific word/character \n 6- Substring\n"
	
	#Paragraph space
	paragraph: .space 1000
	ChoiceOfFunction: .space 10
	
	#data of join function 
	first:      .asciiz     "First string: \n "
	last:       .asciiz     "Second string: \n"
	full:       .asciiz     "Full string: \n"
	newline:    .asciiz     "\n"
	string1:    .space      256             # buffer for first string
	string2:    .space      256             # buffer for second string
	string3:    .space      512             # combined output buffer
	
	#data of substring function
	found:.asciiz "Found!"
	notFound:.asciiz "Not found!"
	word: .space 100
	wordMsg: .asciiz "Enter word/character to search : "
	endline: .asciiz "\n"
	
	#data for serch function
	msg1: .asciiz "Enter Main String: "
	msg2: .asciiz "Enter word or character to search: "
	msg3: .asciiz "Word not found"
	index: .asciiz "This word found at Index: "
	WordS: .space 100

	

.text
.globl main
#---------------------------------------- MAIN PROGRAME------------------------------------------------------
	main:
		#print "enter paragraph message"
		li $v0, 4 
		la $a0, inputParagraph
		syscall
		#Scan the paragraph from user
		li $v0, 8
		la $a0, paragraph
		li $a1, 100
		syscall
		#print table of options 
		li $v0, 4
    		li $t0, 0
		#print table of options
		li $v0, 4
		la $a0, functions
		syscall
		#print new line
		li $v0, 4
		la $a0, newline
		syscall
		#scan Choise
		li $v0, 5
		syscall
		move $t7, $v0
		
		#Choise Functions
		beq $t7, 1, LoopOfLowerCase	#choice number 1 to start lower case function
		beq $t7, 2, LoopOfUpperCase	#choice number 2 to start Upper case function
		beq $t7, 3, LoopOfcapitalize	#choice number 3 to start capitalize first letter of each word function
		beq $t7, 4, join	#choice number 4 to make join of 2 diffrent strings function
		beq $t7, 5, search	#choice number 5 to start search a word in the paragraphe function
		beq $t7, 6, substring	#choice number 6 to start search a substring in the paragraphe function
		

#---------------------------------------- CAPITALIZE EACH WORD FUNCTION------------------------------------------------------
 LoopOfcapitalize:
    lb $t1, paragraph($t0)	#load the paragraphe
    beq $t1, 0, exit	#if condition  if (index == 0) exit 
    beq $t0,0,case2	#if condition  if (index == 0) case2
    beq $t1, ' ', case1		#if condition  if (index == ' ') case1
    sb $t1, paragraph($t0)	#update the paragraphe
    addi $t0, $t0, 1
    j LoopOfcapitalize	#j++ and back to loop

case1:
    addi $t0, $t0, 1
    lb $t1, paragraph($t0)	#load the paragraphe
    blt $t1, 'a', case	#if condition  if (index < 'a') case
    bgt $t1, 'z', case	#if condition  if (index > 'z') case
    sub $t1, $t1, 32
    sb $t1, paragraph($t0)
    j LoopOfcapitalize	#j++ and back to loop

case2:
	blt $t1, 'a', case	#if condition  if (index < 'a') case
	bgt $t1, 'z', case	#if condition  if (index > 'z') case
	sub $t1, $t1, 32
	sb $t1, paragraph($t0)	#update the paragraphe
	addi $t0, $t0, 1	
	j LoopOfcapitalize	#j++ and back to loop
	
case:
sb $t1, paragraph($t0)	#update the paragraphe
addi $t0, $t0, 1
j LoopOfcapitalize	#j++ and back to loop


#---------------------------------------- JOIN FUNCTION------------------------------------------------------ 
join:
la      $a0,first               # prompt string
    la      $a1,string1             # buffer address
    jal     prompt
    move    $s0,$v0                 # save string length

    # prompt and read second string
    la      $a0,last                # prompt string
    la      $a1,string2             # buffer address
    jal     prompt
    move    $s1,$v0                 # save string length

    # point to combined string buffer
    # NOTE: this gets updated across strcat calls (which is what we want)
    la      $a0,string3

    # decide which string is shorter based on lengths
    blt     $s0,$s1,string1_short

    # string 1 is longer -- append to output
    la      $a1,string1
    jal     strcat

    # string 2 is shorter -- append to output
    la      $a1,string2
    jal     strcat

    j       print_full

string1_short:
    # string 2 is longer -- append to output
    la      $a1,string2
    jal     strcat

    # string 1 is shorter -- append to output
    la      $a1,string1
    jal     strcat

# show results
print_full:
    # output the prefix message for the full string
    li      $v0,4
    la      $a0,full
    syscall

    # output the combined string
    li      $v0,4
    la      $a0,string3
    syscall

    # finish the line
    li      $v0,4
    la      $a0,newline
    syscall

    li      $v0,10
    syscall


prompt:
    # output the prompt
    li      $v0,4                   #to print string
    syscall

    # get string from user
    li      $v0,8                   #for string read
    move    $a0,$a1                 #store string
    li      $a1,256                 #maximum length of string
    syscall

    li      $v1,0x0A                # ASCII value for newline
    move    $a1,$a0                 # remember start of string

# strip newline and get string length
prompt_nltrim:
    lb      $v0,0($a0)              # get next char in string
    addi    $a0,$a0,1               # pre-increment by 1 to point to next char
    beq     $v0,$v1,prompt_nldone   # is it newline? if yes, fly
    bnez    $v0,prompt_nltrim       # if not end of string move to loop

prompt_nldone:
    sub $a0,$a0,1               # compensate for pre-increment
    sb   $zero,0($a0)            # zero out the newline
    sub  $v0,$a0,$a1             # get string length
    jr   $ra                     # return

strcat:
    lb      $v0,0($a1)              # get the current char
    beqz    $v0,strcat_done         # is char 0? if yes, done
    sb      $v0,0($a0)              # store the current char
    addi    $a0,$a0,1               # advance destination pointer
    addi    $a1,$a1,1               # advance source pointer
    j       strcat

strcat_done:
    sb      $zero,0($a0)            # add EOS
    jr      $ra                     # return

  
#---------------------------------------- LOWER CASE FUNCTION------------------------------------------------------ 
 LoopOfLowerCase:
    lb $t1, paragraph($t0)	#load the paragraphe
    beq $t1, 0, exit		#if condition  if (index == 0) exit
    blt $t1, 'A', case3		#if condition  if (index < 'A') case3
    bgt $t1, 'Z', case3		#if condition  if (index > 'Z') case3
    add $t1, $t1, 32		# this index + 32 (ASCII)
    sb $t1, paragraph($t0)

case3: 
    addi $t0, $t0, 1		# this index + 1 in the array of paragraphe
    j LoopOfLowerCase
    
#---------------------------------------- UPPER CASE FUNCTION------------------------------------------------------ 
 LoopOfUpperCase:
    lb $t1, paragraph($t0)	#load the paragraphe
    beq $t1, 0, exit		#if condition  if (index == 0) exit
    blt $t1, 'a', case4		#if condition  if (index < 'a') case4
    bgt $t1, 'z', case4		#if condition  if (index > 'z') case4
    sub $t1, $t1, 32		# this index - 32 (ASCII)
    sb $t1, paragraph($t0)

case4: 
    addi $t0, $t0, 1		# this index + 1 in the array of paragraphe
    j LoopOfUpperCase
    
#---------------------------------------- SEARCH FUNCTION------------------------------------------------------
search:
    li $v0, 4	#tell the system that the output string type
    la $a0, msg2	#load the address of the message
    syscall

    li $v0, 8	#scan from user
    la $a0, WordS	#address of the word
    li $a1, 99	#buffer input
    syscall

    la $a0,paragraph	#move the address of the first char of the string to $a0 "the first address" =>string[0]
    jal findLengthString	#call to find the length
    move $a2, $v0	#move the output to $a2

    la $a0, WordS	#move the address of the first char of the string to $a0 "the first address" =>string[0]
    jal findLengthString	#call to find the length
    move $a3, $v0 # Length of all string "paragraph"
    sub $a2, $a2, $a3 # wordLen - stringlen
    

    la $a0, paragraph	#first address to string
    la $a1, WordS 	#first pointer to the word

    jal Match	# call compare 
    move $t1, $v0


    li $v0, 1
    move $a0, $t1
    syscall
    
exit3:
    li $v0, 10
    syscall
    lb $t9, endline

findLengthString:#first loop to count : wordlen/stringlen
    li $t0, -1#end
    move $s0, $a0#move return value

    loop_counter:
        lb $t1, 0($s0)	#load one byte from string
        beq $t1, $t9, findLength	# if equal to null => 0, branch if(string[index]==null)

        addi $t0, $t0, 1	#i++
        addi $s0, $s0, 1	#address++
        j loop_counter	#repeat loop

    findLength:	#for word 
        move $v0, $t0	#move address of the word
        jr $ra

Match:
    li $t0, 0 #i = 0
    l1:
        bgt $t0,$a2, l1done  #if(i>paragraphlen-wordLen end)
        li $t1, 0 #j = 0
        l2:
            bge $t1, $a3, l2done	# if j>wordLen
            add $t3, $t0, $t1	#i+j
            add $t4, $a0, $t3	# i+j + the address of the string 
            lb $t3, 0($t4) # string[i+j] 

            add $t4, $a1, $t1	#j +word address
            lb $t4, 0($t4) # word[j]
            # if a0[i + j] != a1[j]
            bne $t3, $t4, break01	#string[i+j] != word[j]

            addi $t1, $t1, 1	#j++
            j l2	 #repeat loop
        
        l2done:
            beq $t1, $a3, loopAgain
            j break01
        loopAgain:
             li $v0,4 #print message of the index
           la $a0,index #message address
           syscall
            move $v0, $t0
            jr $ra
            
    break01:
        addi $t0, $t0, 1 #i++
        j l1 #return to loop i
    l1done:
      
            li $v0,4 #preent not found message\ 
           la $a0,msg3 #message address
           syscall
           li $v0,-1 #return -1 to end 
           jr $ra
#---------------------------------------- SUBSTRING FUNCTION------------------------------------------------------

substring:
#load message and scan word:
    li $v0, 4  	#tell the system that the output string type
    la $a0, wordMsg#load the address of the message
    syscall
# scan the word
    li $v0, 8 #scan from user
    la $a0, word #address of the word
    li $a1, 99 #buffer input
    syscall

    la $a0,paragraph #move the address of the first char of the string to $a0 "the first address" =>string[0]
    jal stringLength #call to find the length
    move $a2, $v0 #move the output to $a2

    la $a0, word #move the address of the first char of the string to $a0 "the first address" =>string[0]
    jal stringLength #call to find the length
    move $a3, $v0 # Length of all string "paragraph"
    sub $a2, $a2, $a3 # wordLen - stringlen
    

    la $a0, paragraph #first address to string
    la $a1, word #first pointer to the word

    jal Compare # call compare 
    move $t1, $v0
   
exit2:
    li $v0, 10 #return 0
    syscall
 lb $t9, endline#to handle null term

stringLength: #first loop to count : wordlen/stringlen
    li $t0, -1 #end
    move $s0, $a0 #move return value

    loopCount:
        lb $t1, 0($s0) #load one byte from string
        beq $t1, $t9, foundLength # if equal to null => 0, branch if(string[index]==null)
        addi $t0, $t0, 1 #i++ 
        addi $s0, $s0, 1 #address++
        j loopCount #repeat loop

    foundLength: #for word 
        move $v0, $t0 #move address of the word
        jr $ra


Compare:
    li $t0, 0 #i=0
    
    loop1:
        bgt $t0,$a2, loop1done  #if(i>paragraphlen-wordLen end)
        li $t1, 0 #j=0
        #add $s2,$zero,1 #found=1
        
        loop2:
            bge $t1, $a3, loop2done # if j>wordLen
            add $t3, $t0, $t1 #i+j
            add $t4, $a0, $t3 # i+j + the address of the string 
            lb $t3, 0($t4) # string[i+j]
            add $t4, $a1, $t1 #j +word address
            lb $t4, 0($t4) # word[j]           
            bne $t3, $t4, break1 #string[i+j] != word[j]
	    addi $t1, $t1, 1 #j++
	    j loop2  #repeat loop
        
        loop2done:
            beq $t1, $a3, foundlabel #j<wordLen
            j break1 #break from j loop 
            
        foundlabel: #label
            li $v0, 4 #to print string
            la $a0,found #address of the message
            syscall
            jr $ra
              
    break1:
        addi $t0, $t0, 1 #i++
        j loop1 #return to loop i
         
    loop1done:
           li $v0,4 #preent not found message
           la $a0,notFound #message address
           syscall
           li $v0,-1 #return -1 to end 
           jr $ra
    
exit:
    li $v0, 4
    la $a0, paragraph
    syscall
