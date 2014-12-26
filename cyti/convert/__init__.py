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
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")

    if v.type_code == 0x0:
        return ti8xreal_to_int(v)
    if v.type_code == 0x1:
        return ti8xreallist_to_list(v)

    return v

def to_cyti(v, name, calc):
    if isinstance(v, int) or isinstance(v, float):
        return int_to_ti8xreal(v, name, calc)
    elif isinstance(v, list):
        return list_to_ti8xreallist(v, name, calc)
    else:
        raise TypeError("Unable to convert the given argument")

def ti8xreal_to_int(v):
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")
    if v.type_code != 0x0:
        raise TypeError("Argument is not a TI Real variable")

    val = core._real_frame_to_abs_int(v.data)
    val *= -1 if v.data[0] & 0x80 else 1

    return val

def int_to_ti8xreal(i, name, calc):
    if not isinstance(i, int) and not isinstance(i, float):
        raise TypeError("Argument cannot be converted to a TI Real variable")

    if isinstance(calc, cyti.Calculator):
        calc = calc.calc_model

    v = types._create_ti8x_real_var(calc, name)
    v.data[:] = core._int_to_real_frame(i)
    return v

def ti8xreallist_to_list(v):
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")
    if v.type_code != 0x1:
        raise TypeError("Argument is not a TI Real List variable")

    vals = []
    size = v.data[1] * 256 + v.data[0]

    for i in range(0, size):
        idx = i * 9 + 2
        frame = v.data[idx:idx+9]
        val = core._real_frame_to_abs_int(frame)
        val *= -1 if frame[0] & 0x80 else 1
        vals.append(val)

    return vals

def list_to_ti8xreallist(l, name, calc):
    if not isinstance(l, list):
        raise TypeError("Argument cannot be converted to a TI Real List variable")
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
