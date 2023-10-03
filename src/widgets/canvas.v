module widgets

import gg
import gx
import op
import sokol.sapp
import data
import draw

[heap]
pub struct Canvas {
mut:
	world_offset_x f32
	world_offset_y f32
	matrices []Matrix
	is_dragging bool
	zoom_percentage f32
	scale f32
}

pub fn Canvas.new() Canvas {
	return Canvas{
		zoom_percentage: 100
		scale: f32(gg.dpi_scale())
		world_offset_x: 20
		world_offset_y: 0
		matrices: [
			Matrix{
				position_x: 10, position_y: 10,
				cell_in_edit_mode: widgets.Pt{ x: -1, y: -1 }
				mdata: data.Matrix.new(4, 2)
				editor: Editor{
					area: Area{ size: Pt{ x: draw.cell_width, y: draw.cell_height} }
					bg_color: gx.rgb(206, 160, 242)
				}
			},
			Matrix{
				position_x: 10, position_y: 180,
				cell_in_edit_mode: widgets.Pt{ x: -1, y: -1 }
				mdata: data.Matrix.new(25, 15)
				editor: Editor{
					area: Area{ size: Pt{ x: draw.cell_width, y: draw.cell_height} }
					bg_color: gx.rgb(206, 160, 242)
				}
			}
		]
	}
}

pub fn (mut canvas Canvas) draw(mut ops op.Stack, mut gfx &gg.Context) {
	canvas.scale = (canvas.zoom_percentage / 100) * f32(gg.dpi_scale())
	if gfx.scale != canvas.scale {
		gfx.scale = canvas.scale
	}
	ops.push_offset(canvas.world_offset_x, canvas.world_offset_y)
	defer { ops.pop_offset() }
	for _, mut m in canvas.matrices {
		m.draw(mut ops, gfx)
	}
}

pub fn (mut canvas Canvas) on_event(e &gg.Event, mut ops op.Stack) {
	ops.push_offset(canvas.world_offset_x, canvas.world_offset_y)
	defer { ops.pop_offset() }
	for i := canvas.matrices.len-1; i >= 0; i-- {
		if canvas.matrices[i].on_event(ops, e, canvas.scale) { return }
	}

	match e.typ {
		.mouse_scroll {
			canvas.zoom_percentage += (e.scroll_y) * .5
			if canvas.zoom_percentage < 10 {
				canvas.zoom_percentage = 10
			} else if canvas.zoom_percentage > 180 {
				canvas.zoom_percentage = 180
			}
		}
		.mouse_down {
			if e.mouse_button == gg.MouseButton.right {
				sapp.set_mouse_cursor(sapp.MouseCursor.resize_all)
				canvas.is_dragging = true
			}
		}
		.mouse_move {
			if canvas.is_dragging {
				canvas.world_offset_x += e.mouse_dx / canvas.scale
				canvas.world_offset_y += e.mouse_dy / canvas.scale
			}
		}
		.mouse_up {
			canvas.is_dragging = false
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
		}
		else {}
	}
}

pub fn (mut canvas Canvas) on_key_down(key gg.KeyCode, mod gg.Modifier) {
	for i := canvas.matrices.len-1; i >= 0; i-- {
		canvas.matrices[i].on_key_down(key, mod)
	}
}

pub fn (mut canvas Canvas) on_char(c u32) {
	buf := [5]u8{}
	s := unsafe { utf32_to_str_no_malloc(c, &buf[0]) }

	for i := canvas.matrices.len-1; i >= 0; i-- {
		canvas.matrices[i].on_char(s)
	}
}

