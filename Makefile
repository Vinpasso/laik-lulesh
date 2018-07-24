#default build suggestion of MPI + OPENMP with gcc on Livermore machines you might have to change the compiler name

# default for LAIK installation: submodule in directory laik/ of this repository
LAIK_ROOT = ../laik

SHELL = /bin/sh
.SUFFIXES: .cc .o

LULESH_EXEC = lulesh2.0

MPI_INC = /opt/local/include/openmpi
MPI_LIB = /opt/local/lib

LAIK_INC =-I$(LAIK_ROOT)/include/
LAIK_LIB =-L$(LAIK_ROOT)/ -llaik

SERCXX = g++ -DUSE_MPI=0
MPICXX = mpic++ 
CXX = $(MPICXX)

SOURCES2.0 = \
	lulesh.cc \
	lulesh-comm.cc \
	lulesh-viz.cc \
	lulesh-util.cc \
	lulesh-init.cc \
	laik_partitioners.cc \
	laik_vector.cc
OBJECTS2.0 = $(SOURCES2.0:.cc=.o)

TARGET = REPARTITIONING

#Default build suggestions with OpenMP for g++
OPT = -O3
#CXXFLAGS = -g $(OPT) -std=c++11 -fopenmp -I. -Wall $(LAIK_INC) -DUSE_MPI=1 -DREPARTITIONING=1
CXXFLAGS = -g $(OPT) -std=c++11 -fopenmp -I. -Wall $(LAIK_INC) -DUSE_MPI=1 -D$(TARGET)=1
LDFLAGS = -g $(OPT) -std=c++11 -fopenmp -Wl,-rpath,$(abspath $(LAIK_ROOT)) $(LAIK_LIB)  -lmpi

#Below are reasonable default flags for a serial build
#CXXFLAGS = -g -O3 -I. -Wall
#LDFLAGS = -g -O3 

#common places you might find silo on the Livermore machines.
#SILO_INCDIR = /opt/local/include
#SILO_LIBDIR = /opt/local/lib
#SILO_INCDIR = ./silo/4.9/1.8.10.1/include
#SILO_LIBDIR = ./silo/4.9/1.8.10.1/lib

#If you do not have silo and visit you can get them at:
#silo:  https://wci.llnl.gov/codes/silo/downloads.html
#visit: https://wci.llnl.gov/codes/visit/download.html

#below is and example of how to make with silo, hdf5 to get vizulization by default all this is turned off.  All paths are Livermore specific.
#CXXFLAGS = -g -DVIZ_MESH -I${SILO_INCDIR} -Wall -Wno-pragmas
#LDFLAGS = -g -L${SILO_LIBDIR} -Wl,-rpath -Wl,${SILO_LIBDIR} -lsiloh5 -lhdf5

.cc.o: lulesh.h
	@echo "Building $<"
	$(CXX) -c $(CXXFLAGS) -o $@  $<

all: $(LULESH_EXEC)

lulesh2.0: $(OBJECTS2.0)
	@echo "Linking"
	$(CXX) $(OBJECTS2.0) $(LDFLAGS) -lm -o $@

clean:
	/bin/rm -f *.o *~ $(OBJECTS) $(LULESH_EXEC)
	/bin/rm -rf *.dSYM

run:
	@echo "testing 8, no repartitioning"
	mpirun -np 8 --oversubscribe ./lulesh2.0 -q -s 2 -repart 0
	@echo "testing 8 -> 1, @ 10"
	mpirun -np 8 --oversubscribe ./lulesh2.0 -q -s 2 -repart 1 -repart_cycle 10
	@echo "testing 8 -> 1, @ 20"
	mpirun -np 8 --oversubscribe ./lulesh2.0 -q -s 2 -repart 1 -repart_cycle 20
	@echo "testing 27 -> 8, @ 20"
	mpirun -np 27 --oversubscribe ./lulesh2.0 -q -s 2 -repart 8 -repart_cycle 20
	@echo "testing 27 -> 1, @ 20"
	mpirun -np 27 --oversubscribe ./lulesh2.0 -q -s 2 -repart 1 -repart_cycle 20
	@echo "testing 64 -> 8, @ 20"
	mpirun -np 64 --oversubscribe ./lulesh2.0 -q -s 2 -repart 8 -repart_cycle 20

tar: clean
	cd .. ; tar cvf lulesh-2.0.tar LULESH-2.0 ; mv lulesh-2.0.tar LULESH-2.0

.SILENT:run
