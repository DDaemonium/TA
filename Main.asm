
        .global kd
        .global _capint

        .sect  "main"

        .include  main.h 


_c_int0:
main:
        SETC	INTM ;Disable interrupts
		CLRC	SXM  ;Clear Sign Extension Mode
		CLRC	OVM  ;Reset Overflow Mode
		CLRC	CNF  ;Config Block B0 to Data mem.
        

        ldp		#wd_page
		splk	#01101111b, wdcr
		splk	#0055h, wdkey
		splk	#00AAh, wdkey
;configure PLL for 4MHz xtal, 10MHz SYSCLK and 20MHz CPUCLK
		ldp		#00E0h
		SPLK	#00E4h, CKCR1 ; CLKIN(XTAL)=4MHz,CPUCLK=20MHz
		;SPLK	#0043h, CKCR0 ; CLKMD=PLL disable,SYSCLK=CPUCLK/2,
		SPLK	#00C3h, CKCR0 ; CLKMD=PLL Enable,SYSCLK=CPUCLK/2,
        SPLK 	#40C0h, SYSCR ; No reset, CLKOUT=CPUCLK
        
        setc  SXM
        
        LAR   AR1 , #0380h ; инициализаци€ указател€ на стек
        MAR   *,AR1
                
                
        ldp   #0           ; обнуление счетчиков NMI и BadTrap
        splk  #0 , nmic
        splk  #0 , btc
        
        ldp   #0
        splk  #0h , 04h
        
        ldp		#pwm1_page
        splk	#60 , versia         ;задание номера версии
       
        ldp    #work_page
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
        
        splk  #0011111100001100b, t
        bldd  t , #ocra
        
        ;bldd  #ocrb ,t     ; это
        ;lacc  t             ; растака€
        ;or		#1000b     ; инициализаци€
        ;sacl  t             ; такого-то
        splk	#1000b, t
        bldd	t , #ocrb    ; ocrb , вот
         
        ; отладочна€ временна€ диаграма
        ldp   #0e1h
        
        splk	#1100000000b, padatdir
        
        lacc  pbdatdir
        or    #0ff00h 
        sacl  pbdatdir
        
        splk	#1111101100001000b, pcdatdir
        clrc	XF
        
        ;splk	#1111111100000000b, pddatdir 
         
        ;  »нициализаци€ Spi интерфейса
        ldp   #spi_page
       
        splk  #01000111b , spiccr
        splk  #00000110b , spictl
        ;splk  #9 , spibrr
        splk  #4 , spibrr
        splk  #11000111b , spiccr
  
        ; конец Com и SPI инициализации


        ldp   #pwm1_page  ;инициализаци€ переменных
        
        ;splk  #28508 , K0 ; K0 = 0.87
        splk	#6400, K0
        splk    #32748, K1
		;splk	#800, K2	;	K2 = 0.024
        ;splk	#3277, K3	;	K3 = 0.1
        splk	#32692, K3
        splk	#256, K4   ;	K4 = 0.008


        splk	#0, nS
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
        
        splk  #0 , val1 
        splk  #0 , val2 
        splk  #0 , val3 
        splk  #0 , val4 

        splk  #0 , cmd1 
        splk  #0 , cmd2 
        splk  #0 , cmd3 
        splk  #0 , cmd4 

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
		

        
        ldp   #work_page
        
        splk	#0, kiv_scan
        splk  #0 , tval 
        splk  #0 , tchan 
        splk  #0 , tcmd 
        splk  #0 , data 
        splk  #0 , tsan 
        splk  #1 , fle  ;флаг конца обнулени€ токов
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
       
       
        splk  #1101000010000010b, t
        bldd  t, #t2con

        splk  #0h, t
        bldd  t, #t2cnt

        ;splk  #2000, t			; 10 к√ц
        splk	#1000, t		; 20 к√ц
        bldd  t, #t2pr
        
        splk	#900, t
        bldd	t, #T2CMPR
        
        splk  #1101000011000010b, t
        bldd  t, #t2con
        
        ; T1 init
       
       
        ;splk  #1101000000001000b , t
        splk  #1101000000000010b , t
        bldd  t , #t1con
        
        splk  #0h , t
        bldd  t , #t1cnt
        
        ;splk  #2000 , t			; 10 к√ц 
        splk	#1000, t			; 20 к√ц
        bldd  t , #t1pr
        
        ;splk  #1101000001001000b , t
        splk  #1101000001000010b , t
        bldd  t , #t1con
       
  
       
       ; Ў»ћџ 
        

        splk  #0100101000000111b , t
        bldd  t , #COMCON
        splk  #1100101000000111b , t
        bldd  t , #COMCON
        
        splk	#0000111111111111b , t	
        bldd	t,	#ACTR            
         
        ;SPLK  #0000100011101100b, t
        ;splk	#0000101011101000b, t
        ;bldd   t , #DBTCON
        
        ;b		andr	;!!!
        
         ; здесь вс€ инициализаци€ ј÷ѕ
          
        ldp     #adc_page
    	splk	#010b , adctrl2
        splk    #0101100101111111b , adctrl1 
l:		lacl    adctrl1
		and		#0000000010000000b
		bcnd	l, NEQ  
       
       lacc		adcfifo1  ;фиктивное сбросовое чтение ј÷ѕ
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
        ; конец инициализации ј÷ѕ
        
andr:  
       ;разрешение прерываний от таймера
       ldp   #work_page
       splk  #1101000001001000b , t
       bldd  t , #t1con
       splk  #0200h , t 
       bldd  t , #evimra  ;разрешение прерываний tufint
       splk  #0002h , t 
       bldd  t , #evimrb
              
        ;splk	#1000000000000101b , t	
        ;bldd	t,	#xint1cr
        
        ldp   #0
        splk  #027h , 04h
        ;splk	#026h, 04h
        
        clrc   INTM

beg:	;¬от это и есть самое начало функции MAIN ; ; ; ;
        ldp   #work_page
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

        lacc   tchan    ;указани€ номеров каналов
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
        bldd  tcmd , #(pwm1_offset+cmd0)
        bldd  tval , #(pwm1_offset+val0)
        b      beg
ch1:
        bldd  tcmd , #(pwm1_offset+cmd1)
        bldd  tval , #(pwm1_offset+val1)
        b      beg
ch2:
        bldd  tcmd , #(pwm1_offset+cmd2)
        bldd  tval , #(pwm1_offset+val2)
        b      beg
ch3:
        bldd  tcmd , #(pwm1_offset+cmd3)
        bldd  tval , #(pwm1_offset+val3)
        b      beg
ch4:
        bldd  tcmd , #(pwm1_offset+cmd4)
        bldd  tval , #(pwm1_offset+val4)
        b      beg
ch5:
        bldd  tcmd , #(pwm1_offset+cmd5)
        bldd  tval , #(pwm1_offset+val5)
        b      beg
ch6:
        bldd  tcmd , #(pwm1_offset+cmd6)
        bldd  tval , #(pwm1_offset+val6)
        b      beg
ch7:
        bldd  tcmd , #(pwm1_offset+cmd7)
        bldd  tval , #(pwm1_offset+val7)
        b      beg
ch8:
        bldd  tcmd , #(pwm1_offset+cmd8)
        bldd  tval , #(pwm1_offset+val8)
        b      beg
ch9:
        bldd  tcmd , #(pwm1_offset+cmd9)
        bldd  tval , #(pwm1_offset+val9)
        b      beg
ch10:
        bldd  tcmd , #(pwm1_offset+cmd10)
        bldd  tval , #(pwm1_offset+val10)
        b      beg
ch11:
        bldd  tcmd , #(pwm1_offset+cmd11)
        bldd  tval , #(pwm1_offset+val11)
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
       