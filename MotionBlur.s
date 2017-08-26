	AREA	MotionBlur, CODE,READONLY
	IMPORT	main
	IMPORT	getkey
	IMPORT  fputs
	IMPORT	sendchar
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
	PRESERVE8
start

; Code produced by Conor Gildea in first year in 2016/2017.

restart
enterNonNegativeRadius			;
	LDR	R0, =motionBlurRadius	;
	LDR R1,=0;					;
	BL	fputs					; System.out.print("Please enter the radius value for your motion blur");
	LDR R0,=0;					; allowNegativeBlurRadius = false;
	BL getUserValue				; userValue = getUserValue(allowNegativeBlurRadius);
	CMP R1,#0					; if(negativeNumberEntered)
	BNE notNegative				; {
	LDR R0, =negativeNumbersNotAllowed;	System.out.print("\nNegative numbers aren't allowed. Please enter your contrast value again.");
	BL fputs					;
	LDR R1,=0;					;
	B enterNonNegativeRadius	;		Branch to enterNonNegativeRadius
notNegative						; }
	MOV R1,R0					; radius = userInput.nextInt();

	BL motionBlur
	BL	putPic					; re-display the updated image
	
stop	B 	stop

; Code produced by Conor Gildea in first year in 2016/2017.

; getUserValue subroutine
; Allows input from user, converts ASCII number input into a hexademical number value
; Parameters R0: Display minus symbol boolean - If value true "1", it will allow for the minus symbol to be displayed and negative boolean allowed to be set
; Return values R0: user entered value in hexadecimal form R1: Return 1 if negative number entered, else return 0;
; Code produced by Conor Gildea in first year in 2016/2017.
getUserValue
	MOV R2,R0;
	LDR R1,=0;
	LDR R4,=0;
	STMFD sp!, {lr} ; save link register
read
	BL	getkey				; Read key from console
	CMP	R0,#0x0D  			; if (key != "Enter")
	BEQ	endRead				; {
	CMP R2,#1
	BEQ negativeNumbersAllowed
	CMP R0,#0x2D			; 		if (key != "-")
	BEQ negativenumberskip 	;		{
	BL sendchar
	B minusSkip
negativeNumbersAllowed
	BL	sendchar			; 		echo key back to console
	CMP R0,#0x2D			; 		if (key != "-")
	BEQ negativenumberskip 	;		{
minusSkip
	CMP R0,#0x30			;			if(key>"0" )||(key<"9") *ASCII symbols* // Preventing non-numbers being entered
	BLO endprograminvalid1	;			{
	CMP R0,#0x39			;
	BHI endprograminvalid2	;
	LDR R10,=10;
	MUL R4,R10,R4  			;  			PreviousRunningTotal*10
	SUB R2,R0,#0x30 		; 			Converting the new digit from ASCII symbol to actual hexadecimal number (0x39 = "9" --> 0x09)
	ADD R4,R4,R2    		;			Adding the new digit to the running total
							;			}
negativenumberskip			;		}
	CMP R0,#0x2D			;		else if (key = "-")
	BNE negativenumber		; 		{
	MOV R1,#1				;			boolean negativeNumber = true
	MOV R12,#1
negativenumber				;		}
	B	read				; 	}
							;}
endRead
	MOV R0,R4
	LDMFD sp!, {lr} ; restore link register
	BX lr
	
; Code produced by Conor Gildea in first year in 2016/2017.
;motionBlur subroutine
;Causes a motion blur to be applied to a photo
;Parameters: R1: radiusOfMotionBlur
;Returns: A saved image with a motion blur, of the inputted radius, applied.
; Code produced by Conor Gildea in first year in 2016/2017.
motionBlur
	BL	getPicHeight; load the height of the image (rows) in R5
	MOV	R5,R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6,R0	
	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4,R0	
	MOV R2,R6
	MOV R3,R5
	MOV R9,R1		; radiusBackup = radius;				//Move radius to R9, to leave R1 free for subroutines;
	MOV R7, #0		; currentColumn = 0;
	MOV R8, #0		; currentRow = 0;
	MOV R5,R2		; columnSize = picture.getWidth();
	MOV R6,R3		; rowSize = picture.getHeight();
processEachPixelInImage
	
	CMP R7,R5 						;if(currentColumn!=columnSize)
	BNE processEachDiagonalLine 	;{ Branch to processEachDiagonalLine }
									;else if(currentColumn==columnSize)
	LDR R7,=0						;currentColumn=0; 						
	ADD R8, #1 						;currentRow++;
	CMP R8,R6						;if(currentRow==rowSize)
									;{
	BEQ motionBlurProcessFinished	;	Branch to motionBlurProcessFinished;
									;}
			;processEachDiagonalLine is run each time, 
			;the program needs to find the value of the 
			;next pixel in the motion blur
			; Code produced by Conor Gildea in first year in 2016/2017.
processEachDiagonalLine
	MOV R0,R7 
	MOV R1,R8
	STMFD SP!, {R0-R1}		;STORE currentColumn and currentRow
	SUB R8,R9 				;currentRow = currentRow - radius;
	SUB R7,R9 				;currentColumn = currentColumn - radius;
	LDR R3,=0 				;numberOfCompletedDiagonalPixels = 0;
	LDR R12,=0 				;redTotal = 0;
	LDR R11,=0 				;greenTotal = 0;
	LDR R10,=0 				;blueTotal = 0;
diagonalLineLoop
	CMP R8, #0				;
	BLT pixelOutOfBounds	;
	CMP R7, #0				;	
	BLT pixelOutOfBounds	;if((!currentRow is outside boundaries of the image)||(currentColumn is outside boundaries of the image))
	CMP R7,R5				;{	
	BGE pixelOutOfBounds	;
	CMP R8,R6				;
	BGE pixelOutOfBounds	;
	MUL R2,R8,R5			; 	pixelLocation = currentRow x columnSize
	ADD R2,R2,R7			; 	pixelLocation = pixelLocation + currentColumn
	LSL R2,R2,#2			; 	pixelLocation = pixelLocation x 4;
	ADD R2,R2,R4			; 	pixelLocation = pixelLocation + pictureStartingAddress
	MOV R1,R2				;
	BL getPixelB			;	blue = getPixelB;
	ADD R10,R10,R0			;	bTotal += blue;
	BL getPixelG 			;	green = getPixelG;
	ADD R11,R11,R0			;	gTotal += green;
	BL getPixelR			;	red = getPixelR;
	ADD R12,R12,R0			;	rTotal += red;
	ADD R3,R3,#1			;	numberOfCompletedDiagonalPixels++;
pixelOutOfBounds			;}
	ADD R7,R7,#1 			;currentColumn++;
	ADD R8,R8,#1			;currentRow++;
	LDMFD SP, {R0-R1}		;LOAD currentColumn and currentRow;
	ADD R2,R0,R9			;maxColumn = prev.currentColumn+radius
	CMP R7,R2				;if(currentColumn<maxColumn)
	BGT savePixel 			;{
	B diagonalLineLoop		;	Branch to diagonalLineLoop;
savePixel					;}
	STMFD SP!, {R0-R1}		;STORE currentColumn and currentRow;
	MOV R0,R10		;
	MOV R1,R3		;
	BL div 			;	red = redTotal/numberOfCompletedDiagonalPixels
	MOV R10,R0		;
	MOV R0,R11		;
	MOV R1,R3		;
	BL div			;	green = greenTotal/numberOfCompletedDiagonalPixels
	MOV R11,R0		;
	MOV R0,R12		;
	MOV R1,R3		;
	BL div 			;	blue = blueTotal/numberOfCompletedDiagonalPixels
	MOV R12,R0		;
	MOV R0,R12		;

				;Ensuring each component value 
				; is within the correct range
	CMP R0,#255					;if(componentValue>255)
	BLO notTooHigh				;{
	MOV R0,#255					;	componentValue = 255;
	B finished					;
notTooHigh						;}
	CMP R0,#0					;else if(componentValue!<=0)	//Making sure values are within range
	BGT withinRange				;{
	MOV R0,#0					;	componentValue = 0;
	B finished					;}
finished						;
withinRange						;
	MOV R12,R0					;
	MOV R0,R11					;
	CMP R0,#255					;if(componentValue>255)
	BLO notTooHigh2				;{
	MOV R0,#255					;	componentValue = 255;
	B finished2					;
notTooHigh2						;}
	CMP R0,#0					;else if(componentValue!<=0)	//Making sure values are within range
	BGT withinRange2			;{
	MOV R0,#0					;	componentValue = 0;
	B finished2					;}
finished2						;
withinRange2					;
	MOV R11,R0					;
	MOV R0,R10					;
	CMP R0,#255					;if(componentValue>255)
	BLO notTooHigh3				;{
	MOV R0,#255					;	componentValue = 255;
	B finished3					;
notTooHigh3						;}
	CMP R0,#0					;else if(componentValue!<=0)	//Making sure values are within range
	BGT withinRange3			;{
	MOV R0,#0					;	componentValue = 0;
	B finished3					;}
withinRange3					;
finished3						;
	LSL R12,R12,#16				;
	LSL R11,R11,#8 				; Shifting the colour components to their correct location
	MOV R10,R0					;
	ADD R10,R11					;
	ADD R10,R12					; Combining colour components to form colour of pixel;
	LDMFD SP!, {R0-R1}			; LOAD prev. currentColumn and prev. currentRow;
	MUL R2,R1,R5				; pixelLocation = currentRow x columnSize;
	ADD R2,R0,R2				; pixelLocation = pixelLocation + currentColumn;
	LSL R2,R2,#2				; pixelLocation = pixelLocation x 4;
	ADD R2,R2,R4				; pixelLocation = pixelLocation + pictureStartingAddress;
	STR R10, [R2]				; STORE pixel in pixelLocation;
	MOV R7,R0					; currentColumn = prev.currentColumn;
	MOV R8,R1					; currentRow = prev.currentRow;
	ADD R7,R7,#1				; currentColumn++;
	B processEachPixelInImage	; Move onto the next pixel in the image
motionBlurProcessFinished		;
	BX lr
	
;div subrountine
;Divides the first registry by the second registry
; Code produced by Conor Gildea in first year in 2016/2017.
;Parameters: R0; Number to be divided R1: Divisor
;Returns quotient in R0
div
	MOV R2, #0
whilediv
	CMP R0,R1
	BLO stopdiv
	ADD R2,R2,#1
	SUB R0,R0,R1
	B whilediv
stopdiv
	MOV R0,R2
	BX lr

; getPixelR subroutine
; Gets red value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Red component 
getPixelR
	LDR R0,[R1]
	LSR R0,R0,#16
	BX lr

; getPixelG subroutine
; Gets green value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Green component 
getPixelG
	LDR R0,[R1]
	LSL R0,R0,#16
	LSR R0,R0,#24
	BX lr

; getPixelB subroutine
; Gets blue value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Blue component 
getPixelB
	LDR R0,[R1]
	LSL R0,R0,#24
	LSR R0,R0,#24
	BX lr
; Code produced by Conor Gildea in first year in 2016/2017.

; Negate subroutine
; Converts a number into a negative number in 2 Compliment form
; Code produced by Conor Gildea in first year in 2016/2017.
; Parameters R0: Value to convert R1: Boolean - If true (1), it converts the value to a negative number in 2 Compliment form
; Return values R0: value in 2 Compliment form R1: Value set back to zero - No Longer necessary
negate
	STMFD sp!, {lr} ; save link register
	MOV R4,R0
	CMP R12,#1					;if (negativeNumber=true) 	//Converts negative numbers to 2 Compliment Form
	BNE negativenumberchange	;{
	MVN R4,R4 					; 	value = NOT value (invert bits)
	ADD R4,R4, #1 				; 	value = value + 1 (add 1)	
negativenumberchange			;}
	MOV R1,#0					; negativeNumber = false;
	MOV R0,R4
	LDMFD sp!, {lr} ; restore link register
	BX lr;

	; Code produced by Conor Gildea in first year in 2016/2017.
endprograminvalid1
endprograminvalid2
		LDR R0,=invalidInput;	System.out.print("\nInvalid Input, please restart and enter valid input.");
		BL fputs			;
		B restart			;
			        AREA	MyStrings, DATA,READONLY
motionBlurRadius	DCB	"\nPlease enter the radius value for your motion blur\n",0
invalidInput 			DCB "\nInvalid Input, please restart and enter valid input.",0
negativeNumbersNotAllowed			DCB "\nNegative numbers aren't allowed. Please enter your contrast value again.",0
	END
                                                                                                                                                                                                                                                                                                                                                                                   
																																																																																																	  
																																																																																																	  
																																																																																																	  
	END