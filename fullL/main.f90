!spin 对角化且两块相等时，轨道计半，然后乘2，能量同理
PROGRAM MAIN
USE PARS
IMPLICIT NONE
 INTEGER::NREAL,NFIX,L,ISPIND,ISSYM
 INTEGER::ERROR,ITNOW,ITMAX,FLAGMAX,IFLAG,NLIMIT
 REAL(DP)::RMIX,EGS,VFACTOR,RSURF,EPSI
 REAL(DP)::ALPHA
 NSHELL=3;LUSE=2;!NUSE=NLIMIT(L,NSHELL)
 !WRITE(*,*)NUSE;STOP
 NREAL=8                              !PARTICLE NUMBER
 ERROR=1.0D0;EPSI=1.0D-6;RMIX=1.0D0  !ITERATION OPTIONS
 ITNOW=0;ITMAX=10;FLAGMAX=5;IFLAG=0
 ISPIND=1;ISSYM=1                            !TREAT ONLY SPIN UPPER PART
! 
! IF(ISPINC.NE.1) STOP "NOT IMPLEMENTED YET"
! IF((ISPINC.EQ.1).AND.MOD(NREAL,2)==1) STOP 'NFIX NOW CAN ONLY BE EVEN'
 NFIX=NREAL!/(ISPIND+1)!WHEN IPSINC=1, ONE ONLY TREAT THE UPPER BLOCK OF H MATRIX 
!
 HBAR2M=20.73D0;HBROMG=10.0D0;BOSC=SQRT(0.5D0*HBROMG/HBAR2M)!CONSTANTS  
 V0R=2.0D2;KAPPAR=1.487D0
 V0S=-9.185D1;KAPPAS=0.465D0
!
 CALL INITIAL(NFIX)!INITIALIZE T,V,RHO,E! CALL V2TEST(L,RSURF,VFACTOR)
 CALL ITERS(NFIX,ISSYM,ISPIND,EPSI,ITMAX,ITNOW,IFLAG,FLAGMAX,RMIX,EGS)
        
END PROGRAM
