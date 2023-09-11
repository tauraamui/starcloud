module widgets

import gg
import op

[heap]
pub struct Canvas {
mut:
	ops op.Stack
	world_offset_x f32
	world_offset_y f32
	matrices []Matrix

	evt_area gg.Rect
}

pub fn Canvas.new() Canvas {
	return Canvas{
		world_offset_x: 0
		world_offset_y: 0
		matrices: [
			Matrix{ position_x: 10, position_y: 10, cols: 2, rows: 4 }
			Matrix{ position_x: 10, position_y: 180, cols: 10, rows: 8 }
		]
	}
}

pub fn (mut canvas Canvas) draw(gfx &gg.Context) {
	canvas.ops.push_offset(canvas.world_offset_x, canvas.world_offset_y)
	defer { canvas.ops.pop_offset() }
	for _, m in canvas.matrices {
		m.draw(canvas.ops, gfx)
	}
}

pub fn (mut canvas Canvas) on_event(e &gg.Event, v voidptr) {
	for _, m in canvas.matrices {
		if m.on_event(e) { return }
	}
}

fn within_area(ops op.Stack, ptx f32, pty f32, area gg.Rect) bool {
	areax, areay := ops.offset(area.x, area.y)
	if ptx > areax && ptx < areax + area.width && pty > areay && pty < areay + area.height { return true }
	return false
}

