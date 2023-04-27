# distutils: language = c++
# cython: language_level=3

from setuptools import Extension, setup
from Cython.Build import cythonize
import numpy as np
ext_modules = [
    Extension("colorsearchcythonmulti", ["colorsearchcythonmulti.pyx"], include_dirs=[np.get_include()],define_macros=[("NPY_NO_DEPRECATED_API", "NPY_1_7_API_VERSION")])
]

setup(
    name='colorsearchcythonmulti',
    ext_modules=cythonize(ext_modules),
)


# .\python.exe .\colorsearchcythonmultisetup.py build_ext --inplace