from distutils.core import setup
from Cython.Build import cythonize
import os

pyxFiles = [os.path.join('pyGrape', f) for f in os.listdir('pyGrape') if f.endswith('.pyx')]

setup(
  name = 'pyGrape',
  ext_modules = cythonize('pyGrape/indexing.pyx', 'pyGrape/collection.pyx'),
)
