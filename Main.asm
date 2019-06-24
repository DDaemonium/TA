

        .global kd
        .global _capint

        .sect  "main"

        .include  main.h 


_c_int0:
main:

		;b		vraschatel
		SETC	INTM ;Disable interrupts
		CLRC	SXM  ;Clear Sign Extension Mode
		CLRC	OVM  ;Reset Overflow Mode
		CLRC	CNF  ;Config Block B0 to Data mem.
        

        ldp		#wd_page
		splk	#01101111b, wdcr
		
		;configure PLL for 4MHz xtal, 10MHz SYSCLK and 20MHz CPUCLK
		ldp		#00E0h
		SPLK	#00E4h, CKCR1 ; CLKIN(XTAL)=4MHz,CPUCLK=20MHz
		;SPLK	#0043h, CKCR0 ; CLKMD=PLL disable,SYSCLK=CPUCLK/2,
		SPLK	#00C3h, CKCR0 ; CLKMD=PLL Enable,SYSCLK=CPUCLK/2,
        SPLK 	#40C0h, SYSCR ; No reset, CLKOUT=CPUCLK
        
		;Spi_init 

	    ldp   #spi_page
        ;splk  #10000111b , spiccr  ;7040
        ;splk  #00000110b , spictl  ;7041
        ;splk  #19 , spibrr	
        ;splk  #01000000b , spipri  ;704F  
        ;splk  #01010010b , spipc1 ;704D spi
        splk  #01010000b , spipc1  ;spiste-digital out,1(ЦАП-не исп.)spiste.6
        						   ;spiclk-digital in  (КВОСМ)spiclk.3   
        ;splk  #00100000b , spipc2 ;704E 
        ;splk  #00000000b , spipc2  ;spisimo-digital in (Готовн.ПН)spipc2.7
        						   ;spisomi-digital in (КВОРМ)spipc2.3
        ;splk  #00000111b , spiccr	;
	    ;переключение каналов ЦАП - F/0 в старшей тетраде
	    ;записываемого в spitxbuf слова, *FFFh- +5B, *000- -5B

        
        ldp		#work_page
        splk	#0100101000000111b , t
        bldd	t , #COMCON
        splk	#1100101000000111b , t
        bldd	t , #COMCON
		splk	#1111111111b, t
        bldd	t, #ACTR
		
		;splk	#0100h,  t
		;bldd	t,	#pbdatdir
		
		splk	#1000b, t
        bldd	t , #ocrb    ; ocrb , вот
metka:  SETC	XF
        splk    #0000100000001000b, t 
        bldd	t, #pcdatdir
;        lacc	#30000, 7         ; задержка на плавный заряд конденсатора = 1 с
;metka_plavn_zar:
;        sub		#1
;        bcnd	metka_plavn_zar, NEQ
        
        CLRC	XF
        ;splk	#0101h,  t
		;bldd	t,	#pbdatdir
		ldp   #spi_page
		;splk  #01010000b , spipc1
		splk  #00010000b , spipc1
        ;b       metka
		
L122:        
        SETC	INTM ;Disable interrupts
		CLRC	SXM  ;Clear Sign Extension Mode
		CLRC	OVM  ;Reset Overflow Mode
		CLRC	CNF  ;Config Block B0 to Data mem.
        

        ldp		#wd_page
		splk	#01101111b, wdcr
		splk	#0055h, wdkey
		splk	#00AAh, wdkey
;configure PLL for 4MHz xtal, 10MHz SYSCLK and 20MHz CPUCLK
;		ldp		#00E0h
;		SPLK	#00E4h, CKCR1 ; CLKIN(XTAL)=4MHz,CPUCLK=20MHz
;		;SPLK	#0043h, CKCR0 ; CLKMD=PLL disable,SYSCLK=CPUCLK/2,
;		SPLK	#00C3h, CKCR0 ; CLKMD=PLL Enable,SYSCLK=CPUCLK/2,
;        SPLK 	#40C0h, SYSCR ; No reset, CLKOUT=CPUCLK
        
        setc  SXM
        
        LAR   AR1 , #0380h ; инициализация указателя на стек
        MAR   *,AR1
                
                
        ldp   #0           ; обнуление счетчиков NMI и BadTrap
        splk  #0 , nmic
        splk  #0 , btc
        
        ;ldp   #0
        ;splk  #0h , 04h
        ;splk	#27h, 06h

        ldp		#pwm1_page
        splk	#65 , versia         ;задание номера версии
       
        ldp    #work_page
        splk	#0 , F1	; очистка флага перехода на программу 1Л122
        splk	#0 , F2	; очистка флага перехода на программу врашателя 
        spm  0

        splk  #05555h , aa
        splk  #0aaaah , bb
        setc   sxm
        
        splk #07c0h , t
        out  t , 0ffffh

        splk #2100 , t
        out  t , 0h

        splk #2110 , t
        out  t , 01h

        splk #2110 , t
        out  t , 02h

        splk #2110 , t
        out  t , 03h

        splk #2110 , t
        out  t , 04h

        
            
        ;SCI
        splk	#17h , t
        bldd	t , #ccr
        splk	#13h , t
        bldd	t , #ctl1
        splk	#0h , t
        bldd	t , #ctl2
        splk	#0h , t
        bldd	t , #baud_hi
        splk	#0Ah , t
        bldd	t , #baud_lo
        splk	#22h , t
        bldd	t , #SCIPC2
        splk	#10h , t
        bldd	t , #pri      ; (PWM,TxD и пр.)
        splk	#33h , t
        bldd	t , #ctl1
        ;End of SCI
        
        splk  #0011111000001100b, t
        bldd  t , #ocra
        
        ;bldd  #ocrb ,t     ; это
        ;lacc  t             ; растакая
        ;or		#1000b     ; инициализация
        ;sacl  t             ; такого-то
        splk	#1000b, t
        bldd	t , #ocrb    ; ocrb , вот
         
        ; отладочная временная диаграма
        ldp   #0e1h
        
        splk	#1100000000b, padatdir
        
        lacc  pbdatdir
        or    #0ff00h 
        sacl  pbdatdir
        
        splk	#1111101100001000b, pcdatdir
        clrc	XF
        
        ;splk	#1111111100000000b, pddatdir 
         
        ;  Инициализация Spi интерфейса
        ldp   #spi_page
       
        splk  #01000111b , spiccr
        splk  #00000110b , spictl
        ;splk  #9 , spibrr
        splk  #4 , spibrr
        splk  #11000111b , spiccr
  
        ; конец Com и SPI инициализации


        ldp   #pwm1_page  ;инициализация переменных
        
        ;splk  #28508 , K0 ; K0 = 0.87
        splk	#6400, K0
        splk    #32748, K1
		;splk	#800, K2	;	K2 = 0.024
        ;splk	#3277, K3	;	K3 = 0.1
        splk	#32692, K3
        splk	#256, K4   ;	K4 = 0.008


        splk	#0, nS
        splk	#0,	eta
        splk	#0, contr_pit
        splk	#1, contr_scht
        splk	#11b, contr_rej
        ;splk	#222, scr1
        ;splk	#444, scr1
        splk	#1333, scr1
		splk	#0, scr2
        splk	#0, intscr
        splk	#0, Wz1
        splk	#0, Wz2
        splk	#0, Wz3
        splk	#0, frazgon
        splk	#0, frazgon2
		splk	#0, schet
        splk	#0, schet2
		splk	#0, schet3
        splk	#0, eds1
        splk	#0, eds2
        splk	#0, sraz
        splk	#0, sraz1
        splk	#50, sraz2
        splk	#50, sraz3
        splk	#0, frej
        splk	#0, Flag
        splk	#1000, Flag2
        splk	#30000, Flag3
        splk	#0001b, contr_rej2
        splk	#0001b, contr_temp
        
        splk	#410h, traz_post
        splk	#300, traz_vr
		splk	#0, traz_vr2        
                
        splk	#0, 200h
        splk	#0, 201h
        splk	#0, 202h
        splk	#0, 203h
        splk	#0, 204h
        splk	#0, 205h
        splk	#0, 206h
		splk	#0, 207h        
        
        splk	#0, Wz2
        ;splk	#40, sht1
        splk	#16, sht1
        splk	#111111111111b, sht2
        splk	#0, sht3
        splk	#272, maus
        splk	#0, a00
        splk	#0, a01
        splk	#0, a10
        splk	#0, a11
        splk	#0, gamma2
        splk	#10, st10
        splk	#40, nS2
        splk	#34, schet4
		splk	#0, Flag4
		splk	#0, ttt
		bldd	ttt, #cmpr1
		bldd	ttt, #cmpr2
		bldd	ttt, #cmpr3
		splk	#0, per
		splk	#0, per2
		splk	#0, per3
		splk	#6, nS3
		splk	#0, Flag5
		splk	#5, schet5
		splk	#0, Flag_1
		splk	#0, Flag_2
		splk	#0, Flag_eds
		splk	#0, schet_eds

		ldp   #pwm1_page2
		splk  #0 , val1 
        splk  #0 , val2 
        splk  #0 , val3 
        splk  #0 , val4 

        splk  #0 , cmd1 
        splk  #0 , cmd2 
        splk  #0 , cmd3 
        splk  #0 , cmd4 
        
        ldp   #work_page
        
        splk	#0, kiv_scan
        splk  #0 , tval 
        splk  #0 , tchan 
        splk  #0 , tcmd 
        splk  #0 , data 
        splk  #0 , tsan 
        splk  #1 , fle  ;флаг конца обнуления токов
        splk  #0 , evic
        splk  #0 ,fbf 
        splk  #0 , scp
        splk  #30 ,tsp 
        splk  #0 , osp 
        splk  #0h , spk


        
        ; конец инициализации переменных
        
       
       ; TIMERS
       

       splk  #0h , t
       bldd  t , #evimra
       splk  #0h , t
       bldd  t , #evimrb
       splk  #0h , t
       bldd  t , #evimrc
       splk  #1101010b , t
       bldd  t , #gptcon

       
        ; T2 init
       
        splk  #1101000000000010b , t
        bldd  t , #t1con
              
        splk  #1101000010000010b, t
        bldd  t, #t2con
 
        splk  #0h , t
        bldd  t , #t1cnt
        
        splk  #0h, t
        bldd  t, #t2cnt

        splk	#2,	t
        bldd	t,	#evifrb
        splk	#200h,	t
        bldd	t,	#evifra
        
        ldp   #0
        splk  #0h , 04h
        splk	#27h, 06h
        ldp   #work_page
        ;splk  #2000, t			; 10 кГц
        splk	#1000, t		; 20 кГц
        bldd  t, #t2pr
        
        splk	#900, t
        bldd	t, #T2CMPR
        
        splk  #1101000011000010b, t
        bldd  t, #t2con
        
        ; T1 init
       
       
        ;splk  #1101000000001000b , t
        ;splk  #1101000000000010b , t
        ;bldd  t , #t1con
        
        ;splk  #0h , t
        ;bldd  t , #t1cnt
        
        ;splk  #2000 , t			; 10 кГц 
        splk	#1000, t			; 20 кГц
        bldd  t , #t1pr
        
        ;splk  #1101000001001000b , t
        splk  #1101000001000010b , t
        bldd  t , #t1con
       
  
       
       ; ШИМЫ 
        

        splk  #0100101000000111b , t
        bldd  t , #COMCON
        splk  #1100101000000111b , t
        bldd  t , #COMCON
        
        splk	#0000111111111111b , t	
        bldd	t,	#ACTR            
         
        ;SPLK  #0000100011101100b, t
        ;splk	#0000101011101000b, t
        splk	#0,	t
        bldd   t , #DBTCON
        
        ;b		andr	;!!!
        
         ; здесь вся инициализация АЦП
          
        ldp     #adc_page
    	splk	#010b , adctrl2
        splk    #0101100101111111b , adctrl1 
lm:		lacl    adctrl1
		and		#0000000010000000b
		bcnd	lm, NEQ  
       
       lacc		adcfifo1  ;фиктивное сбросовое чтение АЦП
       lacc		adcfifo1
       lacc		adcfifo2
       lacc		adcfifo2
       splk		#0100000100000000b, adctrl1      
       splk		#010b , adctrl2
           
        
        ldp   #work_page
        
        splk  #0 , adcf
                
        ldp  #adc_page
        splk  #010b , adctrl2  ;init ADCTRL2
        splk  #0101101101111111b , adctrl1       

        ldp  #0
        splk #020h , 04h
               
        ldp  #work_page
        clrc   INTM

adcinitsicle:        

        call kd
        lacc adcf
        bcnd adcinitsicle , EQ

        setc   INTM
        
		ldp  #adc_page
        
		lacc adcfifo1
		lacc adcfifo1
		lacc adcfifo1
		lacc adcfifo1
        
       
        lacc adcfifo2
        lacc adcfifo2
        lacc adcfifo2
        lacc adcfifo2
        ; конец инициализации АЦП
        
andr:  
       ;разрешение прерываний от таймера
       ldp   #work_page
       splk  #1101000001001000b , t
       bldd  t , #t1con
       splk  #0200h , t 
       bldd  t , #evimra  ;разрешение прерываний tufint
       splk  #0002h , t 
       bldd  t , #evimrb
              
        ldp		#sys_page
	    splk	#0, xint1cr
        
        ldp   #0
        splk  #027h , 04h
        ;splk	#026h, 04h ;!!! нет прерывания по xint1
        
        clrc   INTM
        b		beg
        
vraschatel:    ;начало иницилизации для программы вращателя

        setc  INTM
        setc  SXM
        ;CLRC	SXM  ;Clear Sign Extension Mode
		;CLRC	OVM  ;Reset Overflow Mode
		;CLRC	CNF  ;Config Block B0 to Data mem.
 
         
        
        ;ldp		#wd_page
		;splk	#01101111b, wdcr
		;splk	#0055h, wdkey
		;splk	#00AAh, wdkey
		
;configure PLL for 4MHz xtal, 10MHz SYSCLK and 20MHz CPUCLK
;		ldp		#00E0h
;		SPLK	#00E4h, CKCR1 ; CLKIN(XTAL)=4MHz,CPUCLK=20MHz
;		;SPLK	#0043h, CKCR0 ; CLKMD=PLL disable,SYSCLK=CPUCLK/2,
;		SPLK	#00C3h, CKCR0 ; CLKMD=PLL Enable,SYSCLK=CPUCLK/2,
;        SPLK 	#40C0h, SYSCR ; No reset, CLKOUT=CPUCLK
        
        LAR   AR6, 	#2		;для вычислений в циклах
                            
        LAR   AR1 , #0380h ; инициализация указателя на стек
        MAR   *,AR1
                
        lar   AR0 , #2	;для М-Р =16 ячеек угла
        				;при изменении нужно также
        				;изменить в AR6 
        			
;        MAR   *,AR3      
;        lar   AR3 , #360h		;для вычисл. скорости
;        lar   AR4 , #360h       
;        MAR   *BR0+ , AR1 
;        MAR   *,AR1
               
        ldp   #0           ; обнуление счетчиков NMI и BadTrap
        splk  #0 , nmic
        splk  #0 , btc
        splk  #0h , 04h	;очистка IMR
    
		ldp		#pwm1_page
        splk	#62 , versia         ;задание номера версии
        
		ldp	#wd_page	
		bit	wdcr,8
		bcnd	neon,NTC
    	ldp   #pwm1_page
neon:	ldp	#wd_page
		lacl	wdcr
		or	#0A8h	;101	WDCHK
		sacl	wdcr	;сброс флага WDx!!        
    
        
        
        ldp    #work_page ;для t
        splk	#0 , F1	; очистка флага перехода на программу 1Л122
        splk	#0 , F2	; очистка флага перехода на программу врашателя
        spm  0
        
        splk  #05555h , aa
        splk  #0aaaah , bb
        setc   sxm
               
         ;splk #01f8h , t    ;07F8h 01ffh
         splk	#0006h, t
         out  t , 0ffffh	;WSGR, на внешнюю шину данных макс. задержка

         ;SCI
         splk	#17h , t
         bldd	t , #ccr
         splk	#13h , t
         bldd	t , #ctl1
         splk	#0h , t
         bldd	t , #ctl2
         splk	#0h , t
         bldd	t , #baud_hi
         splk	#0Ah , t
         bldd	t , #baud_lo
         splk	#22h , t
         bldd	t , #SCIPC2
         splk	#10h , t
         bldd	t , #pri      ; (PWM,TxD и пр.)
         splk	#33h , t
         bldd	t , #ctl1
        
;******************************************************************        
         ;IOPA0-IOPA3,PWM7-стабил.тока торм. ,IOPB1-IOPB7
         splk  #0100h, t
         bldd  t , #ocra
         
         ;IOPC0-IOPC7
         splk	#1000b, t
         bldd	t , #ocrb    ; ocrb 
;-----------------------------------------------------------------         
         ;IOPC1
         bldd	#SYSCR, t
         lacc	t
         and	#0ff3fh
         sacl	t
         bldd	t, #SYSCR                
;-------------------------------------------------------------------- 
         ldp   #0e1h
                  
         splk	#0, padatdir
;--------------------------------------------------------------------         
         splk	#0D100h, pbdatdir 
;--------------------------------------------------------------------         
         ;splk	#0, pcdatdir
         splk	#1111101100001000b, pcdatdir
         clrc	XF

;инициализация переменных
       
        ldp   #pwm1_page
        
        splk  #0 , Upit
 	    
        ;splk	#0, fi
		splk	#1000, fi      ;для счётчика задержки торможения  (1 c)
        
        splk  #0 , magnitude        
        splk  #1001  , k_u          
  
        
        splk  #049e7h , inv_sqrt_3  
    
        splk	#0, Flag_rabota
        splk	#0, Flag_magnitud_2
        splk	#0, Flag_1
		splk	#0, Flag_2


        splk	#12345, per_1
        splk	#12345, per_2
        splk	#89, K3
        splk	#0ffffh, max

        
        ldp   #pwm1_page2
        splk  #293 , val0
        splk  #22 , val1      
        splk  #2 , val2      
        splk  #1023 , val3      
        splk  #500 , val4      
        splk  #0 , val5      
        splk  #0 , cmd0      
        splk  #0 , cmd2      
        splk  #0 , cmd3      
        splk  #0 , cmd4                                
        
        ldp   #work_page     
;инициализация переменных обмена        
        
        splk  #0, kiv_scan
        splk  #0 , tval 
        splk  #0 , tchan 
        splk  #0 , tcmd 
        splk  #0 , data 
        splk  #0 , tsan 
        splk  #1 , fle  ;флаг конца обнуления токов
        splk  #0 , evic
        splk  #0 ,fbf 
        splk  #0 , scp
        splk  #30 ,tsp 
        splk  #0 , osp 
        splk  #0h , spk 
        

        splk  #04ah , t
        bldd  t , #gptcon
        splk  #04ah , t
        bldd  t , #gptcon        

        splk  #0h , t
        bldd  t , #evimra
        splk  #0h , t
        bldd  t , #evimrb
        splk  #0h , t
        bldd  t , #capfifo
        splk  #80fch , t
        bldd  t , #capcon  ;рабочий таймер 2, САР3 запрещен, САР1,2 по всем 
                           ;перепадам        
        ; конец инициализации переменных
              
        ; T2 init       
             
        splk  #1101000000000010b, t
        bldd  t, #t2con

        splk  #0h, t
        bldd  t, #t2cnt
        
        splk	#64000, t
        bldd	t, #t2pr

        splk  #1101000001000010b, t
        bldd  t, #t2con
analiz:                  ;анализ флага evifrb
        ldp		#ev_page
        bit		evifrb,	15
        bcnd	analiz, NTC
        splk	#1, evifrb
        ldp		#pwm1_page
        lacc	fi
        sub		#1
        sacl	fi
        bcnd	analiz, NEQ

        ;инициализация ADC  
        ldp   #work_page
        splk  #0804h , t
        bldd  t , #adctrl2	            ;init ADCTRL2       
        splk  #0101100100000001b , t    ;получилось, что нужен запуск АЦП, 
        bldd  t , #adctrl1              ;инициализирующий регистры
        splk  #0804h , t                ;на всякий случай
        bldd  t , #adctrl2            
          
        splk  #207h, t            
        bldd  t , #COMCON
        bldd  t , #COMCON
        ;splk  #111111111111b , t
        splk  #0 , t
        bldd  t , #ACTR	   ;полное запирание моста
        
        SPLK  #0af0h, t  
        bldd   t , #DBTCON  

        ;здесь вся инициализация АЦП          
        ldp     #adc_page
l:		lacl    adctrl1    ;дождаться конца начального ADC
		and		#100h
		bcnd	l, EQ  
       
        lacc	adcfifo1   ;фиктивное сбросовое чтение АЦП
        lacc	adcfifo1
        lacc	adcfifo2
        lacc	adcfifo2 
        splk	#4100h,  adctrl1      
	
        ldp   #dio_page
        lacl  pcdatdir  
        or    #00080h	;Нач взвод триггера  ненорм. Iф (IOPC7=1)
        and	  #0fffeh	;Включение выходов 1554ИР22		(IOPC0=0)
        sacl  pcdatdir  
       
		;Задержка 			 
				lacc	#32767
zader_centr_dt1:
				sub   #1
             	bcnd  zader_centr_dt1 , NEQ
        		lacl  pcdatdir  
        		and	  #0ff7fh	;снятие сбросового уровня
       							;с R-входа триггера (IOPC7=0)
        		sacl  pcdatdir  
           
        setc	SXM

        ; T1 init
        ldp   #work_page       
        splk  #2802h, t               
        bldd  t , #t1con     

        splk  #1000  , t     
        bldd  t , #t1pr      

        splk  #500 , t        
        bldd  t , #t1cnt     

        splk  #2842h , t 
        bldd  t , #t1con
                       
;------------------------------------------------------------------------------
; Регистры управления таймерами и ШИМ
;------------------------------------------------------------------------------
		ldp	#ev_page
		splk	#0000000001100101b, gptcon
		splk	#0000000001100001b, gptcon
;                fedcba9876543210
; 6 -- разрешить режим сравнения для таймеров общего назначения
; 1 - 0 -- t1pin - полярность выхода сравнения GPT1
;	(00 - forced low)
;	(01 - active low)
;	(10 - active high)
;	(11 - forced high)

		splk	#0, t1cnt
		splk	#0, t2cnt
		splk	#0010100000000010b, t1con
		splk	#0001000000000010b, t2con
;                fedcba9876543210
; d - b -- режим счёта (101 - continuous up/down)
; a - 8 -- предварительный делитель частоты (000 - CPU/1)
; 7 -- запуск таймера от бита t1enable (для первого таймера -- зарезервировано)
; 6 - tenable - запуск таймера
; 5 - 4 -- источник тактирования (00 - внутреннее)
; 3 - 2 -- условие перезагрузки регистра сравнения
;          (00 - по 0 значению счётчика, underflow)
; 1 -- разрешить сравнение
; 0 -- выбор регистра периода (для первого таймера -- зарезервировано)

		splk	#1h, sactr
		splk	#1011011001100110b, actr
		;splk	#1011100110011001b, actr
;                fedcba9876543210
; f -- svrdir - направление формирования вектора (0 - CCW; 1 - CW)
; e - c -- базовые вектора
; b - a -- действие на выходе PWM6/CMP6 (в векторной ШИМ не работает, помоему)
; 9 - 8 -- действие на выходе PWM5/CMP5
; 7 - 6 -- действие на выходе PWM4/CMP4
; 5 - 4 -- действие на выходе PWM3/CMP3
; 3 - 2 -- действие на выходе PWM2/CMP2
; 1 - 0 -- действие на выходе PWM1/CMP1
;	Compare Mode		PWM Mode
;	00 Hold			Forced low
;	01 Reset		Active low
;	10 Set			Active high
;	11 Toggle		Forced high

		SPLK  #0af0h, DBTCON    
;------------------------------------------------------------------------------
; f - 8 -- период таймера мёртвого времени (00 - без мертвого времени)
; 7 -- запуск таймера мёртвого времени 3 (PWM5/PWM6)
; 6 -- запуск таймера мёртвого времени 2 (PWM3/PWM4)
; 5 -- запуск таймера мёртвого времени 1 (PWM1/PWM2)
; 4 - 3 -- предварительный делитель частоты для таймера
; мёртвого времени: (01 = CPU/2)
; 2 - 0 -- зарезервировано
;------------------------------------------------------------------------------

		splk	#1h, cmpr1
		splk	#2h, cmpr2
		splk	#1000, t1pr
		splk	#2000, t2pr 
		splk	#0,  scmpr1


		splk	#0000001000000000b, evimra
;                fedcba9876543210
; 9 - разрешить t1ufint

		ldp	#cmp_page
		splk	#0000001110000111b, COMCON
		splk	#1000001110000111b, COMCON
;                fedcba9876543210
; f -- разрешить сравнение
; e - d -- условие перезагрузки CMPRx (00 - по 0 значению таймера - по заёму)
; c -- установка режима векторной ШИМ
; b - a -- условие перезагрузки ACTR (00 - по 0 значению таймера - по заёму)
; 9 -- разблокировка выхода полного регистра сравнения
; 8 -- разблокировка выхода простого регистра сравнения
; 7 -- выбор базового таймера (0 - GPT1)
; 6 - 5 -- условие перезагрузки SCMPRx (00 - по 0 значению таймера - по заёму)
; 4 - 3 -- условие перезагрузки SACTR (00 - по 0 значению таймера - по заёму)
; 2 -- режим для PWM6/PWM5 (1 - ШИМ-режим)
; 1 -- режим для PWM4/PWM3
; 0 -- режим для PWM2/PWM1

		splk	#0010100001000010b, t1con
		splk	#0001000001000010b, t2con
; Завершение конфигурирования таймера и запуск ШИМ
; 6 -- запуск таймера
       
       ;разрешение прерываний tufint
        ldp   #0
        ;splk  #032h , 04h
;        splk  #002h , 04h
		splk  #022h , 04h    
      
        clrc   INTM  

beg:	;Вот это и есть самое начало функции MAIN ; ; ; ;
        ldp   #work_page
		lacc	F1
		bcnd	L122, NEQ
		lacc	F2
		bcnd	vraschatel, NEQ

        splk   #1000 , i
        splk   #8000 , ch
        splk   #0 , s
metc:
        call   kd
        bldd   #07055h, t
        lacc   t
        and    #040h
        sacl   t

        bcnd   read  , GT
        lacc   i
        sub    #1
        sacl   i
        bcnd   metc  , GEQ
        b      rend
read:
        bldd   #07057h, ch
        lacc   ch
        and    #00ffh
        sacl   ch
rend:
        lacc   ch
        sub    #8000
        bcnd   beg   , EQ
        bldd   #(work_page_offset+p1) , p
        bldd   #(work_page_offset+p2) , p1
        bldd   #(work_page_offset+ch) , p2
        bldd   #(work_page_offset+p ) , a
        bldd   #(work_page_offset+p1) , a1
        bldd   #(work_page_offset+p2) , a2
        
        
        splk   #1  , com
        splk   #1 , what
        call   fsum
        lacc   rez
        bcnd   stan , EQ

        
        lacc   p1 , 8
        or     p2
        sacl   data
        ;bldd   data , #(pwm1_offset+Ic)
        splk   #255 , p
        splk   #255 , p1
        splk   #255 , p2
        
        clrc   SXM
        
        lacc   data
        and    #3c00h
        sach   tchan , 6
        lacc   data , 2
        sach   tcmd 
        lacc   data
        and    #3ffh
        sacl   tval
        
        setc   SXM

        lacc   tchan    ;указания номеров каналов
        sub    #0
        bcnd   ch0 , EQ
        
        lacc   tchan
        sub    #1
        bcnd   ch1 , EQ
        
        lacc   tchan
        sub    #2
        bcnd   ch2 , EQ
        

        lacc   tchan
        sub    #3
        bcnd   ch3 , EQ
        
        
        lacc   tchan    
        sub    #4
        bcnd   ch4 , EQ
        
        lacc   tchan
        sub    #5
        bcnd   ch5 , EQ
        
        lacc   tchan
        sub    #6
        bcnd   ch6 , EQ
        

        lacc   tchan
        sub    #7
        bcnd   ch7 , EQ
        
        
        lacc   tchan    
        sub    #8
        bcnd   ch8 , EQ
        
        lacc   tchan
        sub    #9
        bcnd   ch9 , EQ
        
        lacc   tchan
        sub    #10
        bcnd   ch10 , EQ
        

        lacc   tchan
        sub    #11
        bcnd   ch11 , EQ

        
        b      beg
ch0:
        bldd  tcmd , #(pwm1_offset2+cmd0)
        bldd  tval , #(pwm1_offset2+val0)
        b      beg
ch1:
        bldd  tcmd , #(pwm1_offset2+cmd1)
        bldd  tval , #(pwm1_offset2+val1)
        b      beg
ch2:
        bldd  tcmd , #(pwm1_offset2+cmd2)
        bldd  tval , #(pwm1_offset2+val2)
        b      beg
ch3:
        bldd  tcmd , #(pwm1_offset2+cmd3)
        bldd  tval , #(pwm1_offset2+val3)
        b      beg
ch4:
        bldd  tcmd , #(pwm1_offset2+cmd4)
        bldd  tval , #(pwm1_offset2+val4)
        b      beg
ch5:
        bldd  tcmd , #(pwm1_offset2+cmd5)
        bldd  tval , #(pwm1_offset2+val5)
        b      beg
ch6:
        bldd  tcmd , #(pwm1_offset2+cmd6)
        bldd  tval , #(pwm1_offset2+val6)
        b      beg
ch7:
        bldd  tcmd , #(pwm1_offset2+cmd7)
        bldd  tval , #(pwm1_offset2+val7)
        b      beg
ch8:
        bldd  tcmd , #(pwm1_offset2+cmd8)
        bldd  tval , #(pwm1_offset2+val8)
        b      beg
ch9:
        bldd  tcmd , #(pwm1_offset2+cmd9)
        bldd  tval , #(pwm1_offset2+val9)
        b      beg
ch10:
        bldd  tcmd , #(pwm1_offset2+cmd10)
        bldd  tval , #(pwm1_offset2+val10)
        b      beg
ch11:
        bldd  tcmd , #(pwm1_offset2+cmd11)
        bldd  tval , #(pwm1_offset2+val11)
        b      beg 
                       
stan:        

        splk   #1  , com
        splk   #0 , what
        call   fsum
        lacc   rez
        bcnd   beg , EQ
        
        ;splk	#1, kiv_scan	        

        lacc   p1 , 8
        or     p2
        sacl   t
        splk   #255 , p
        splk   #255 , p1
        splk   #255 , p2
        ;sub    #599
        ;bcnd   eosc , NEQ
        ;ldp    #pwm1_page
        ;splk   #560 , Count
        ;splk   #1   , Flag
        ;ldp    #work_page
eosc:
        mar    * , AR5
        lar    AR5 , t
        bldd   * , #(work_page_offset+t) , AR1
        clrc   SXM
        lacc   t , 8
        sach   s1
        setc   SXM
        lacc   t
        and    #00ffh
        sacl   s2
        splk   #0  , com
        splk   #0 , what
        bldd   #(work_page_offset+s1) , a1
        bldd   #(work_page_offset+s2) , a2
        call   fsum
        bldd   #(work_page_offset+sum) , s

it1:
        call  kd
        bldd  #7054h , t
        lacc  t
        and   #040h
        bcnd  it1 , LEQ
		;splk	#0123h, s
        bldd  s , #7059h
it2:
        call  kd
        bldd  #7054h , t
        lacc  t
        and   #040h
        bcnd  it2 , LEQ
		;splk	#0123h, s1
        bldd  s1 , #7059h
it3:
        call  kd
        bldd  #7054h , t
        lacc  t
        and   #040h
        bcnd  it3 , LEQ
        ;splk	#0123h, s2
        bldd  s2 , #7059h

        b   beg
        ret
        
        
_nmi:        

         mar  * , AR1  
         sst  #1 , *+
         sst  #0 , *+
         sach *+
         sacl *+
         spm  0
         sph  *+ ;save PREG
         spl  *+ 
         mpy  #1
         spl  *+ ;save TREG

         setc SXM
         ldp  #0
         lacc nmic
         add  #1
         sacl nmic

         mar  * , AR1
         mar  *-
         mar  *-
         spm  0
         lt   *+
         mpy  #1  
         lt   *-
         mar  *-
         lph  *-
         lacl *-
         add  *-,16
         lst  #0,*-
         lst  #1,*
         clrc INTM
         ret

_bad_trap:
       
         mar  * , AR1  
         sst  #1 , *+
         sst  #0 , *+
         sach *+
         sacl *+
         spm  0
         sph  *+ ;save PREG
         spl  *+ 
         mpy  #1
         spl  *+ ;save TREG

         setc SXM
         ldp  #0
         lacc btc
         add  #1
         sacl btc

         mar  * , AR1
         mar  *-
         mar  *-
         spm  0
         lt   *+
         mpy  #1  
         lt   *-
         mar  *-
         lph  *-
         lacl *-
         add  *-,16
         lst  #0,*-
         lst  #1,*
         clrc INTM
         ret
        
fsum:
        setc   sxm
        lacc   com , 1
        or     what
        sacl   sum , 6
        splk   #0 , i
        lacc   a1 , 8
        or     a2
        sacl   t
m1:
        lt     i
        bitt   t
        bcnd   nul1 , NTC
        lacc   sum
        add    #1
        sacl   sum
nul1:
        lacc   i
        add    #1
        sacl   i
        sub    #16
        bcnd   m1 , LT
        splk   #1 , rez
        lacc   a
        sub    sum
        bcnd   m4 , EQ
        splk   #0 , rez
m4
        ret

kd:     bldd aa , #7025h
        bldd bb , #7025h
        
        ret
        
        
_capint:        

         mar  * , AR1  
         sst  #1 , *+
         sst  #0 , *+

         
         mar  * , AR2
         lar  AR2 , #07405h
      ;   bldd * , #(work_page_offset+ksis)
         ;lar  AR2 , #07405h
         splk  #0 , *
         lar  AR2 , #07431h
         splk  #4 , *
        ; lar  AR2 , #0329h
        ; splk  #1 , *
         
         
         
         mar  * , AR1  
         mar  *-
         lst  #0,*-
         lst  #1,*
         clrc INTM
         ret
        
     
     
     
     
     
     
     
        .end
       