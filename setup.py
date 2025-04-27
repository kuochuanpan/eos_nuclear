from setuptools import setup, find_packages

VERSION = '0.1.1'
DESCRIPTION = 'A python wrapper for the nuclear EoS table'
LONG_DESCRIPTION = 'A python wrapper for the nuclear EoS table'

# Setting up
setup(
    name="eos_nuclear",
    version=VERSION,
    author="Kuo-Chuan Pan",
    author_email="<kuochuan.pan@gapp.nthu.edu.tw>",
    description=DESCRIPTION,
    long_description=LONG_DESCRIPTION,
    packages=find_packages(),
    include_package_data=True,
    package_data={'eos_nuclear': ['src/eospy*.so']},
    zip_safe=False,
    install_requires=['numpy', 'scipy', 'h5py'],
    keywords=['python', 'eos', 'nuclear'],
    classifiers=[
        "Development Status :: 1 - Planning",
        "Intended Audience :: Science/Research",
        "Programming Language :: Python :: 3",
        "Operating System :: Unix",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Microsoft :: Windows",
    ]
)
