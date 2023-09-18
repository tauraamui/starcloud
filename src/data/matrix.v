module data

type Value = string | u8

pub struct Matrix {
	data &Value
}

pub fn Matrix.new(rows, cols int) Matrix {
	size := rows * cols
	assert size > 0
	return Matrix{
		data: &Value(malloc(int(sizeof(Value)) * rows * cols))
	}
}

