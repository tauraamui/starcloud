module widgets

import gg
import gx
import op

const (
	cell_width = 80
	cell_height = 20
)

struct Matrix {
	cols int
	rows int
mut:
	position_x f32
	position_y f32
	is_dragging bool
}

fn (matrix Matrix) draw(ops op.Stack, gfx &gg.Context) {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	matrix.clip(posx, posy, gfx)
	defer { matrix.noclip(gfx) }
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(245, 245, 245))
			gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgba(115, 115, 115, 100))
		}
	}
}

fn (mut matrix Matrix) on_event(ops op.Stack, e &gg.Event) bool {
	match e.typ {
		.mouse_down {
			if !matrix.contains_point(ops, e.mouse_x / gg.dpi_scale(), e.mouse_y / gg.dpi_scale()) { return false }
			if e.mouse_button == gg.MouseButton.right {
				matrix.is_dragging = true
			}
		}
		.mouse_move {
			if matrix.is_dragging {
				matrix.position_x += (e.mouse_dx / gg.dpi_scale())
				matrix.position_y += (e.mouse_dy / gg.dpi_scale())
				return true
			}
		}
		.mouse_up {
			matrix.is_dragging = false
		}
		else {}
	}
	return false
}

fn (matrix Matrix) contains_point(ops op.Stack, pt_x f32, pt_y f32) bool {
	area := matrix.area(ops)
	if pt_x > area.x && pt_x < area.x + area.width && pt_y > area.y && pt_y < area.y + area.height { return true }
	return false
}

fn (matrix Matrix) area(ops op.Stack) gg.Rect {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	width := matrix.cols * cell_width
	height := matrix.rows * cell_height
	return gg.Rect{ x: posx, y: posy, width: width, height: height }
}

fn (matrix Matrix) clip(posx f32, posy f32, gfx &gg.Context) {
	width := matrix.cols * cell_width
	height := matrix.rows * cell_height
	gfx.scissor_rect(int(posx), int(posy), width, height)
}

fn (matrix Matrix) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}

