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

cpdef _real_frame_to_int(uint8_t[:] frame):
    num = 0

    for i in range(2, 9):
        j = (frame[i] >> 4) * 10
        j += frame[i] & 0xF
        num = (num * 100) + j

    exp = frame[1] - 0x80
    num *= pow(10, -13 + exp)

    return num
