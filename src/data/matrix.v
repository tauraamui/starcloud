module data

import math

type Value = string | int | f32

fn (value Value) to_str() string {
	match value {
		string {
			return value
		}
		int {
			return value.str()
		}
		else { return "unknown" }
	}
}

pub struct Matrix {
pub:
	width int
	height int
	mut: data []Value
}

pub fn Matrix.new(rows int, cols int) Matrix {
	size := rows * cols
	assert size > 0
	return Matrix{
		width: cols
		height: rows
		data: []Value{ len: rows * cols, init: 0 }
	}
}

pub fn (mut matrix Matrix) update_value(x f32, y f32, c string) {
	ix, iy := int(math.floor(x)), int(math.floor(y))
	matrix.data[ix + (matrix.width * iy)] = 4843
	// matrix.data[matrix.width * (ix+iy)] = c
}


pub fn (mut matrix Matrix) get_value_as_str(x f32, y f32) string {
	ix, iy := int(math.floor(x)), int(math.floor(y))
	return matrix.data[ix + (matrix.width * iy)].to_str()
}

