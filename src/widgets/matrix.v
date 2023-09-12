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
	selection_area Span

	selected_cells []Cell
}

struct Pt {
mut:
	x f32
	y f32
}

struct Span {
mut:
	min Pt
	max Pt
}

fn (span Span) normalise() Span {
	mut min, mut max := span.min, span.max
	if max.x < min.x {
		max.x = span.min.x
		min.x = span.max.x
	}

	if max.y < min.y {
		max.y = span.min.y
		min.y = span.max.y
	}
	return Span{ min: min, max: max }
}

fn (span Span) empty() bool {
	return span.min.x >= span.max.x || span.min.y >= span.max.y
}

struct Cell {
	x int
	y int
}

fn (matrix Matrix) draw(ops op.Stack, gfx &gg.Context) {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	matrix.clip(posx, posy, gfx)
	defer { matrix.noclip(gfx) }
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(245, 245, 245))
			gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgba(115, 115, 115, 100))
			for _, cell in matrix.selected_cells {
				if cell.x == x || cell.y == y {
					gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(255, 115, 115))
					break
				}
			}
		}
	}

	selection_area := matrix.selection_area.normalise()
	if !selection_area.empty() {
		gfx.draw_rect_filled(selection_area.min.x, selection_area.min.y, selection_area.max.x-selection_area.min.x, selection_area.max.y-selection_area.min.y, gx.rgba(224, 63, 222, 80))
	}
}

fn (mut matrix Matrix) resolve_selected_cells(ops op.Stack) {
	/*
	matrix.selected_cells = []
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	selection := gg.Rect{ x: matrix.selection_begin_pos_x, y: matrix.selection_begin_pos_y, width: matrix.selection_width, height: matrix.selection_height }
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			cell := gg.Rect{ x: posx + (x*cell_width), y: posy + (y*cell_height), width: cell_width, height: cell_height }
			if overlaps(selection, cell) {
				matrix.selected_cells << Cell{x: x, y: y}
			}
		}
	}
	*/
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
					matrix.selection_area = Span{
						min: Pt{
							x: e.mouse_x / gg.dpi_scale(),
							y: e.mouse_y / gg.dpi_scale()
						},
						max: Pt{
							x: e.mouse_x / gg.dpi_scale(),
							y: e.mouse_y / gg.dpi_scale()
						}
					}
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
				matrix.selection_area.max.x += (e.mouse_dx / gg.dpi_scale())
				matrix.selection_area.max.y += (e.mouse_dy / gg.dpi_scale())
			}
		}
		.mouse_up {
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
			matrix.is_dragging = false
			if matrix.is_selecting {
				matrix.is_selecting = false
				matrix.resolve_selected_cells(ops)
				println(matrix.selection_area.normalise())
				matrix.selection_area = Span{}
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

fn overlaps(r gg.Rect, s gg.Rect) bool {
	return false
	/*
	nr := normalise_bounds(r)
	ns := normalise_bounds(s)
	return 
		r.x < s.x+s.width && s.x < r.x+r.width &&
		r.y < s.y+s.height && s.y < r.y+r.height
		r.x < s.x+s.width && s.x < r.x+r.width &&
		r.y < s.height && s.y < r.height
	*/
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

