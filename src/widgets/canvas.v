module widgets

import gg
import op
import sokol.sapp

[heap]
pub struct Canvas {
mut:
	ops op.Stack
	world_offset_x f32
	world_offset_y f32
	matrices []Matrix

	is_dragging bool

	evt_area gg.Rect
}

pub fn Canvas.new() Canvas {
	return Canvas{
		world_offset_x: 20
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
	canvas.ops.push_offset(canvas.world_offset_x, canvas.world_offset_y)
	defer { canvas.ops.pop_offset() }
	for i := canvas.matrices.len-1; i >= 0; i-- {
		if canvas.matrices[i].on_event(canvas.ops, e) { return }
	}

	match e.typ {
		.mouse_down {
			if e.mouse_button == gg.MouseButton.right {
				sapp.set_mouse_cursor(sapp.MouseCursor.resize_all)
				canvas.is_dragging = true
			}
		}
		.mouse_move {
			if canvas.is_dragging {
				canvas.world_offset_x += e.mouse_dx / gg.dpi_scale()
				canvas.world_offset_y += e.mouse_dy / gg.dpi_scale()
			}
		}
		.mouse_up {
			canvas.is_dragging = false
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
		}
		else {}
	}
}

