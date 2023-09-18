module data

type Value = string | u8

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
		data: []Value{ len: rows * cols, init: u8(0) }
	}
}

pub fn (mut matrix Matrix) update_value(x int, y int, c string) {
	matrix.data[matrix.width * (x+y)] = c
}

