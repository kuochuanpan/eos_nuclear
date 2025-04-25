F90=gfortran -fPIC -O2

#HDF5_PATH = /cluster/software/hdf5-parallel/1.8.21/gcc--8.3.0/openmpi--3.1.4
#HDF5_INCLUDE_PATH = /cluster/software/hdf5-parallel/1.8.21/gcc--8.3.0/openmpi--3.1.4
#HDF5_LIB_PATH = /cluster/software/hdf5-parallel/1.8.21/gcc--8.3.0/openmpi--3.1.4

HDF5INCS=-I${HDF5_INCLUDE_PATH}/include
HDF5LIBS=-L${HDF5_LIB_PATH}/lib -lhdf5 -lhdf5_fortran -lhdf5 -lz

