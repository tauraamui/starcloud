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
		data: []Value{ len: rows * cols, init: '' }
	}
}

pub fn (mut matrix Matrix) insert_text_at(x f32, y f32, pos int, s string) string {
	xx, yy := int(math.floor(x)), int(math.floor(y))
	index := xx + (matrix.width * yy)
	line := matrix.data[index].to_str()
	if line.len == 0 {
		matrix.data[index] = '${s}'
	} else {
		uline := line.runes()
		mut upos := pos
		if upos > uline.len {
			upos = uline.len
		}
		left := uline[..upos].string()
		right := uline[pos..uline.len].string()
		matrix.data[index] = '${left}${s}${right}'
	}

	return matrix.data[index].to_str()
}

pub fn (mut matrix Matrix) remove_text_at(x f32, y f32, pos int) string {
	xx, yy := int(math.floor(x)), int(math.floor(y))
	index := xx + (matrix.width * yy)
	line := matrix.data[index].to_str()
	uline := line.runes()
	if pos == 0 { return uline.string() }
	left := uline[..pos - 1].string()
	mut right := ''
	if pos < uline.len {
		right = uline[pos..].string()
	}
	matrix.data[index] = '${left}${right}'

	return matrix.data[index].to_str()
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

