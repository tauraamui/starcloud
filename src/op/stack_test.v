module op

fn test_operation_stack_offsets_correctly() {
	mut stack := Stack{}
	stack.push_offset(10, 10)
	offx, offy := stack.offset(15, 15)
	assert offx == 25 && offy == 25
}

fn test_operation_stack_single_scalar_scales_correctly() {
	mut stack := Stack{}
	stack.push_scalar(1.5)
	assert stack.scale(10) == 15
}

fn test_operation_stack_multiple_scalar_scales_correctly() {
	mut stack := Stack{}
	stack.push_scalar(1.5)
	stack.push_scalar(.5)
	assert stack.scale(10) == 7.5
}

