#SHELL = /bin/tcsh
FC = gfortran
OBJECTS= parmod.o functions.o m1body.o v2read.o rhomat.o meanfield.o diag.o iteration.o main.o
OPTS = -O3 -ffree-form -ffree-line-length-1024
HFLIBS = -L$../libOffice -llapack -lblas
test : $(OBJECTS)
	$(FC) $(OBJECTS) $(HFLIBS) -o $@
parmod.o : parmod.f90
	$(FC) -c $(OPTS) $<
functions.o : functions.f90
	$(FC) -c $(OPTS) $<
m1body.o : m1body.f90
	$(FC) -c $(OPTS) $<
v2read.o : v2read.f90
	$(FC) -c $(OPTS) $<
rhomat.o : rhomat.f90
	$(FC) -c $(OPTS) $<
meanfield.o : meanfield.f90
	$(FC) -c $(OPTS) $<
diag.o : diag.f90
	$(FC) -c $(OPTS) $<
iteration.o : iteration.f90
	$(FC) -c $(OPTS) $<
main.o : main.f90
	$(FC) -c $(OPTS) $<
clean:
	rm -f $(OBJECTS)
	rm -f *.mod
