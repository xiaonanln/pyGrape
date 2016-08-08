from distutils.core import setup
from Cython.Build import cythonize
import os

setup(
  name = 'pyGrape',
  ext_modules = cythonize(['pyGrape/*.pyx', 'pyGrape/*.c']),
)
