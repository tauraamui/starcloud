module widgets

import gg
import gx
import op
import sokol.sapp

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
	is_selecting bool
	selection_begin_pos_x f32
	selection_begin_pos_y f32
	selection_width f32
	selection_height f32
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

	if matrix.selection_begin_pos_x != 0 && matrix.selection_begin_pos_y != 0 && matrix.selection_width != 0 && matrix.selection_height != 0 {
		gfx.draw_rect_filled(matrix.selection_begin_pos_x, matrix.selection_begin_pos_y, matrix.selection_width, matrix.selection_height, gx.rgba(224, 63, 222, 80))
	}
}

fn (mut matrix Matrix) resolve_selected_cells(ops op.Stack) {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	selection := gg.Rect{ x: matrix.selection_begin_pos_x, y: matrix.selection_begin_pos_y, width: matrix.selection_width, height: matrix.selection_height }
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			cell := gg.Rect{ x: posx + (x*cell_width), y: posy + (y*cell_height), width: cell_width, height: cell_height }
			if overlaps(selection, cell) {
				if x == 0 && y == 0 { println("---------------\nselection: ${selection}, cell: ${cell}") }
			}
			//if overlaps(selection, cell) { println("X: ${cell.x}, Y: ${cell.y}") }
		}
	}
}

fn (mut matrix Matrix) on_event(ops op.Stack, e &gg.Event) bool {
	match e.typ {
		.mouse_down {
			if !matrix.contains_point(ops, e.mouse_x / gg.dpi_scale(), e.mouse_y / gg.dpi_scale()) { return false }
			match e.mouse_button {
				.right {
					sapp.set_mouse_cursor(sapp.MouseCursor.resize_all)
					matrix.is_dragging = true
				}
				.left {
					sapp.set_mouse_cursor(sapp.MouseCursor.crosshair)
					matrix.is_selecting = true
					matrix.selection_begin_pos_x = e.mouse_x / gg.dpi_scale()
					matrix.selection_begin_pos_y = e.mouse_y / gg.dpi_scale()
				}
				else {}
			}
		}
		.mouse_move {
			if matrix.is_dragging {
				matrix.position_x += (e.mouse_dx / gg.dpi_scale())
				matrix.position_y += (e.mouse_dy / gg.dpi_scale())
				return true
			}

			if matrix.is_selecting {
				matrix.selection_width += (e.mouse_dx / gg.dpi_scale())
				matrix.selection_height += (e.mouse_dy / gg.dpi_scale())
			}
		}
		.mouse_up {
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
			matrix.is_dragging = false
			if matrix.is_selecting {
				matrix.is_selecting = false
				matrix.resolve_selected_cells(ops)
				matrix.selection_width, matrix.selection_height = 0, 0
			}
		}
		else {}
	}
	return false
}

/*
type Rectangle struct {
	Min, Max f32.Point
}

func (r *Rectangle) SwappedBounds() Rectangle {
	min, max := r.Min, r.Max
	if max.X < min.X {
		max.X = r.Min.X
		min.X = r.Max.X
	}
	if max.Y < min.Y {
		max.Y = r.Min.Y
		min.Y = r.Max.Y
	}
	return Rectangle{Min: min, Max: max}
}

func (r *Rectangle) Empty() bool {
	return r.Min.X >= r.Max.X || r.Min.Y >= r.Max.Y
}

// Overlaps reports whether r and s have a non-empty intersection.
func (r *Rectangle) Overlaps(s Rectangle) bool {
	return !r.Empty() && !s.Empty() &&
		r.Min.X < s.Max.X && s.Min.X < r.Max.X &&
		r.Min.Y < s.Max.Y && s.Min.Y < r.Max.Y
}

func (r *Rectangle) ConvertToPixelspace(dp func(v unit.Dp) int) image.Rectangle {
	return image.Rect(dp(unit.Dp(r.Min.X)), dp(unit.Dp(r.Min.Y)), dp(unit.Dp(r.Max.X)), dp(unit.Dp(r.Max.Y)))
}
*/

fn overlaps(r1 gg.Rect, r2 gg.Rect) bool {
	return r1.x < r2.width && r2.x < r1.width && r1.y < r2.height && r2.y < r1.height
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

