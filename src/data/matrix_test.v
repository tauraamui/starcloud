module data

fn test_matrix_initialisation() {
	rows, cols := 3, 2
	m := Matrix.new(rows, cols)
	assert m.data == [ Value(u8(0)), Value(u8(0)), Value(u8(0)), Value(u8(0)), Value(u8(0)), Value(u8(0)) ]
}

fn test_matrix_value_updating() {
	rows, cols := 3, 2
	mut m := Matrix.new(rows, cols)
	m.update_value(1, 1, "row1,col1")
	assert m.data == [ Value(u8(0)), Value(u8(0)), Value(u8(0)), Value(u8(0)), Value("row1,col1"), Value(u8(0)) ]

	m.update_value(0, 1, "row0,col1")
	assert m.data == [ Value(u8(0)), Value(u8(0)), Value("row0,col1"), Value(u8(0)), Value("row1,col1"), Value(u8(0)) ]
}
