SUBROUTINE V2_RESHAPE(L,S,LP,SP,VTEMP)!PUT <A|v|B>(LJ,L'J'FIXED) INTO V(N1,N2,N3,N4)
USE PARS
USE V2MATS
USE ORBINDX
IMPLICIT NONE
 INTEGER ::L,S,LP,SP
 INTEGER ::NLIMIT
 REAL(DP)::VTEMP(0:NMAX,0:NMAX,0:NMAX,0:NMAX)
 INTEGER ::NL,NLP,N1,N2,N3,N4,A,B
 VTEMP(:,:,:,:)=0.0D0
 NL=NLIMIT(L,NSHELL)
 NLP=NLIMIT(LP,NSHELL)
 DO N1=0,NL
   DO N2=0,NLP
      DO N3=0,NL
         DO N4=0,NLP
           A=JORB(N1,N3,L,S);B=JORB(N2,N4,LP,SP)
           VTEMP(N1,N2,N3,N4)=V2B_UU(A,B)
         ENDDO
      ENDDO
   ENDDO
ENDDO
RETURN
END SUBROUTINE V2_RESHAPE

SUBROUTINE VMEAN_BASIC(NL,NLP,VMAT,RHOMAT,VMAT_MEAN)!V(N1,N2,N3,N4)*RHO(N2,N4)(L,J,L',J'FIEXED)
USE PARS
IMPLICIT NONE
 INTEGER::NL,NLP
 REAL(DP)::VMAT(0:NMAX,0:NMAX,0:NMAX,0:NMAX),RHOMAT(0:NMAX,0:NMAX)
 REAL(DP)::VMAT_MEAN(0:NMAX,0:NMAX)
 INTEGER::N1,N2,N3,N4
 REAL(DP)::SUMS
 VMAT_MEAN(:,:)=0.0D0
 DO N1=0,NL
    DO N3=0,NL
       SUMS=0.0D0
       DO N2=0,NLP
          DO N4=0,NLP
             SUMS=SUMS+VMAT(N1,N2,N3,N4)*RHOMAT(N4,N2)
          ENDDO
       ENDDO
       VMAT_MEAN(N1,N3)=SUMS
    ENDDO
 ENDDO
 RETURN
END SUBROUTINE VMEAN_BASIC   

SUBROUTINE VMEAN_LS(NL,L,S)!V(L,J,L',J')*RHO(L',J'),SUMS OVER L',J'
USE PARS
USE VMEANS
USE V2MATS
USE RHOS
IMPLICIT NONE
 INTEGER :: NL,L,S
 REAL(DP):: VTEMP(0:NMAX,0:NMAX,0:NMAX,0:NMAX),VM_TEMP(0:NMAX,0:NMAX)
 INTEGER :: LP,SP,SPST,NLP,NLIMIT,SSTART
!
 VMEAN_UU(:,:,S)=0.0D0
 DO LP=0,LUSE
    SPST=SSTART(LP);
    NLP=NLIMIT(LP,NSHELL)
    DO SP=SPST,NSPIN
       CALL V2_RESHAPE(L,S,LP,SP,VTEMP)
       CALL VMEAN_BASIC(NL,NLP,VTEMP,RHO_UU(:,:,LP,SP),VM_TEMP)
       VMEAN_UU(:,:,S)=VMEAN_UU(:,:,S)+VM_TEMP(:,:)
    ENDDO
 ENDDO
END SUBROUTINE VMEAN_LS

SUBROUTINE HMAT_L(NL,L)!BUILD H MATRIX WITH FIXED L AND J=L+-1/2
USE TUMATS
USE VMEANS
USE HMATS
IMPLICIT NONE
 INTEGER::NL,L
 INTEGER::S,START,SSTART	
 START=SSTART(L) 
 DO S=START,NSPIN
    CALL VMEAN_LS(NL,L,S)
    HMAT_UU(:,:,S)=TUMAT(:,:,L)+VMEAN_UU(:,:,S)!TU MAT IS DIAGONAL IN AND INDEPENDENT FROM SPIN
 ENDDO

 RETURN
END SUBROUTINE HMAT_L 
