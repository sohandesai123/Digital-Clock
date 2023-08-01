#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS = 0000h#
#IP = 0000h#

#DS = 0000h#
#ES = 0000h#

#SS = 0000h#
#SP = FFFEh#

#AX = 0000h#
#BX = 0000h#
#CX = 0000h#
#DX = 0000h#
#SI = 0000h#
#DI = 0000h#
#BP = 0000h#  
;since this is a simulation the cs and ip are both at zero

; START OF CODE
jmp start1
;first few locationsin CS are for IVT 
;that is the first 1024 locations 

db 5 dup(0)
dw try1
dw 0000h 
db 1012 dup(0) 

;Allocating memory to 8255A8
port1a equ 00h
port1b equ 02h 
port1c equ 04h
creg1 equ 06h   

;Allocating memory to 8255B
port2a equ 10h
port2b equ 12h
port2c equ 14h  
creg2 equ 16h

;Allocating memory for 8253 timer  
counter0 equ 08h
counter1 equ 0Ah
counter2 equ 0Ch			
creg3 equ 0Eh  ;change           

;Allocating memory for 8259 	
;port8259a equ 18h
;port8259b equ 1Ah  

                  
                  
start1:
        cli

; intialize ds, es,ss to start of RAM that is at 02000h
        mov ax,0200h
        mov ds,ax
        mov es,ax
        mov ss,ax
        mov sp,0FFFEH    


stat db 00h
;count values
	count_sec db 60
	count_min db 60
	count_hour24 db 24
	count_dayleastleap db 29
	count_dayleast db 28
	count_daymost db 31
	count_dayless db 30 
	count_month db 12
	second db 0
	min db 0
	hour db 0
	day db 01
	month db 01
	year dw 2022
	year_lower db 22
	year_upper db 20
	digit db 0
	year_mod db 0 
	format_check db 0
	hour_12 db 0 
	phase db 0
	hour_l db 0
	hour_h db 0  
	min_l db 0
	min_h db 0  
	sec_l db 0
	sec_h db 0
	day_h db 0
	day_l db 0
	month_l db 0
	month_h db 0
	yearu_l db 0
	yearu_h db 0
	yearl_l db 0
	yearl_h db 0
	checker db 0
	old db 0
	
	
;alarm values
	alarm_hour24 db 0 
	alarm_min db 0
	alarm_phase db 0        

;Setting 8255B as the output
mov al, 10000000b 			
out creg2, al

;Setting 8255A as the input
mov al, 10011011b
out creg1, al  

;Initialization of 8253 counter
mov al, 00110100b
out creg3, al
;mov al, 01110100b
;out creg3, al   
mov al, 0E8h 
out counter0, al 
mov al, 03h 
out counter0, al 
;mov al, 88h 
;out counter0, al 
;mov al, 13h 
;out counter0, al
;mov al, 10h 
;out counter0, al
;mov al, 27h
;out counter0, al
;mov al, 0fah 
;out counter1, al
;mov al, 00h
;out counter1, al  
   
;initialization of 8259   
;ICW1
;mov al, 00010011b
;out port8259a, al  
;ICW2
;mov al, 10000000b ;INT 80h has is being sent to IR0
;out port8259b, al  
;ICW4
;mov al, 00000001b
;out port8259b, al    
;OCW1
;mov al, 11111110b
;out port8259b, al  

;initialize LCD for 2 lines & 5*7 matrix
		  mov       al,01h
		  out       port2c,al
		  call      delay_20ms
		  mov       al,38h
		  out       port2b,al
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms
;set mode agian - has to be done twice

		  mov       al,01h
		  out       port2c,al
		  call      delay_20ms
		  mov       al,38h
		  out       port2b,al
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms 
;command to display no blinking cursor - 0eh

		  mov       al,01h
		  out       port2c,al
		  call      delay_20ms
		  mov       al,0ch
		  out       port2b,al
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms
;increment cursor command  - 06h

		  mov       al,01h
		  out       port2c,al
		  call      delay_20ms
		  mov       al,06h
		  out       port2b,al
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms
;clear display  command - 01h

		  mov       al,01h
		  out       port2c,al
		  call      delay_20ms
		  mov       al,01h
		  out       port2b,al 
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms 
;move cursor to line 1 position 1 command - 80h

		  out       port2c,al
		  call      delay_20ms
		  mov       al,80h
		  out       port2b,al 
		  mov       al,00h
		  out       port2c,al
		  call      delay_20ms
	;initialisation end


;Setting default values (assuming time starts at midnight of 1st Jan)
		mov second, 55
		mov min, 59
		mov hour, 23
		
		
;		mov hour_12, 12
;		mov format_check, 0
;		mov phase, 1
;
		mov day, 29
		mov month, 2
;		mov year, 2010
		mov	year_lower, 12
		mov year_upper, 20		; setting date to 1/1/2022
;		
		mov count_sec, 60
		mov count_min, 60
		mov count_hour24, 24
		mov count_dayless, 31 ;for months 4, 6, 9, 11
        mov count_dayleastleap, 30 ;for month 2 if leap
        mov count_dayleast, 29 ;for month 2 if not leap
        mov count_daymost, 32
		mov count_month, 13 
		mov checker,0
;
;        Setting alarm defaults to 00:15
;		mov alarm_hour24, 00
;		mov alarm_min, 15
;		mov alarm_phase, 1                          

;mov  al, 02h
;out 30h, al ;to trick data bus                       ;call display 
;test: sti
;jmp test           

             
;MAIN PROGRAM
;Polling for port1a
            ;checking if alarm on/off pressed                        
poll1a1:    sti  
            ;call display
            in al, port1a
            and al, 00010000b
            cmp al, 00010000b
            jne poll1a2
            ;call buzzer

            ;checking if 12/24 is pressed
poll1a2:    in al, port1a   
            and al, 00000001b
            mov format_check, al
            
poll1c:	    in al, port1c
			mov bl, al
			call delay_20ms
			in al, port1c
			cmp al, bl
			jne optend
		                           
		                
sethour:	cmp al, 01h			;Set Hour
			call set_hour
			
			jne setmin
				
			call set_hour
		
			jmp optend

setmin: 	cmp al, 02h 			;Set Minute
			jne setsec
			call set_minute
			jmp optend

setsec: 	cmp al, 04h 			;Set Second
			jne setdate
			call set_second
			jmp optend

setdate:	cmp al, 08h 			;Set Date
			jne setmonth
			call set_date  
			jmp optend

setmonth:	cmp al, 10h 			;Set Month
			jne setyear
			call set_month  
			jmp optend
			
setyear:	cmp al, 20h 			;Set Year
			jne setalarmhour
			call set_year 
			jmp optend

setalarmhour: cmp al, 40h 			;Set Alarm Hour
			jne setalarmmin
			call set_alarm_hour
			jmp optend

setalarmmin: cmp al, 80h			;Set Alarm Min
			jne optend
			call set_alarm_min 
		  
optend:	    
            ;call display
            jmp poll1a1


try1:	;interrupt service routine for NMI      
        ;sti  
        ;cli
		;call display
	;When         
	mov al,checker
	cmp al,01
	je isrend
		
	mov al, second
		inc al
		mov second, al
		cmp al,60
		jne normal
       ;call display
		mov second, 00		;make second 0 if it is 60
		mov al, min
		inc al
		mov min, al
		cmp al, count_min
		jne normal
      ;call display
		mov min, 00			;make minute 0 if it is 60
		mov al, hour
		inc al
		mov hour, al
		cmp al, count_hour24
		jne normal
      ;call display
    	mov hour, 00		;make hour 0 if it is 24				
		mov al, day
		inc al
		mov day, al	
	  ; display
		call check_month	
		jz feborother		;zero flag 1 if it is a month with 30 or less days
		mov al, day
		cmp al, count_daymost			
		jne normal
		jmp month_increment
      
feborother: 
		call check_february
		jz checkleap				;zero flag 1 if it is february
		mov al, day
		cmp al, count_dayless			
		jne normal
		jmp month_increment

checkleap:		
		call check_leap
		jz notleap					;zero flag 1 if it is not a leap year
		mov al, day
		cmp al, count_dayleastleap			
		jne normal
		jmp month_increment

notleap: 
		mov al, day
		cmp al, count_dayleast			
		jne normal

month_increment:
		mov day, 1						
		mov al, month			
		inc al
		mov month, al
		cmp al, count_month				;compare month with 12
		jne normal							

		mov month, 1						;increment year
		mov al, year_lower
		inc al   
		mov year_lower, al
		cmp al, 100
		jne normal
		
		mov year_lower, 00
		mov al, year_upper
		inc al
		mov year_upper, al
		

normal:
	call disp_hr
	call disp_min	
	call disp_sec 
	call disp_day 
	call disp_month 
	call disp_year
	
isrend:					
iret


;END OF ISR 


;subroutine check_month
check_month proc near
		mov al, month
		cmp al, 02
		jz setzero1
		cmp al, 04
		jz setzero1
		cmp al, 06
		jz setzero1
		cmp al, 09
		jz setzero1
		cmp al, 11
		jz setzero1
		;beginning of clearing zero flag
		mov dx, ax
		Lahf
		and ah, 10111111b
		SAHF
		MOV ax, dx
		;end of clearing zero flag
		jmp endofcheck_month
setzero1: 
		;beginning of setting zero flag
		mov dx, ax
		Lahf
		or ah,01000000b
		SAHF
		mov ax, dx
		;end of setting zero flag
endofcheck_month: 
		ret
check_month endp


;subroutine check_february
check_february proc near
		mov al, month
		cmp al, 02
		jz setzero3
		;beginning of clearing zero flag
		mov dx, ax
		Lahf
		and ah,10111111b
		SAHF
		MOV ax, dx
		;end of clearing zero flag
		jmp endofcheck_february
setzero3: 
		;beginning of setting zero flag
		mov dx, ax
		Lahf
		or ah,01000000b
		SAHF
		mov ax, dx
		;end of setting zero flag
endofcheck_february: 
		ret
check_february endp


check_leap proc near
		mov al, year_lower
		mov ah, 00
		mov dh, 04
		div dh
		cmp ah, 00
		jnz setzero2
		;beginning of clearing zero flag
		mov dx, ax
		Lahf
		and ah,10111111b
		SAHF
		MOV ax, dx
		;end of clearing zero flag
		jmp endofcheck_leap

setzero2: 
		;beginning of setting zero flag
		mov dx, ax
		Lahf
		or ah,01000000b
		SAHF
		mov ax, dx
		;end of setting zero flag
endofcheck_leap: 
		ret
check_leap endp
		
;creating a subroutine that gives a delay 20ms
delay_20ms proc near
				push 	cx
				mov 	cx,900d
				
dl1:			nop							
				loop 	dl1					
				
				pop 	cx					
				ret
delay_20ms endp    

set_hour proc near	
	mov checker,01
;rechecking if set_hour has been selected with debounce
sh1: in al, port1c
	 cmp al, 01h			
	 jnz shend	
	 call delay_20ms
	 in al, port1c
	 cmp al, 01h			
	 jnz shend

;Checking the format status with debounce
            in al, port1a   
            and al, 00000001b
            mov format_check, al
			call delay_20ms
			in al, port1a   
            and al, 00000001b
            mov format_check, al


;check if increment is being given
	in al,port1b 
	cmp al,00h
	je shold
	mov bl,al
	call delay_20ms 
	
	in al,port1b
	cmp bl,al
	jne shc2		;if value given after debounce doesn't match - jmp
    ;Checking if multiple increment values have been sent
    mov bh,old
    cmp bh,0
    jne shc2
    
	and al,00000011b
	cmp al, 02h
	jne shdec
	mov bl,hour
	inc bl
	cmp bl,24
	jne shc1
	mov bl,00h
shc1: mov hour,bl
        mov old,01
	
	jmp shc2

shdec:  cmp al,01h
		jne shc2
		mov bl,hour
		cmp bl,00
		jne shc3
		mov bl,24

shc3:   dec bl
		mov hour,bl
		mov old,01
		jmp shc2
		
shold: mov old,00
shc2: call disp_hr
	  jmp sh1
shend:
	mov checker,00
	ret
set_hour endp

;SET MINUTE STARTS

set_minute proc near
		mov checker,01
smin1: 	in al, port1c
	 cmp al, 02h			
	 jnz sminend	
	 call delay_20ms
	 in al, port1c
	 cmp al, 02h			
	 jnz sminend

	
	;checking if Increment is being given
	in al,port1b
	cmp al,00h
	je sminold
	mov bl,al
	call delay_20ms
	in al,port1b
	cmp bl,al
	jne smin2
	
	mov bh,old
    cmp bh,0
    jne smc2
	
	and al,00000011b
	cmp al, 02h
	jne smindec
    mov bl,min
	inc bl
	cmp bl,60
	jne smin3
	mov bl,00
smin3: mov min,bl
        mov old,1
        jmp smin2

smindec:  cmp al,01
		jne smin2
		mov bl,min
		cmp bl,00
		jne smindec2
		mov bl,60
smindec2: dec bl
		mov min,bl 
		mov old,1
		jmp smin2
	
sminold: mov old,00

smin2: call disp_min
		jmp smin1
sminend: 
		mov checker, 00
		ret
set_minute endp

;SET SECOND STARTS HERE

;Writing the code for setting the second
set_second proc near	
	mov checker,01

ssec1:		in al, port1c
	 cmp al, 04h			
	 jnz ssend	
	 call delay_20ms
	 in al, port1c
	 cmp al, 04h			
	 jnz ssend

	in al,port1b
	cmp al,00h
	je ssecold
	mov bl,al
	call delay_20ms
	in al,port1b
	cmp bl,al
	jne ssec2
	
	mov bh,old
    cmp bh,0
    jne smc2
	
	and al,00000011b
	cmp al, 02h
	jne ssdec

	mov bl,second
	inc bl
	cmp bl,60
	jne ssec3
	mov bl,00
ssec3:mov second,bl
        mov old,1
        jmp ssec2

ssdec:  cmp al,01
		jne ssec2
		mov bl,second
		cmp bl,00
		jne ssdec2
		mov bl,60
ssdec2: dec bl
		mov second,bl
		mov old,1 
		jmp ssec2
		
ssecold: mov old,0

ssec2: call disp_sec
		jmp ssec1
	
ssend: mov checker,00
		ret
set_second endp

set_date proc near
		
set_date endp
;SET MONTH STARTS 
set_month proc near
		mov checker,01
		;checking if 08 is given to port1c

sm1: 	in al, port1c
	 cmp al, 10h			
	 jnz smend	
	 call delay_20ms
	 in al, port1c
	 cmp al, 10h			
	 jnz smend
	;Taking inc/dec input
	in al,port1b
	cmp al,00h
	je smold
	mov bl,al
	call delay_20ms
	in al,port1b
	cmp bl,al
	jne smc2 
	
	mov bh,old
    cmp bh,0
    jne smc2
	
	and al,00000011b
	cmp al, 02h
	jne smdec
	mov bl,month
	inc bl
	cmp bl,13
	jne smc1
	mov bl,1
smc1: mov month,bl
        mov old,01
	
	jmp shc2

smdec:  cmp al,01h
		jne smc2
		mov bl,month
		cmp bl,1
		jne smc3
		mov bl,13

smc3:   dec bl
		mov month,bl
		mov old,01
		jmp smc2
smold:  mov old,00			

smc2: call disp_month
	jmp sm1

smend: 	mov checker,00
		ret
set_month endp

;SET MONTH ENDS HERE 

set_year proc near
    ret
set_year endp

set_alarm_hour proc near
    ret
set_alarm_hour endp

set_alarm_min proc near
    ret
set_alarm_min endp    

disp_hr proc near
	;format check
	in al,port2b
	and al,01h
	mov format_check,al
	
;clear display  command - 01h
;		  mov       al,01h
;		  out       port2c,al    
          ;setting the cursor
          
          mov al,01h  
		  out       port2c,al
		  call      delay_20ms
		  mov       al,80h
		  out       port2b,al 
		 
;		  mov       al,01h
;		  out       port2b,al 
		  mov       al,00h ;e transition to enable module
		  out       port2c,al
		  call      delay_20ms 
		  
		  
		  
		MOV Al,hour
		cmp al,9
		jle disp_hr1
		cmp al,19
		jle disp_hr2
		SUB al,20
		MOV hour_l,al
		MOV hour_h,2
		jmp disp_hrd
		  
disp_hr1:MOV hour_l,al
         MOV hour_h,0  
         jmp disp_hrd
        
disp_hr2:SUB al,10
         MOV hour_l,al
         MOV hour_h,1
                 
        
             		  
disp_hrd: ;displaying higher digit
        call idatdis
		mov AL,hour_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,hour_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms
		
		
		call idatdis
		mov al,3ah		;Ascii value of ':' is 3a
		out port2b,al		; displaying ':'
		mov al,10h
		out port2c,al
		call delay_20ms
		
		ret
disp_hr endp 
   
   
;CODE TO DISPLAY
disp_min proc near  
 ;   		  mov       al,01h
;		  out       port2c,al 
		  mov al,01h  
		  out       port2c,al
		  call      delay_20ms
		  mov       al,83h
		  out       port2b,al 
		  mov       al,00h ;e transition to enable module
		  out       port2c,al
		  call      delay_20ms
		  
;Running digit comparisons 
		MOV Al,min
		cmp al,9
		jle disp_min0
		cmp al,19
		jle disp_min1
		cmp al,29
		jle disp_min2
		cmp al,39
		jle disp_min3
		cmp al,49
		jle disp_min4
		sub al,50
		MOV min_l,al
		MOV min_h,5
		jmp disp_mind
		
disp_min0:	mov min_l,al
			mov min_h,0
			jmp disp_mind
disp_min1:	sub al,10
			mov min_l,al
			mov min_h,1
			jmp disp_mind
disp_min2:	sub al,20
			mov min_l,al
			mov min_h,2
			jmp disp_mind
disp_min3:	sub al,30
			mov min_l,al
			mov min_h,3
			jmp disp_mind
disp_min4:	sub al,40
			mov min_l,al
			mov min_h,4
			jmp disp_mind
disp_mind:	
		call idatdis
		mov AL,min_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,min_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms
		
		
		call idatdis
		mov al,3ah		;Ascii value of ':' is 3a
		out port2b,al		; displaying ':'
		mov al,10h
		out port2c,al
		call delay_20ms
		ret 
disp_min endp 

;CODE FOR DISPLAYING SECOND
disp_sec proc near
	
 ;   		  mov       al,01h
;		  out       port2c,al 
		  mov al,01h  
		  out       port2c,al
		  call      delay_20ms
		  mov       al,086h
		  out       port2b,al 
		  mov       al,00h ;e transition to enable module
		  out       port2c,al
		  call      delay_20ms
		  
;Running digit comparisons 
		MOV Al,second
		cmp al,9
		jle disp_sec0
		cmp al,19
		jle disp_sec1
		cmp al,29
		jle disp_sec2
		cmp al,39
		jle disp_sec3
		cmp al,49
		jle disp_sec4
		sub al,50
		MOV sec_l,al
		MOV sec_h,5
		jmp disp_secd
		
disp_sec0:	mov sec_l,al
			mov sec_h,0
			jmp disp_secd
disp_sec1:	sub al,10
			mov sec_l,al
			mov sec_h,1
			jmp disp_secd
disp_sec2:	sub al,20
			mov sec_l,al
			mov sec_h,2
			jmp disp_secd
disp_sec3:	sub al,30
			mov sec_l,al
			mov sec_h,3
			jmp disp_secd
disp_sec4:	sub al,40
			mov sec_l,al
			mov sec_h,4
			jmp disp_secd
disp_secd:	
		call idatdis
		mov AL,sec_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,sec_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms
		
		
	
		ret 
disp_sec endp

disp_day proc near 
    	mov al,01h  
		out       port2c,al
		call      delay_20ms
		mov       al,0C4h
		out       port2b,al 
		mov       al,00h ;e transition to enable module
		out       port2c,al
		call      delay_20ms 
		
		mov AL,day
		cmp al,9
		jle disp_day0
		cmp al,19
		jle disp_day1
		cmp al,29
		jle disp_day2
		sub al,30
		mov day_l,al
		mov day_h,3
		jmp disp_dayd

disp_day0:	mov day_l,al
			mov day_h,0
			jmp disp_dayd 
			
disp_day1: sub al,10
            mov day_l,al
			mov day_h,1
			jmp disp_dayd 
disp_day2: sub al,20
            mov day_l,al
			mov day_h,2
			jmp disp_dayd
disp_dayd:	
		call idatdis
		mov AL,day_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,day_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms 
		
		call idatdis
		mov al,2fh
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms
		
		ret 
disp_day endp 

disp_month proc near  
    mov al,01h  
		  out       port2c,al
		  call      delay_20ms
		  mov       al,0C7h
		  out       port2b,al 
		 
;		  mov       al,01h
;		  out       port2b,al 
		  mov       al,00h ;e transition to enable module
		  out       port2c,al
		  call      delay_20ms 
		  
		  
		  
		MOV Al,month
		cmp al,9
		jle disp_month1
		cmp al,19
		jle disp_month2
		
		  
disp_month1:MOV month_l,al
         MOV month_h,0  
         jmp disp_monthd
        
disp_month2:SUB al,10
         MOV month_l,al
         MOV month_h,1
                 
        
             		  
disp_monthd: ;displaying higher digit
        call idatdis
		mov AL,month_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,month_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms
		
		call idatdis
		mov al,2fh
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms
	
		
		ret
disp_month endp  

disp_year proc near
    ;Diplsaying first two digits of year
    mov al,01h  
		  out       port2c,al
		  call      delay_20ms
		  mov       al,0CAh
		  out       port2b,al 
		  mov       al,00h ;e transition to enable module
		  out       port2c,al
		  call      delay_20ms   
		  
		  
		  MOV Al,year_upper
		cmp al,9
		jle disp_yearu0
		cmp al,19
		jle disp_yearu1
		cmp al,29
		jle disp_yearu2
		cmp al,39
		jle disp_yearu3
		cmp al,49
		jle disp_yearu4
		cmp al,59
		jle disp_yearu5
		cmp al,69
		jle disp_yearu6
		cmp al,79
		jle disp_yearu7
		cmp al,89
		jle disp_yearu8
		cmp al,99
		jle disp_yearu9
		
		
		
disp_yearu0:mov yearu_l,al
			mov yearu_h,0
			jmp disp_yearud
disp_yearu1:	sub al,10
			mov yearu_l,al
			mov yearu_h,1
			jmp disp_yearud
disp_yearu2:	sub al,20
			mov yearu_l,al
			mov yearu_h,2
			jmp disp_yearud
disp_yearu3:	sub al,30
			mov yearu_l,al
			mov yearu_h,3
			jmp disp_yearud
disp_yearu4:	sub al,40
			mov yearu_l,al
			mov yearu_h,4
			jmp disp_yearud 
disp_yearu5:sub al,50
		    MOV yearu_l,al
		    MOV yearu_h,5
		    jmp disp_yearud
disp_yearu6:	sub al,60
			mov yearu_l,al
			mov yearu_h,6
			jmp disp_yearud
disp_yearu7:	sub al,70
			mov yearu_l,al
			mov yearu_h,7
			jmp disp_yearud
disp_yearu8:	sub al,80
			mov yearu_l,al
			mov yearu_h,8
			jmp disp_yearud
disp_yearu9:	sub al,90
			mov yearu_l,al
			mov yearu_h,9
			jmp disp_yearud

disp_yearud:	
		call idatdis
		mov AL,yearu_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,yearu_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms 
		
	    MOV Al,year_lower
		cmp al,9
		jle disp_yearl0
		cmp al,19
		jle disp_yearl1
		cmp al,29
		jle disp_yearl2
		cmp al,39
		jle disp_yearl3
		cmp al,49
		jle disp_yearl4
		cmp al,59
		jle disp_yearl5
		cmp al,69
		jle disp_yearl6
		cmp al,79
		jle disp_yearl7
		cmp al,89
		jle disp_yearl8
		cmp al,99
		jle disp_yearl9
		
		
		
disp_yearl0:mov yearl_l,al
			mov yearl_h,0
			jmp disp_yearld
disp_yearl1:	sub al,10
			mov yearl_l,al
			mov yearl_h,1
			jmp disp_yearld
disp_yearl2:	sub al,20
			mov yearl_l,al
			mov yearl_h,2
			jmp disp_yearld
disp_yearl3:	sub al,30
			mov yearl_l,al
			mov yearl_h,3
			jmp disp_yearld
disp_yearl4:	sub al,40
			mov yearl_l,al
			mov yearl_h,4
			jmp disp_yearld 
disp_yearl5:sub al,50
		    MOV yearl_l,al
		    MOV yearl_h,5
		    jmp disp_yearld
disp_yearl6:	sub al,60
			mov yearl_l,al
			mov yearl_h,6
			jmp disp_yearld
disp_yearl7:	sub al,70
			mov yearl_l,al
			mov yearl_h,7
			jmp disp_yearld
disp_yearl8:	sub al,80
			mov yearl_l,al
			mov yearl_h,8
			jmp disp_yearld
disp_yearl9:	sub al,90
			mov yearl_l,al
			mov yearl_h,9
			jmp disp_yearld

disp_yearld:	
		call idatdis
		mov AL,yearl_h 
		MOV digit,al  
		mov al,digit
					
		and al,0fh
		add al,30h				
		out port2b,al
		mov al,10h
		out port2c,al
		call delay_20ms 
			
		
		call idatdis
		mov AL,yearl_l 
		MOV digit,al  
		
		mov al,digit			
		and al,0fh
		add al,30h				
		out port2b,al
					
		mov al,10h           
		out port2c,al
		call delay_20ms
		          
		ret
disp_year endp
    
    
    
     
    
 


idatdis proc near  ;initialize for data display
    mov       al,11h
    out       port2c,al
    call      delay_20ms
    ret
idatdis endp  




 





