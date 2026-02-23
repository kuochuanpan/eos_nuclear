project(
  'eos_nuclear',
  'c', 'fortran',
  version: '0.2.0',
  meson_version: '>=1.3',
  default_options: [
    'fortran_std=legacy',
  ],
)

py = import('python').find_installation(pure: false)
np_dep = dependency('numpy', required: true)

subdir('eos_nuclear')
