	AREA	BonusEffect, CODE, READONLY
	IMPORT	main
	IMPORT	getPicAddr
	IMPORT	putPic
	IMPORT	getPicWidth
	IMPORT	getPicHeight
	EXPORT	start
	PRESERVE8
start
	BL boxBlur
stop	B 	stop

; Code produced by Conor Gildea in first year in 2016/2017.

;boxBlur subroutine
;Applies a box blur to an image multiple times
;Parameters: None
;Returns: A Saved Image which has had a box blur applied multiple times to resemble a 
boxBlur ; Code produced by Conor Gildea in first year in the academic year 2016/2017.
	LDR R4,=0		; boxBlurIterations
restart				;
	STMFD SP!, {R4}	; STORE boxBlurIterations
	BL	getPicHeight; load the height of the image (rows) in R5
	MOV	R5,R0		;
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6,R0		;	
	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4,R0		;	
	MOV R2,R6		;
	MOV R3,R5		;
	MOV R7, #0		; currentColumn = 0;
	MOV R8, #0		; currentRow = 0;
	MOV R5,R2		; columnSize = picture.getWidth();
	MOV R6,R3		; rowSize = picture.getHeight();
processEachPixelInImage
	
	MOV R9,#1						;boxIndex = 1;
	CMP R7,R5 						;if(currentColumn!=columnSize)
	BNE processEachBoxBlur 	;{ Branch to processEachBoxBlur }
									;else if(currentColumn==columnSize)
	LDR R7,=0						;currentColumn=0; 						
	ADD R8, #1 						;currentRow++;
	CMP R8,R6						;if(currentRow==rowSize)
									;{
	BEQ boxBlurProcessFinished	;	Branch to boxBlurProcessFinished;
									;}
									
									; Code produced by Conor Gildea in first year in 2016/2017.
;processEachBoxBlur is run each time, 
;the program needs to find the value of the 
;next pixel in the box blur
processEachBoxBlur
	MOV R0,R7 
	MOV R1,R8
	SUB R8,R8,#1 			;currentRow = currentRow - 1;
	SUB R7,R7,#1 			;currentColumn = currentColumn - 1;
	LDR R3,=0 				;numberOfCompletedDiagonalPixels = 0;
	LDR R12,=0 				;redTotal = 0;
	LDR R11,=0 				;greenTotal = 0;
	LDR R10,=0 				;blueTotal = 0;
boxBlurIterations
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
	BL	getPicAddr	; load the start address of the image in R4
	ADD R2,R2,R0			; 	pixelLocation = pixelLocation + pictureStartingAddress
	MOV R1,R2				;
	BL getPixelB			;	blue = getPixelB;
	ADD R10,R10,R0			;	bTotal += blue;
	BL getPixelG 			;	green = getPixelG;
	ADD R11,R11,R0			;	gTotal += green;
	BL getPixelR			;	red = getPixelR;
	ADD R12,R12,R0			;	rTotal += red;
	ADD R3,R3,#1			;	numberOfCompletedDiagonalPixels++;
pixelOutOfBounds			;}
	ADD R9,R9,#1			; boxIndex++;
	CMP R9,#4				; if(boxIndex==4)
	BNE sideOfBox			;{
	SUB R7,R7,#3			;	currentColumn -= 3
	ADD R8,R8,#1			;	currentRow += 1
sideOfBox					;}
	CMP R9,#7				; else if(boxIndex==7)
	BNE sideOfBox2			;{
	SUB R7,R7,#3			;	currentColumn -= 3
	ADD R8,R8,#1			;	currentRow += 1
sideOfBox2					;}
	CMP R9,#10				; else if(boxIndex!=10)
	BEQ sideOfBox3			;{
	ADD R7,R7,#1			;	currentColumn += 1
	B boxBlurIterations		;	Branch to boxBlurIterations;
							;}
							; else
sideOfBox3					;{
	SUB R7,R7,#1			;	currentRow -= 1
	SUB R8,R8,#1			;	currentRow -= 1
	B savePixelNow			;}
savePixelNow		;
	MOV R0,R7		;
	MOV R1,R8		;
	STMFD SP!, {R0-R1}; STORE currentColumn and currentRow;
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
;Ensuring each component value	;
; is within the correct range	;
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
								;
	LDMFD SP!, {R0-R1}			; LOAD prev. currentColumn and prev. currentRow;
	MUL R2,R1,R5				; pixelLocation = currentRow x columnSize;
	ADD R2,R2,R0				; pixelLocation = pixelLocation + currentColumn;
	LSL R2,R2,#2				; pixelLocation = pixelLocation x 4;
	MOV R8,R0					;
	BL	getPicAddr				; load the start address of the image in R4
	ADD R2,R2,R0				; pixelLocation = pixelLocation + pictureStartingAddress;
	MOV R0,R8					;
	MOV R8,#0;					;
	STR R10, [R2]				; STORE pixel in pixelLocation;
	MOV R7,R0					; currentColumn = prev.currentColumn;
	MOV R8,R1					; currentRow = prev.currentRow;
	ADD R7,R7,#1				; currentColumn++;
	B processEachPixelInImage	; Move onto the next pixel in the image
boxBlurProcessFinished		;
	BL	putPic					; re-display the updated image
	LDMFD SP!, {R4}				; LOAD boxBlurIterations;
	CMP R4,#2					; if(boxBlurIterations!=2)
	BEQ finished4				; {
	ADD R4,R4,#1				;	boxBlurIterations++; Branch to restart
	B restart					; }
finished4						;
	BX lr
	; Code produced by Conor Gildea in first year in 2016/2017.
;div subrountine
;Divides the first registry by the second registry
;Parameters: R0; Number to be divided R1: Divisor
;Returns quotient in R0
div
	MOV R2, #0
whilediv
	CMP R0,R1
	BLS stopdiv
	ADD R2,R2,#1
	SUB R0,R0,R1
	B whilediv
stopdiv
	MOV R0,R2
	BX lr
	; Code produced by Conor Gildea in first year in 2016/2017.
; getPixelR subroutine
; Gets red value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Red component 
getPixelR
	LDR R0,[R1]
	LSR R0,R0,#16
	BX lr
	; Code produced by Conor Gildea in first year in 2016/2017.
; getPixelG subroutine
; Gets green value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Green component 
getPixelG
	LDR R0,[R1]
	LSL R0,R0,#16
	LSR R0,R0,#24
	BX lr
	
	; Code produced by Conor Gildea in first year in 2016/2017.
; getPixelB subroutine
; Gets blue value of a pixel
; Parameters R1: Address of pixel
; Return values R0: Blue component 
getPixelB
	LDR R0,[R1]
	LSL R0,R0,#24
	LSR R0,R0,#24
	BX lr

	END	