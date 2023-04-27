# Detects colors in images 5-10 x faster than Numpy 

### pip install locate-pixelcolor-cythonmulti

#### Tested+compiled against Windows 10 / Python 3.10 / Anaconda

#### If you can't import it, compile it on your system (code at the end of this page)



### How to use it in Python 

```python
import numpy as np
import cv2
from locate_pixelcolor_cythonmulti import search_colors
# 4525 x 6623 x 3 picture https://www.pexels.com/pt-br/foto/foto-da-raposa-sentada-no-chao-2295744/
picx = r"C:\Users\hansc\Downloads\pexels-alex-andrews-2295744.jpg"
pic = cv2.imread(picx)
colors0 = np.array([[255, 255, 255]],dtype=np.uint8)
resus0 = search_colors(pic=pic, colors=colors0)
colors1=np.array([(66,  71,  69),(62,  67,  65),(144, 155, 153),(52,  57,  55),(127, 138, 136),(53,  58,  56),(51,  56,  54),(32,  27,  18),(24,  17,   8),],dtype=np.uint8)
resus1 =  search_colors(pic=pic, colors=colors1)
####################################################################
%timeit resus0=search_colors(pic,colors0)
32.3 ms ± 279 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)

b,g,r = pic[...,0],pic[...,1],pic[...,2]
%timeit np.where(((b==255)&(g==255)&(r==255)))
150 ms ± 209 µs per loop (mean ± std. dev. of 7 runs, 10 loops each)
####################################################################
%timeit resus1=search_colors(pic, colors1)
151 ms ± 3.21 ms per loop (mean ± std. dev. of 7 runs, 10 loops each)

%timeit np.where(((b==66)&(g==71)&(r==69))|((b==62)&(g==67)&(r==65))|((b==144)&(g==155)&(r==153))|((b==52)&(g==57)&(r==55))|((b==127)&(g==138)&(r==136))|((b==53)&(g==58)&(r==56))|((b==51)&(g==56)&(r==54))|((b==32)&(g==27)&(r==18))|((b==24)&(g==17)&(r==8)))
1 s ± 16.1 ms per loop (mean ± std. dev. of 7 runs, 1 loop each)
####################################################################
```


### The Cython Code 

```python
# distutils: language = c++
# cython: language_level=3
# distutils: extra_compile_args = /openmp
# distutils: extra_link_args = /openmp


from cython.parallel cimport prange
cimport cython
import numpy as np
cimport numpy as np
import cython
from collections import defaultdict

@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cpdef searchforcolor(unsigned char[:] pic, unsigned char[:] colors, int width, int totallengthpic, int totallengthcolor):
    cdef my_dict = defaultdict(list)
    cdef int i, j
    cdef unsigned char r,g,b
    for i in prange(0, totallengthcolor, 3,nogil=True):
        r = colors[i]
        g = colors[i + 1]
        b = colors[i + 2]
        for j in range(0, totallengthpic, 3):
            if (r == pic[j]) and (g == pic[j+1]) and (b == pic[j+2]):
                with gil:
                    my_dict[(r,g,b)].append(j )

    for key in my_dict.keys():
        my_dict[key] = np.dstack(np.divmod(np.array(my_dict[key]) // 3, width))[0]
    return my_dict

```


### setup.py to compile the code 


```python
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
```