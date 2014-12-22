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

    if v.type_code == 0:
        return ti8xreal_to_int(v)

    return v

def ti8xreal_to_int(v):
    if not isinstance(v, Variable):
        raise TypeError("Argument is not a CyTI variable")
    if v.type_code != 0:
        raise TypeError("Argument is not a TI Real variable")

    val = core._real_frame_to_abs_int(v.data)
    val *= -1 if v.data[0] & 0x80 else 1

    return val
