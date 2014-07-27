SUBROUTINE E_REORDER(NFIX)!DETERMINE OCCUPIED ORBIT AND PARTICLE NUMBER IN EACH ORBIT
USE PARS
USE LABELS
USE EIGENS
IMPLICIT NONE
 
 INTEGER::NFIX
 INTEGER::L,S,START,N,ITOTAL
 INTEGER::NN,IBEGIN,IEND,I,J,JM,NREMAIN
 INTEGER::NLIMIT,STATE_TOTAL,SSTART
 TYPE(EINX)::ETEMP
 TYPE(EINX),ALLOCATABLE::EIGORD(:)
!
 IF(.NOT.(ALLOCATED(EIGORD)))THEN
    ITOTAL=STATE_TOTAL(NSHELL,LUSE)
    ALLOCATE(EIGORD(0:ITOTAL))
 ENDIF
 EIGORD(:)%E=0.0D0;EIGORD(:)%N=0
 EIGORD(:)%L=0;    EIGORD(:)%S=0
 DEGENER(:,:,:)=0
!write(*,*)itotal
 IBEGIN=0;IEND=0;
!
 DO L=0,LUSE
    START=SSTART(L)
    NN=NLIMIT(L,NSHELL)!NN IS MAX N NUMBER WHEN L IS FIXED
    DO S=START,NSPIN  
       DO N=0,NN    
          EIGORD(IBEGIN+N)%E=EIGVAL_NEW(N,L,S)!MERGE EIGEN VALUE IN EVERY BLOCK
	  EIGORD(IBEGIN+N)%N=N;EIGORD(IBEGIN+N)%L=L;EIGORD(IBEGIN+N)%S=S
       ENDDO
    IBEGIN=IBEGIN+NN+1
    ENDDO
 ENDDO

 DO I=0,ITOTAL-1!ARRANGE ENERGIES IN ASCENDING ORDER
    DO J=I+1,ITOTAL
       IF (EIGORD(J)%E<EIGORD(I)%E)THEN
          ETEMP=EIGORD(I);EIGORD(I)=EIGORD(J);EIGORD(J)=ETEMP
       ENDIF
    ENDDO
 ENDDO
!
 NBELOW(:,:)=0
 I=0;NREMAIN=NFIX
 DO WHILE(NREMAIN>0)!FIND OCCUPIED 2j+1 FOLDED HF STATE IN EACH BLOCK AND PARTICLE NUBMER IN EACH STATE
    JM=2*(EIGORD(I)%L+EIGORD(I)%S)!
    NREMAIN=NREMAIN-JM
    IF(NREMAIN>0)THEN
       DEGENER(EIGORD(I)%N,EIGORD(I)%L,EIGORD(I)%S)=JM!PUT 2J+1 PARTICLE INTO CURRENT HF STATE
       NBELOW(EIGORD(I)%L,EIGORD(I)%S)=NBELOW(EIGORD(I)%L,EIGORD(I)%S)+1
!       write(*,*)eigord(i)%E,eigord(i)%n,eigord(i)%l,eigord(i)%s,DEGENER(EIGORD(I)%N,EIGORD(I)%L,EIGORD(I)%S)
    ELSE!LAST ORBIT MAY NOT BE FULLY OCCUPIED
       DEGENER(EIGORD(I)%N,EIGORD(I)%L,EIGORD(I)%S)=NREMAIN+JM!PUT REMAIN PARTICLE INTO CURRENT HF STATE
       NBELOW(EIGORD(I)%L,EIGORD(I)%S)=NBELOW(EIGORD(I)%L,EIGORD(I)%S)+1
!       write(*,*)eigord(i)%E,eigord(i)%n,eigord(i)%l,eigord(i)%s,DEGENER(EIGORD(I)%N,EIGORD(I)%L,EIGORD(I)%S)
    ENDIF 
    I=I+1!MOVE TO NEXT ORBIT  
 ENDDO
 RETURN
END SUBROUTINE E_REORDER

SUBROUTINE ENERGY_LS(NL,N_OCC,DEGE,EVNEW,EV,ENLS,ERRLS)!FIND MEAN FIELD ENERGY IN A LS BLOCK AND UPDATE EIGVEC
USE PARS
IMPLICIT NONE
 INTEGER ::NL,N_OCC,ISSYM
 REAL(DP)::EVNEW(0:NMAX),EV(0:NMAX)
 INTEGER ::DEGE(0:NMAX)
 REAL(DP)::ENLS,ERRLS
 INTEGER::ISPIN,I
 ENLS=0.0D0;ERRLS=0.0D0
 DO I=0,NL
    IF(I<=N_OCC)ENLS=ENLS+EVNEW(I)*DEGE(I)
    ERRLS=ERRLS+ABS(EVNEW(I)-EV(I))
 ENDDO
 EV(:)=EVNEW(:)
 RETURN
END SUBROUTINE ENERGY_LS

SUBROUTINE TE_LS(NL,L,S,TUES)!TR((T+U)*RHO) IN LS BLOCK
USE PARS
USE TUMATS
USE RHOS
!USE EIGENS
IMPLICIT NONE
 INTEGER::NL,L,S
 REAL(DP)::TUES,SUMS
 INTEGER::I,JM
 JM=2*(L+S)
 SUMS=0.0D0
 DO I=0,NL
    SUMS=SUMS+TUMAT(I,I,L)*RHO_UU(I,I,L,S)
 ENDDO
 TUES=SUMS
END SUBROUTINE TE_LS

SUBROUTINE TE_ALL(TENERGY)
USE PARS
IMPLICIT NONE
 INTEGER ::ISSYM
 REAL(DP)::TENERGY
 INTEGER ::L,S,START,NL,NLIMIT,SSTART
 REAL(DP)::TUES
 TENERGY=0.0D0
 DO L=0,LUSE
    START=SSTART(L)
    NL=NLIMIT(L,NSHELL)
    DO S=START,NSPIN
       CALL TE_LS(NL,L,S,TUES)
       TENERGY=TENERGY+TUES
    ENDDO
 ENDDO
 RETURN 
END SUBROUTINE TE_ALL 

SUBROUTINE ENERGY_NEW(EGS,ERROR)!FIND G.S ENERGY;CALCULATE ERRORS;UPDATE EIGVALUE VECTOR
USE PARS
USE EIGENS
IMPLICIT NONE
 REAL(DP)::EGS,ERROR
 INTEGER ::L,START,S,NL,NEIG,N_OCC,NLIMIT,SSTART
 REAL(DP)::TENERGY,ENLS,ERRLS
 EGS=0.0D0;ERROR=0.0D0;NEIG=0
!
 DO L=0,LUSE
    START=SSTART(L)
    NL=NLIMIT(L,NSHELL)
    DO S=START,NSPIN
       N_OCC=NBELOW(L,S)
       CALL ENERGY_LS(NL,N_OCC,DEGENER(:,L,S),EIGVAL_NEW(:,L,S),&
            EIGVAL(:,L,S),ENLS,ERRLS)
       EGS=EGS+ENLS;ERROR=ERROR+ERRLS;NEIG=NEIG+(NL+1)
    ENDDO
 ENDDO
!ONE BODY ENERGY
 CALL TE_ALL(TENERGY)
!
 EGS=0.5*(EGS+TENERGY)
 ERROR=ERROR/NEIG
 RETURN
END SUBROUTINE ENERGY_NEW 

SUBROUTINE INITIAL(TFIX)
USE PARS
USE RHOS
USE EIGENS
IMPLICIT NONE
 INTEGER:: TFIX
 INTEGER:: N,NL,L,S,START,NREMAIN,JM
 INTEGER:: NLIMIT,SSTART
 REAL(DP)::ALPHA
!
 RHO_UU(:,:,:,:)=0.0D0
 EIGVAL_NEW(:,:,:)=0.0D0;EIGVAL(:,:,:)=0.0D0
! 
 CALL T1BODY !CALCULATE ONE-BODY MATRIX ELEMENTS
 CALL V2_BUILD!CALCULATE TWO-BODY MATRIX ELEMENTS
!INITIALIZE RHO
 NREMAIN=TFIX
 DO L=0,LUSE
    START=SSTART(L)
    NL=NLIMIT(L,NSHELL)
    DO S=START,NSPIN
       JM=2*(L+S)
       DO N=0,NL
          NREMAIN=NREMAIN-JM
          IF(NREMAIN>0)THEN
             RHO_UU(N,N,L,S)=JM
             DEGENER(N,L,S)=JM
          ELSE
             RHO_UU(N,N,L,S)=NREMAIN+JM
             DEGENER(N,L,S)=NREMAIN+JM
             GO TO 1
          ENDIF
       ENDDO
    ENDDO
 ENDDO

   1 CONTINUE

 RETURN
END SUBROUTINE INITIAL

SUBROUTINE ITERS(NFIX,ISSYM,ISPIND,EPSI,ITMAX,ITNOW,IFLAG,FLAGMAX,RMIX,EGS)
USE PARS
USE RHOS
USE TUMATS
USE EIGENS
IMPLICIT NONE
 INTEGER ::ISSYM,ISPIND
 REAL(DP)::EPSI,RMIX,ERROR
 INTEGER ::NFIX,ISPINC,ITMAX,ITNOW,IFLAG,FLAGMAX
 REAL(DP)::EGS,TES
 INTEGER ::L,S,START,NL,NLIMIT,SSTART
!
100 FORMAT(A4,5X,A9,3X,A10)
!200 FORMAT(I4,5X,F9.5,3X,E10.3)
200 FORMAT(I4,5X,F9.5,3X,E10.3,E12.5,E12.5)
 WRITE(*,100)'ITER','ENERGY','DIFF'
 DO WHILE ((IFLAG<FLAGMAX).AND.(ITNOW<=ITMAX))
!
    DO L=0,LUSE!DIAGONAL EVERY L BLOCK
       NL=NLIMIT(L,NSHELL)
       START=SSTART(L)
       CALL HMAT_L (NL,L)!BUILD H MATRIX      
       CALL HDIAG_L(NL,L)!DIAGONALIZATION        
    ENDDO!END DIAGONALIZE IN ALL BLOCKS
!
    CALL E_REORDER(NFIX)!FIND ASCENDING ORDER
    CALL RHO_ALL!RHO IS BUILD AFTER ORDERING ENERGY IN DIFFERENT BLOCK
    CALL ENERGY_NEW(EGS,ERROR)
    CALL RHO_NEW(RMIX)   
!
    WRITE(*,200)ITNOW,EGS,ERROR,EIGVAL(0,0,1),EIGVAL(1,0,1)
    IF(ABS(ERROR)<EPSI) IFLAG=IFLAG+1
    ITNOW=ITNOW+1
 ENDDO
 RETURN
END SUBROUTINE ITERS

