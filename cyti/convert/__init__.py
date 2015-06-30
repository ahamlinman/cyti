# CyTI - A Cython module for linking with TI calculators.
#
# Copyright (C) 2014 Alex Hamlin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Conversions between Python and TI types

from cyti.types import Variable

from cyti.convert import core
from cyti import types

from array import array

import cyti

def to_python(v):
    try:
        if v.type_code == 0x0: # Real
            return _ti8xreal_to_int(v)
        if v.type_code == 0x1: # Real List
            return _ti8xreallist_to_list(v)
        if v.type_code == 0x2: # Matrix
            return _ti8xmatrix_to_matrix(v)
        if v.type_code == 0xC: # Complex
            return _ti8xcomplex_to_complex(v)
        if v.type_code == 0xD: # Complex List
            return _ti8xcomplexlist_to_list(v)
    except Exception:
        raise TypeError("Unable to convert to Python type")

    return v

def to_cyti(v, name, calc):
    # Real or complex number
    if hasattr(v, "real"):
        if hasattr(v, "imag"):
            return _complex_to_ti8xcomplex(v, name, calc)
        else:
            return _int_to_ti8xreal(v, name, calc)

    # Real or complex list
    try:
        if not False in [hasattr(i, "real") for i in v]:
            if True in [hasattr(i, "imag") for i in v]:
                return _list_to_ti8xcomplexlist(v, name, calc)
            else:
                return _list_to_ti8xreallist(v, name, calc)
    except TypeError:
        pass

    # Matrix
    try:
        if not False in [[hasattr(n, "real") for n in row] for row in v]:
            return _matrix_to_ti8xmatrix(v, name, calc)
    except TypeError:
        pass

    raise TypeError("Unable to convert the given argument")

def _ti8xreal_to_int(v):
    if v.type_code != 0x0:
        raise TypeError("Argument is not a TI Real variable")

    return core._real_frame_to_int(v.data)

def _int_to_ti8xreal(i, name, calc):
    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_real_var(calc, name)
    v.data[:] = core._int_to_real_frame(i)
    return v

def _ti8xreallist_to_list(v):
    if v.type_code != 0x1:
        raise TypeError("Argument is not a TI Real List variable")

    vals = []
    size = v.data[1] * 256 + v.data[0]

    for i in range(0, size):
        idx = i * 9 + 2
        frame = v.data[idx:idx+9]
        val = core._real_frame_to_int(frame)
        vals.append(val)

    return vals

def _list_to_ti8xreallist(l, name, calc):
    if len(l) > 999:
        raise OverflowError("Argument has too many elements for a TI Real List")

    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_real_list_var(calc, name, len(l))
    v.data[0:2] = array("B", [len(l) % 256, len(l) // 256])

    for i in range(0, len(l)):
        idx = i * 9 + 2
        v.data[idx:idx+9] = core._int_to_real_frame(l[i])

    return v

def _ti8xmatrix_to_matrix(v):
    if v.type_code != 0x2:
        raise TypeError("Argument is not a TI Matrix variable")

    cols = v.data[0]
    rows = v.data[1]

    vals = [[] for i in range(rows)]
    for i in range(rows):
        for j in range(cols):
            idx = (i * cols + j) * 9 + 2
            vals[i].append(core._real_frame_to_int(v.data[idx:idx+9]))

    return vals

def _matrix_to_ti8xmatrix(m, name, calc):
    rows = len(m)
    cols = len(m[0])

    if [len(row) for row in m].count(cols) != len(m):
        raise TypeError("All rows must contain the same number of columns")

    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_matrix_var(calc, name, rows, cols)
    v.data[0] = cols
    v.data[1] = rows

    for i in range(rows):
        for j in range(cols):
            idx = (i * cols + j) * 9 + 2
            v.data[idx:idx+9] = core._int_to_real_frame(m[i][j])

    return v

def _ti8xcomplex_to_complex(v):
    if v.type_code != 0xC:
        raise TypeError("Argument is not a TI Complex variable")

    real_part = core._real_frame_to_int(v.data[0:9])
    imag_part = core._real_frame_to_int(v.data[9:18])
    return complex(real_part, imag_part)

def _complex_to_ti8xcomplex(c, name, calc):
    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_complex_var(calc, name)
    v.data[0:9] = core._int_to_real_frame(c.real)
    v.data[9:18] = core._int_to_real_frame(c.imag)
    v.data[0] |= 0xC
    v.data[9] |= 0xC

    return v

def _ti8xcomplexlist_to_list(v):
    if v.type_code != 0xD:
        raise TypeError("Argument is not a TI Complex List variable")

    vals = []
    size = v.data[1] * 256 + v.data[0]

    for i in range(0, size):
        idx = i * 18 + 2
        frame = v.data[idx:idx+18]
        real_part = core._real_frame_to_int(frame[0:9])
        imag_part = core._real_frame_to_int(frame[9:18])
        val = complex(real_part, imag_part)
        vals.append(val)

    return vals

def _list_to_ti8xcomplexlist(l, name, calc):
    if len(l) > 999:
        raise OverflowError("Argument has too many elements for a TI Complex List")

    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_complex_list_var(calc, name, len(l))
    v.data[0:2] = array("B", [len(l) % 256, len(l) // 256])

    for i in range(0, len(l)):
        idx = i * 18 + 2
        frame = v.data[idx:idx+18]
        frame[0:9] = core._int_to_real_frame(l[i].real)
        frame[9:18] = core._int_to_real_frame(l[i].imag)
        frame[0] |= 0x0C
        frame[9] |= 0x0C

    return v
