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

# Conversions between Python and TI types: Cython core

from libc.stdint cimport uint8_t
import math

cpdef _real_frame_to_abs_int(uint8_t[:] frame):
    num = 0

    for i in range(2, 9):
        j = (frame[i] >> 4) * 10
        j += frame[i] & 0xF
        num = (num * 100) + j

    exp = frame[1] - 0x80
    num *= pow(10, -13 + exp)

    return num

cpdef _int_to_real_frame(num):
    cdef uint8_t arr[9]

    if num == 0:
        frame = <uint8_t[:]>arr
        frame[:] = 0
        frame[1] = 0x80
        return frame.copy()

    order = math.floor(math.log(abs(num), 10))
    if(abs(order) > 99):
        raise OverflowError("Argument outside of TI real number range")

    norm = int(math.floor(abs(num) * pow(10, 13 - order)))

    for i in range(0, 7):
        n = norm % 100
        v = n % 10
        v += int(n / 10) << 4
        arr[8 - i] = v
        norm /= 100

    arr[1] = order + 0x80
    arr[0] = 0x80 if num < 0 else 0x0

    return (<uint8_t[:]>arr).copy()
