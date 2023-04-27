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
