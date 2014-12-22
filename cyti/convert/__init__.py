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

def to_python(v):
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")

    if v.type_code == 0x0:
        return ti8xreal_to_int(v)
    if v.type_code == 0x1:
        return ti8xreallist_to_list(v)

    return v

def ti8xreal_to_int(v):
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")
    if v.type_code != 0x0:
        raise TypeError("Argument is not a TI Real variable")

    val = core._real_frame_to_abs_int(v.data)
    val *= -1 if v.data[0] & 0x80 else 1

    return val

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
