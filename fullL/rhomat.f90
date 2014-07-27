SUBROUTINE RHO_BASIC(NL,N_OCC,DEG,VEC1,VEC2,RHOMAT)
USE PARS
IMPLICIT NONE
 INTEGER::NL,N_OCC
 REAL(DP)::VEC1(0:NMAX,0:NMAX),VEC2(0:NMAX,0:NMAX)!EIGEN VECTOR
 INTEGER::DEG(0:NMAX)!PARTICLE NUMBER IN EACH OCCUPIED ORBIT
 REAL(DP)::RHOMAT(0:NMAX,0:NMAX)!OUTPUT RHO
 INTEGER::IBRA,IKET,I
 REAL(DP)::SUMS
 RHOMAT(:,:)=0.0D0
 DO IBRA=0,NL
    DO IKET=0,NL
       SUMS=0.0D0
       DO I=0,N_OCC-1!FROM 0 TO N_OCC-1, TOTAL NUMBER IS N_OCC
             SUMS=SUMS+VEC1(IBRA,I)*VEC2(IKET,I)*DEG(I)
       ENDDO
       RHOMAT(IBRA,IKET)=SUMS
    ENDDO
 ENDDO
 RETURN
END SUBROUTINE RHO_BASIC 

SUBROUTINE RHO_LS(NL,L,S)!RHO WITH A GIVE L,J(S)
USE PARS
USE EIGENS
USE RHOS
IMPLICIT NONE 
 INTEGER :: NL,L,S
 REAL(DP)::RMIX
 INTEGER :: START,N_OCC
 REAL(DP):: RTEMP(0:NMAX,0:NMAX)
 INTEGER:: DEG(0:NMAX)
 N_OCC=NBELOW(L,S)!FIND THE NUMBER OF OCCUPIED ORBIT IN THIS L,J BLOCK
 DEG=DEGENER(:,L,S)!PARTICLE NUMBER IN EACH OCCUPIED ORBIT
 CALL RHO_BASIC(NL,N_OCC,DEG,EVEC_UU(:,:,L,S),&
      EVEC_UU(:,:,L,S),RHONEW_UU(:,:,L,S))
 RETURN
END SUBROUTINE RHO_LS

SUBROUTINE RHO_ALL!BUILD NEW RHO MATRIX
USE PARS
IMPLICIT NONE
 INTEGER::ISSYM,ISPIND,NLIMIT
 INTEGER::NL,L,START,S,SSTART
 DO L=0,LUSE
    START=SSTART(L)
    NL=NLIMIT(L,NSHELL)
    DO S=START,NSPIN
       CALL RHO_LS(NL,L,S)
    ENDDO
 ENDDO
END SUBROUTINE RHO_ALL  

SUBROUTINE RHO_NEW(RMIX)!MIX RHO MATRIX WITH OLD ONE
USE RHOS
IMPLICIT NONE
 REAL(DP)::RMIX
 INTEGER::SMAX,ISPIND
 INTEGER::S
    RHO_UU(:,:,:,:)=RHONEW_UU(:,:,:,:)*RMIX&
                       +RHO_UU(:,:,:,:)*(1-RMIX)       
 RETURN
END SUBROUTINE RHO_NEW
 
