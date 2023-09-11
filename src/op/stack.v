module op

pub struct Stack {
	pub mut:
		x []f32
		y []f32
}

pub fn (stack Stack) offset(x f32, y f32) (f32, f32) {
	mut offx := x
	mut offy := y
	for i in 0..stack.x.len {
		offx += stack.x[i]
		offy += stack.y[i]
	}
	return offx, offy
}

pub fn (mut stack Stack) push_offset(x f32, y f32) {
	stack.x << x
	stack.y << y
}

pub fn (mut stack Stack) pop_offset()  {
	stack.x.pop()
	stack.y.pop()
}
