	AREA	Adjust, CODE, READONLY
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
restart

; Code produced by Conor Gildea in first year in 2016/2017.

;Get user input brightness - Allowing negatives
; Code produced by Conor Gildea in first year in 2016/2017.
	LDR	R0, =brightnessInstruction	; 
	BL	fputs						; System.out.print("Please enter the negative or positive value you want to increase the brightness by:\n");
	LDR R0,=1;						; negativeNumbersAllowed = true;
	BL getUserValue					; getUserValue(negativeNumbersAllowed);
	BL negate						; negate(number,negativeNumberBoolean);
	MOV R7,R0;						; int brightnessNumber;
	LDR R1,=0						; negativeNumberEntered = false;

;Get user input contrast - Preventing negatives
enterNonNegativeContrast
	LDR	R0, =contrastInstruction	; 
	BL	fputs						; System.out.print("Please enter the value you want to change the contrast by,\n if the value is above 16 the contrast will increase,\n if it is below 16 the contrast will decrease and if the value is 16,\n the contrast will remain unchanged");
	LDR R0,=0						; negativeNumbersAllowed = false;
	BL getUserValue					; getUserValue(negativeNumbersAllowed);
	CMP R1,#0						; if(negativeNumberEntered)
	BNE notNegative					; {
	LDR R0, =negativeNumbersNotAllowed;
	BL fputs						;	System.out.print("\nNegative numbers aren't allowed. Please enter your contrast value again.");
	LDR R1,=0						; }
	B enterNonNegativeContrast		;
notNegative							;
	MOV R8,R0						; int contast;

	; Code produced by Conor Gildea in first year in 2016/2017.
;Get pixel starting address, picture height and picture width.
	BL	getPicAddr	; load the start address of the image in R4
	MOV	R4, R0
	BL	getPicHeight	; load the height of the image (rows) in R5
	MOV	R5, R0
	BL	getPicWidth	; load the width of the image (columns) in R6
	MOV	R6, R0

; Code produced by Conor Gildea in first year in 2016/2017.
;Have a nested for loop, checking each pixel, separating the different colour components, 
; Code produced by Conor Gildea in first year in 2016/2017.
;making the relevent adjustments to each component, combining components and saving the pixel value.
	MOV R9,#0	;
	MOV R10,#0	;
for				;
	CMP R9,R5	;for(int row = 0; row<image length; row++)
	BHS endfor	;{
	MOV R10,#0	;
for2			;
	CMP R10,R6	;	for(int column = 0; column<image width;column++)
	BHS endfor2	;	{
	MOV R1,R9	;		
	MOV R2,R10	;		
	MUL R0,R6,R1;		pixelPos = row x imageWidth;
	ADD R0,R0,R2;		pixelPos = pixelPos + column;
	LDR R12,=4	;		addressIncrement = 4;
	MUL R0,R12,R0;		pixelLocation = addressIncrement x pixelPos;
	ADD R1,R0,R4;		pixelLocation = startingPixelAddress + pixelLocation;
				;
	BL getPixelR;				Get red pixel value;
	MOV R2,R8;					int contrast;
	MOV R3,R7;					int brightness;
	BL contrastAndBrightness;	Change contrast and brightness
	LSL R0,#16;					Revert to red component location
	MOV R12,R0;					Save red component to final pixel
	BL getPixelG;				Get green pixel value;
	BL contrastAndBrightness;	Change contrast and brightness
	LSL R0,#8;					Revert to green component location
	ADD R12,R0,R12;				Save green component to final pixel
	BL getPixelB;				Get blue pixel value;
	BL contrastAndBrightness;	Change contrast and brightness
	ADD R0,R0,R12;				Save blue component to final pixel
	BL setPixel;				Save final pixel
	
	ADD R10,R10,#1;		}
	B for2		  ;
endfor2			  ;
	ADD R9,R9,#1  ;}
	B for		  ;
endfor
	BL	putPic		; re-display the updated image

stop	B	stop

; Code produced by Conor Gildea in first year in 2016/2017.
; getUserValue subroutine
; Allows input from user, converts ASCII number input into a hexademical number value
; Parameters R0: Display minus symbol boolean - If value true "1", it will allow for the minus symbol to be displayed and negative boolean allowed to be set
; Return values R0: user entered value in hexadecimal form R1: Return 1 if negative number entered, else return 0;
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
	SUB R5,R0,#0x30 		; 			Converting the new digit from ASCII symbol to actual hexadecimal number (0x39 = "9" --> 0x09)
	ADD R4,R4,R5    		;			Adding the new digit to the running total
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
	BX lr;

	; Code produced by Conor Gildea in first year in 2016/2017.
; negate subroutine
; Converts a number into a negative number in 2 Compliment form
; Parameters R0: Value to convert R1: Boolean - If true (1), it converts the value to a negative number in 2 Compliment form
; Return values R0: value in 2 Compliment form R1: Value set back to zero - No Longer necessary
negate
	STMFD sp!, {lr} ; save link register
	MOV R4,R0
	CMP R12,#1					;if (negativeNumber=true) 	//Converts negative numbers to 2 Compliment Form
	BNE negativenumberchange	;{
	MVN R4, R4 					; 	value = NOT value (invert bits)
	ADD R4, R4, #1 				; 	value = value + 1 (add 1)	
negativenumberchange			;}
	MOV R1,#0					; negativeNumber = false;
	MOV R0,R4
	LDMFD sp!, {lr} ; restore link register
	BX lr;

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
; contrastAndBrightness subroutine
; Changes contrast and brightness of a pixel component
; Parameters R0: componentValue		R2: contrast 	R3: brightness 
; Return values R0: adjustedComponentValue
contrastAndBrightness
	CMP R2,#16					;if(contrast!=16)
	BEQ skipDivisionAndAddition	;{
	MUL R0,R2,R0				;	numerator = componentValue x contrast;
	LSR R0,#4 					;	componentValue = numerator/16;
skipDivisionAndAddition			;}
	CMP R3,#0					;if(brightness==0)
	BEQ skipAddition			;{
	CMP R3,#0x80000000			;	if(brightness>0)
	BHI negative				;	{
	ADD R0,R0,R3				;		componentValue+= brightness;
	B skipNegative				;	}
negative						;	else if(brightness<0)
								;	{
	MVN R3, R3 					; 		value = NOT value (invert bits)
	ADD R3, R3, #1 				; 		value = value + 1 (add 1)	
	SUB R0,R0,R3				;		componentValue -= brightness;
	MVN R3, R3					; 		value = NOT value (invert bits)
	ADD R3, R3, #1 				; 		value = value + 1 (add 1)	
skipNegative					;	}
skipAddition					;}
	CMP R0,#0x80000000			;if(componentValue<0)
	BHI negative2				;{
	B skipneg					;
negative2						;	componentValue = 0;
	MOV R0,#0					;
	B finished					;
skipneg							;}
	CMP R0,#255					;else if(componentValue>255)
	BLO notTooHigh				;{
	MOV R0,#255					;	componentValue = 255;
	B finished					;
notTooHigh						;}
	CMP R0,#0					;else if(componentValue!<=0)	//Making sure values are within range
	BGT withinRange				;{
	MOV R0,#0					;	componentValue = 0;
	B finished					;}
withinRange						;
finished						;
	BX lr						;
	
	; Code produced by Conor Gildea in first year in 2016/2017.
; setPixel subroutine
; Saves a pixel value in an address
; Parameters R0:Pixel Values R1:Address of pixel
; Return values: Pixel saved in memory
setPixel						;			
	STR R0,[R1]					; Memory[pixelAddress] = pixelValues;
	BX lr						;
endprograminvalid1
endprograminvalid2
		LDR R0,=invalidInput	;	System.out.print("\nInvalid Input, please restart and enter valid input.");
		BL fputs				;
		B restart				;

		; Code produced by Conor Gildea in first year in 2016/2017.
		
        AREA	MyStrings, DATA, READONLY
brightnessInstruction	DCB	"\nPlease enter the negative or positive value you want to \nincrease the brightness by:\n",0
contrastInstruction		DCB	"\nPlease enter the value you want to change the contrast by,\nif the value is above 16 the contrast will increase,\nif it is below 16 the contrast will decrease and if the value is 16,\nthe contrast will remain unchanged.The value must be positive.\n",0
invalidInput 			DCB "\nInvalid Input, please restart and enter valid input.",0 ; Code produced by Conor Gildea in first year in 2016/2017.
negativeNumbersNotAllowed			DCB "\nNegative numbers aren't allowed. Please enter your contrast value again.",0
	END	