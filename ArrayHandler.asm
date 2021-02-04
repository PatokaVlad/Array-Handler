stseg SEGMENT PARA STACK "STACK"
	db 64 dup ("STACK")
stseg ENDS

dtseg SEGMENT PARA PUBLIC "DATA"
	num dw -32768

	rowstxt DB 'Enter number of rows (from 1 to 10): $'
	columnstxt DB 'Enter number of columns (from 1 to 10): $'
	numerElementstxt DB 'Enter number of elements (from 2 to 10): $'
	elemetnInputtxt DB 'Please enter the elements of the theArray: $'

	answertxt DB 'Press the key to select theArray type:', 10, 13
		      DB '1 - One-dimensional array', 10, 13
			  DB '2 - Two-dimensional array$'

	countertxt DB '[00][00]:$'
	counterElementtxt DB '[00][00]$'

	arraytxt DB 'Array preview:$'
	sumtxt DB 'Sum of the elements: $'
	sorttxt DB 'Sorted array: $'
	maxAndMintxt DB 'Min and Max element of the theArray: $'
	elementFindtxt DB "Enter the element to find: $"

	outRangeErrortxt DB 'Out of range!$'
	errortxt DB 'Incorect input!$'
	menuErrortxt DB 'Incorect variant!$'
	noElementtxt DB 'Element not found!$'
	pausetxt DB 'Press any key to continue.$'
	newLinetxt DB 10, 13, "$"
	
	theArray DW 100 DUP(0)

	rows DW 1 DUP(0)
	columns DW 1 DUP(0)
	arraySize DW 1 DUP(0)

	i DW 1 DUP(0)
	j DW 1 DUP(0)

	rowsInput DB 3,?,3 DUP(" ")
	columnsInput DB 3,?,3 DUP(" ")
	numInput DB 7,?,7 DUP(" ")
	elementFindInput DB 7,?,7 DUP(" ")

	elementFlag DB 1 DUP(0)
	parityFlag DB 1 DUP(0)
	minusFlag db 1 DUP(0)
	errorFlag db 1 DUP(0)

	out_str macro str 
		push  ax 
		xor ax, ax
		mov  ah, 09h 
		lea  dx, str 
		int  21h 
		pop  ax 
	endm  

	in_str macro input 
		push  ax 
		xor ax, ax
		lea dx, input
		mov ah, 10
		int 21h
		pop  ax 
	endm

	newline macro  
		push  ax 
		xor ax, ax
		lea dx, newLinetxt
		mov ah, 9
		int 21h
		pop  ax
	endm
  
	space macro
		push dx
		push ax
		xor ax, ax
		mov ax, ' '
		int 29h
		pop ax
		pop dx
	endm

	bubblesort macro array, size
		local while1
		local while2
		local continue
		local swap
		local endsort

		xor cx, cx
		mov cx, size
    
		while1: 
			push cx        
			mov ax, size
			dec ax
			push ax
			pop cx
			lea si, array
			while2: 
				mov ax, [si]      
				mov bx, [si+2]
				cmp ax, bx
				jns swap 
			continue:  
				add si, 2     
				loop while2
		pop cx
		loop while1
		jmp endsort
    
		swap:   
			mov [si], bx  
			mov [si+2], ax
			jmp continue

		endsort:
	endm

	index macro indexI, indexJ, counter_x
		local m4
		local m5
		local m6
		local returnIndex

		push ax
		push dx
		push si
		mov si, 10
		mov ax, indexI
		cmp ax, 9
		jng m4
		div si
		add ax, '0'
		mov counter_x+1, al
		add dx, '0'
		mov counter_x+2, dl
		xor ax, ax
		xor dx,dx
		mov ax, indexJ
		cmp ax, 9
		jng m5

		m6:
			div si
			add ax, '0'
			mov counter_x+5, al
			add dx, '0'
			mov counter_x+6, dl
			xor ax, ax
			xor dx,dx
			jmp returnIndex
		m4:
			add ax, '0'
			mov counter_x+2, al
			xor ax, ax
			mov ax, indexJ
			cmp ax, 9
			jg m6
		m5:
			add ax, '0'
			mov counter_x+6, al
		returnIndex:
			pop si
			pop ax
			pop dx
	endm


	to_number macro inputtxt, input
		local result
		local outOfRangeTranslationError
		local error
		local negative
		local numberTranslation
		local negativeConvert
		local start
		local return

		jmp start
  
		return:
			newline
 
		start:
			out_str inputtxt
			in_str input
			newline

			lea di, input + 1
			mov errorFlag, 0
			mov minusFlag, 0
			xor ax,ax

			mov al, byte ptr [di]
			mov cx, ax
			inc di
			cmp byte ptr [di], '-'
			je negative

			xor ax,ax 
			mov si, 10
			xor bh, bh
			jmp numberTranslation

		outOfRangeTranslationError:
			lea dx, outRangeErrortxt
			mov ah, 9
			int 21h
			mov errorFlag, 1
			jmp return

		error:
			lea dx, errortxt
			mov ah, 9
			int 21h
			mov errorFlag, 1
			jmp return

		negative:
			mov minusFlag, 1
			dec cx
			inc di
			mov si, 10
			xor bh, bh
			xor ax,ax 

		numberTranslation:
			cmp byte ptr [di], '9'
			ja error
			cmp byte ptr [di], '0'
			jb error

			mul si
			mov bl, [di]
			jo outOfRangeTranslationError
			sub bl, 30h 
			add ax, bx
			js outOfRangeTranslationError
			jc outOfRangeTranslationError
			inc di
			loop numberTranslation
			jmp result

		negativeConvert:
			neg ax
			mov minusFlag, 0

		result:
			cmp minusFlag, 1
			je negativeConvert
	endm

	output macro
		local m1
		local m2
		local m3

		or bx, bx
		jns m1
		mov al, '-'
		int 29h
		neg bx

		m1:
			mov ax, bx
			xor cx, cx
			mov bx, 10

		m2:
			xor dx, dx
			div bx
			add dl, '0'
			push dx
			inc cx
			test ax, ax
			jnz m2

		m3:
			pop ax
			int 29h
			loop m3
	endm

dtseg ENDS



cdseg SEGMENT PARA PUBLIC "CODE"
	main proc far
		assume ds:dtseg, ss:stseg, cs:cdseg
		push ds
		xor ax, ax
		push ax

		mov ax, dtseg
		mov ds, ax

		theMenuPoint:
			newline 
			out_str answertxt

			menuInput:
				xor ax, ax
				xor bx, bx
				mov ah, 8
				int 21h

				cmp al,'1'
				je goToOne
				cmp al, '2'
				je goToTwo
				cmp al, 27
				jne menuInputErrorPoint
				ret

			menuInputErrorPoint:
				out_str menuErrortxt
				newline
				jmp menuInput
			
			goToOne:
				call oneDimensionalArray
				jmp elementsInput
			goToTwo:
				call twoDimensionalArray
				jmp elementsInput

			elementsInput:
				xor si, si
				mul rows
				mov arraySize, ax

				xor bx, bx
				out_str elemetnInputtxt
				newline

				xor di, di
				lea di, theArray
				mov cx, rows

			row:
				inc i
				push cx
				mov cx, columns
				column:
					inc j
					index i, j, countertxt
					call numberInput
					loop column
				mov j, 0
				pop cx
				loop row

			newline
			out_str arraytxt 
			newline
			xor di, di
			lea di, theArray
			mov cx, rows

			rowElementOutput:
				push cx
				mov cx, columns
				columnElementOutput:
					xor bx, bx
					mov bx, [di]
					push cx
					output
					pop cx
					space
					add di,2
					loop columnElementOutput
				pop cx
				newline
				loop rowElementOutput

			sum:
				newline
				out_str sumtxt
				bubblesort theArray, arraySize
				xor di, di
				xor ax, ax
				xor cx, cx

				lea di, theArray
				lea si, theArray
				add si, arraySize
				add si, arraySize
				sub si, 2
				xor ax, ax
				mov ax, arraySize
				test ax, 1
				jnz parityPoint 
				xor dx, dx
				mov dl, 2
				div dl
				test ah, 1
				jnz parityPoint2d
				mov cx, ax
				xor ax, ax

				sumCalculation:
					add ax, [di]
					jo sumCalculationError
					add ax, [si]
					jo sumCalculationError
					add di, 2
					sub si, 2
					loop sumCalculation

				cmp parityFlag, 1
				jne sumResultOutput
				add di, 2
				add ax, [di]

				sumResultOutput:
					xor bx, bx
					mov bx, ax
					output
					newline
					xor ax, ax
					jmp maxAndMin

				parityPoint:
					mov parityFlag, 1
					xor bx, bx
					mov bl, 2
					div bl
					mov cl, al
					xor ax, ax
					jmp sumCalculation

				parityPoint2d:
					mov cx, ax
					xor ax, ax
					mov parityFlag, 1
					jmp sumCalculation

				sumCalculationError:
					out_str outRangeErrortxt
					newline

			maxAndMin:
				newline
				bubblesort theArray, arraySize
				xor di, di
				lea di, theArray
				out_str maxAndMintxt
				xor bx, bx
				mov bx, [di]
				output
				space
				xor bx, bx
				xor ax, ax
				add di, arraySize
				add di, arraySize
				sub di, 2
				mov bx, [di]
				output
				newline
				xor ax, ax

			sort:
				newline
				bubblesort theArray, arraySize
				out_str sorttxt
				newline
				xor di, di
				lea di, theArray
				mov cx, rows

				rowSort:
					push cx
					mov cx, columns
					columnSort:
					xor bx, bx
					mov bx, [di]
					push cx
					output
					pop cx
					space
					add di,2
					loop columnSort
					pop cx
					newline
					loop rowSort

				newline

			elementToFindInput:
				newline
				xor di, di
				mov i, 0
				mov j, 0
				to_number elementFindtxt, elementFindInput
				xor si, si
				mov si, ax
				mov cx, rows
				xor di, di
				lea di, theArray
				jmp rowFind

			find:
				mov elementFlag, 1
				index i, j, counterElementtxt
				out_str counterElementtxt
				xor ax, ax
				space
				int 29h
				add di, 2
				dec cx
				jmp columnFind

				rowFind:
					push cx
					mov cx, columns
					inc i
					columnFind:
						jcxz cxRebuild
						inc j
						cmp si, [di]
						jne noFind
						jmp find
						noFind:
						add di,2
						loop columnFind
					cxRebuild:
					mov j, 0
					pop cx
					loop rowFind

				cmp elementFlag, 1
				je findComplete
				out_str noElementtxt

				findComplete:
					newline

			ret
	main endp

	numberInput proc
		push cx
		push si
		push di
		to_number countertxt, numInput
		pop di
		mov [di], ax
		pop si
		pop cx
		add di, 2
		ret
	numberInput endp

	oneDimensionalArray proc
		oneArray:
			mov rows, 1
			theNumberInputPoint:
				newline
				to_number numerElementstxt, columnsInput
				mov columns, ax
				cmp ax, 10
				ja arrayErrorPoint3
				cmp ax, 2
				jb arrayErrorPoint3

				jmp oneEnd

			arrayErrorPoint3:
				out_str outRangeErrortxt
				newline
				jmp theNumberInputPoint
			oneEnd:
				ret
	onedimensionalArray endp

	twoDimensionalArray proc
		rowsInputPoint:
			newline
			to_number rowstxt, rowsInput
			mov rows, ax
			cmp ax, 10
			ja arrayErrorPoint
			cmp ax, 1
			jb arrayErrorPoint
			jmp columnsInputPoint

		arrayErrorPoint:
			out_str outRangeErrortxt
			newline
			jmp rowsInputPoint

		cmp ax, 1
		je readElements
		jmp columnsInputPoint

		readElements:
			call oneDimensionalArray
			ret
		columnsInputPoint:
			newline
			to_number columnstxt, columnsInput
			mov columns, ax
			cmp ax, 10
			ja arrayErrorPoint2
			cmp ax, 1
			jb arrayErrorPoint2
			jmp twoEnd
		arrayErrorPoint2:
			out_str outRangeErrortxt
			newline
			jmp columnsInputPoint
		twoEnd:
			ret
	twoDimensionalArray endp
cdseg ENDS
end main