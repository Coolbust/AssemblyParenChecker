#######################################################################
# Created By: Robinson, Sidney
#            
#
# Syntax Checker
#        
#
# Description: 
#
# Notes: This program is intended to be run from the MARS IDE and before running you must put an input file into the 
#input option in the MARS IDE. Test file must be in some directory as MARS IDE
######################################################################
######################################################################
# Psuedocode
# First thing is u want to print file and then cross check the value with all valid and invalid opperands
#       Enter file name into a bunch of brances and have certain breaks depeding on invalid imputs
#             If file is of proper formatting branch to a file success loop
#
#             Updated Psuedo: Iterate thru the loop forward and backwards popping brackets on checking type
#                Move backwards and pop brace(Pop errors if mismatch)
#   
#
#     If Success Loop is initiated parse thru the loop and add value and index to stack
#             Add open braces to stack
#                    Parse through the stack and pop things of the stack if open braces work
#
#     If pop check value of what is popped to determ what error to throw
#            store pop value and compare to the ascii table
#
######################################################################
.data  
#fin: .asciiz "test1.txt\n"      # filename for input
youEnt: .asciiz "You entered the file:\n"
succ1: .asciiz "SUCCESS: There are "
succ2: .asciiz " pairs of braces."
errInv: .asciiz "ERROR: Invalid program argument."
newLine: .asciiz"\n"
space: .asciiz " "
check: .asciiz"checkpls1"
check1: .asciiz"checkpls2"
enterCheck:.asciiz "EnterCheck"
errBrack: .asciiz "ERROR - Brace(s) still on stack: "
errBrackMis: .asciiz "ERROR - There is a brace mismatch: "
errBrackMis1: .asciiz " at index "
buffer: .space 128

.text
####################################################################################################################
#printing the you enter file message:
li $v0,4
la $a0,youEnt
syscall 

# $a1 pointer to pointer (adress of an adress)
lw $t6, ($a1) #loading the word of the prompt into a temp variable

#printing the name of the file
li $v0,4
move $a0, $t6
syscall 

#printing a newLine
li $v0,4
la $a0, newLine
syscall

#beg of file checking
####################################################################################################################
addi $t2,$zero,0 #store 0 in temp 2
li $t2, 0

#checking first value
lb $t0,0($t6) #storing  the first bite of the file name into t0
blt $t0,65, checkNameFail #checking to make sure first value is a letter
bgt $t0,122,checkNameFail #checking to make sure first value is a letter

ble  $t0, 90, endOfBetween1 #if it is A Cap it will success
bgt $t0,90,between1 #greater than @->A aciii
between1:
blt $t0,97,checkNameFail #and less than 65 it fsucceds 
endOfBetween1:

add $s2,$zero,1 #initializing a counter in s2 to make sure the length of the input does not exceed 20 char with end character
#Loop to check thru bytes(chars and throw error if broken/go thru to the rest of the code if it works)
checkStart:
bgt $s2,20,checkNameFail
lb $t0,0($t6)            # load a byte from the array into t0
addi $t6, $t6, 1         # increment $a1 by one, to point to the next element in the array
lb $t0,0($t6)            # load a byte from the array into $t0


beq $t0,0, fileOpenStart #if $t0 is null aka the end of the file name the null terminator run the code
beq $t0,46,checkStart #goes back to the top if it is a .
beq $t0,95,checkStart #goes back to the top if it is a underscore(_) 
beq $t0,31,checkStart #goes back to the top if it is a unit seperator

ble $t0,48,checkNameFail #if it is less than 48 it will throw check name fail


bge $t0,123,checkNameFail #throw the program to end of the file if non good file name



blt $t0,58,endOfChunk1 #:
bgt $t0,57,chunk1 #greater than 9 aciii
chunk1:
blt $t0,65,checkNameFail #and less than 65 it fails
endOfChunk1:

blt $t0,91,endOfChunk2  #branch to check the chunk
bge $t0,91,chunk2
chunk2:
ble $t0,96,checkNameFail
endOfChunk2:


addi $s2,$s2,1
b checkStart
checkEnd:

#end of file checking
####################################################################################################################




#Beginning of file open and buffering/checking
fileOpenStart:
#open a file for reading
li   $v0, 13       # system call for open file
lw   $a0, ($a1)   # pointer to address at whcih stores the prompt input
li   $a1,0         #file flag(reads)
li   $a2, 0        #mode is ignored
syscall            # open a file 
move $s6, $v0      # save the file descriptor 



move $s4,$zero
top:
la $a2, buffer
move $a2, $zero
addi $a2,$a2,1
addi $s4,$s4,1
beq $s4,128,endTop
endTop:
####################################################################################################
readLoop:
#going to put this in a loop so it will through the enirety of the file regardless of length
#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer   # address of buffer to which to read
li   $a2, 127      # hardcoded buffer length #TA said it was convient that way you can check for null
syscall            # read from file
move $s7, $v0 #storing whether or not a file is finished or not
 


move $s4,$zero #0ing out s4 to store later

#########################################################################################################
endOfReadLoop:

#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#########################################################################################################
#poping and reading through buffer
#read until buffer end and then if the s7 which is the value of the og file isnt at the end loop back up
#move $s2, $zero
la $a2,buffer
move $s6,$s4
addi $s0,$s0,1
#li $v0,4
#la $a0,($a2)
#syscall
parseBuffLoop:
lb $s2,0($a2)      # load a byte from the array into $a2
######################################################## 
subi,$s5,$s5,1 #decrenenting s5 as we go back in index


beq $s2,41,backTrack
beq $s2,93,backTrack
beq $s2,125,backTrack

storeSection:
subi $sp,$sp,4 #allocate space for the stack
sw $s2,($sp) #storing the the bite onto the stack
b endOfBackTrack #jumping ot end of the back track loop because we dont need to irate back as it is an open bracket it is added to stack
endOfStoreLoop:

backTrack:
move $s5,$s6 #clone of index
backTrack1:
lw $s1,($sp) #poping what is on the stack    
#############################
bne $s2,41,endOfParenCheck #check to see if it is a )

beq $s1,91,cBrackMis #if it is a ) and the popped thing is a different brack throw mismatch
beq $s1,123,cBrackMis

#check to see if it a nonsense character like a letter
bne $s1,40,endOfParenCheck
addi $s3,$s3,1
b endOfBackTrack
endOfParenCheck:
#############################

#############################
bne $s2,93,endOfBrackCheck #if it is a ] and the popped thing is a different brack throw mismatch

beq $s1,40,cBrackMis
beq $s1,123,cBrackMis

#check to see if it a nonsense character like a letter
bne $s1,91,endOfBrackCheck
addi $s3,$s3,1
b endOfBackTrack
endOfBrackCheck:
#############################

#############################
bne $s2,125,endOfCurlyCheck #if it is a } and the popped thing is a different brack throw mismatch

beq $s1,91,cBrackMis
beq $s1,40,cBrackMis

#check to see if it a nonsense character like a letter
bne $s1,123,endOfCurlyCheck
addi $s3,$s3,1
b endOfBackTrack
endOfCurlyCheck:
#############################
subi $s5,$s5,1
beq $s5,0,endOfBackTrack
addi $sp,$sp,4 #decrementing the stack to finish the pop procedure,it is placed here to ensure an error isnt thrown if the stack is empty
b backTrack1
endOfBackTrack:

addi $a2,$a2,1

addi $s6, $s6,1 #index

beq $s2,0,endParseBuffLoop
b parseBuffLoop

endParseBuffLoop:

beq $s7,127,top

b checkSuccess

###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
###############################################################################################################
#Print and error statements

#throws error if missing bracket
cBrackMis:

#li $v0,4
#la $a0,check
#syscall

li $v0,4
la $a0, newLine
syscall

li $v0,4
la $a0, errBrackMis
syscall

li $v0,11
la $a0,($s1)
syscall 

li $v0,4
la $a0, errBrackMis1
syscall

li $v0,1
la $a0,($s5)
syscall 

li $v0,4
la $a0, space
syscall

li $v0,11
la $a0,($s2)
syscall 


li $v0,4
la $a0, errBrackMis1
syscall

li $v0,1
la $a0,($s6)
syscall 

j endOfCheckSuccess
endCBrackMis:

#throws fail if objects are still on the stack
stackCheckFail:
li $v0,4
la $a0, newLine
syscall

li $v0,4
la $a0, errBrack
syscall


halfWayPoint:
beq $s1, 40 printGuard
beq $s1, 91, printGuard
beq $s1, 123, printGuard

j endOfCheckSuccess
printGuard:
li $v0,11
la $a0,($s1)
syscall

lw $s0,($sp)     
addi $sp,$sp,4
lw $s1,($sp)
addi $sp,$sp,4


beq $s1,0,endOfCheckSuccess
b halfWayPoint
endOfStackCheckFail:

#throws errors for extra brackets
extraBrackFail:
li $v0,4
la $a0, newLine
syscall

li $v0,4
la $a0, errBrackMis
syscall

li $v0,11
la $a0,($s2)
syscall 

li $v0,4
la $a0, errBrackMis1
syscall

li $v0,1
la $a0,($s5)
syscall 

j endOfCheckSuccess
endExtraBrackFail:

#la $a0, ($t0)
#syscall
#addi $sp,$sp,4
#displaying failed naming convention error message
checkNameFail:


li $v0,4
la $a0, newLine
syscall

li $v0,4
la $a0, errInv
syscall

j endOfCheckSuccess
endOfCheckFail:


checkSuccess:
#print checks to see what is being stored in the stack
#lw $t0,($sp)
#addi $sp,$sp,4
#li $v0,1
#la $a0,($t0)
#syscall

li $v0,4
la $a0, newLine
syscall




#succ 1 print
li $v0,4
la $a0, succ1
syscall

#divide by 2 add 1
#div $s3,$s3,2
#addi $s3,$s3,1
#value of counter divided by 2 plus one on a full success
li $v0,1
la $a0, ($s3)
syscall

#succ2 print
li $v0,4
la $a0, succ2
syscall
endOfCheckSuccess:

#lw $t0,($sp)
#addi $sp,$sp,4


#li $v0,11
#la $a0,($t0)
#syscall

#li $v0,4
#la $a0,check
#syscall


li $v0,4
la $a0, newLine
syscall

#closing the program cleaning using sycall 10
li $v0,10
syscall
