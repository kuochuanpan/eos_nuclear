# Find dependencies
hdf5_dep = dependency('hdf5', language: 'fortran', required: true)

# Check for OpenMP (Fortran only — avoid passing -fopenmp to Apple clang)
fc = meson.get_compiler('fortran')
has_openmp = fc.has_argument('-fopenmp')
omp_fortran_args = has_openmp ? ['-fopenmp'] : []

# Find libgomp for linking (works with clang linker)
omp_link_args = []
if has_openmp
  gomp = fc.find_library('gomp', required: false)
  if gomp.found()
    omp_link_args = ['-lgomp']
  endif
endif

# NumPy include dirs (for f2py headers)
incdir_numpy = run_command(py,
  ['-c', 'import numpy; print(numpy.get_include())'],
  check: true,
).stdout().strip()

incdir_f2py = run_command(py,
  ['-c', 'import numpy.f2py; import os; print(os.path.join(os.path.dirname(numpy.f2py.__file__), "src"))'],
  check: true,
).stdout().strip()

# fortranobject.c is needed by all f2py extensions
fortranobject_c = incdir_f2py / 'fortranobject.c'

# Fortran sources for the EOS library (order matters: modules first)
fortran_srcs = files(
  'eosmodule.F90',
  'readtable.F90',
  'nuc_eos.F90',
  'bisection.F90',
  'findtemp.F90',
  'findrho.F90',
  'linterp_many.F90',
  'linterp.f',
)

# f2py wrapper source
f2py_wrapper = files('eospy.F90')

# Use f2py to generate the C glue code
f2py_gen = custom_target(
  'eospy_f2py',
  input: f2py_wrapper,
  output: ['eospymodule.c', 'eospy-f2pywrappers.f'],
  command: [
    py, '-m', 'numpy.f2py',
    '@INPUT@',
    '-m', 'eospy',
    '--lower',
    '--build-dir', '@OUTDIR@',
  ],
)

# Build the f2py extension module
py.extension_module(
  'eospy',
  [fortran_srcs, f2py_wrapper, f2py_gen, fortranobject_c],
  dependencies: [hdf5_dep],
  include_directories: [incdir_numpy, incdir_f2py],
  subdir: 'eos_nuclear/src',
  install: true,
  fortran_args: ['-fPIC', '-O2'] + omp_fortran_args,
  link_args: omp_link_args,
)

# Install the __init__.py for the src subpackage
py.install_sources(
  '__init__.py',
  subdir: 'eos_nuclear/src',
)
