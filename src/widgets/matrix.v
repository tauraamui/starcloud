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

	selected_cells []Pt
}

pub struct Pt {
pub mut:
	x f32
	y f32
}

pub struct Span {
pub mut:
	min Pt
	max Pt
}

fn (pt Pt) offset(ops op.Stack) Pt {
	offx, offy := ops.offset(pt.x, pt.y)
	return Pt{ x: offx, y: offy }
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

fn (span Span) overlaps(s Span) bool {
	return !span.empty() && !s.empty() &&
		span.min.x < s.max.x && s.min.x < span.max.x &&
		span.min.y < s.max.y && s.min.y < span.max.y
}

struct Cell {
	x int
	y int
}

fn (matrix Matrix) draw(ops op.Stack, gfx &gg.Context) {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	matrix.clip(posx, posy, gfx) // TODO:(tauraamui) -> expand clip by 1 px to allow for elapsed cell border draws
	defer { matrix.noclip(gfx) }
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(245, 245, 245))
			gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(115, 115, 115))
		}
	}

	for _, cell in matrix.selected_cells {
		x, y := cell.x, cell.y
		// draw_rect_empty_with_thickness(gfx, posx + (x*cell_width)-1, posy + (y*cell_height)-1, cell_width+1, cell_height+1, 1, gx.rgb(255, 64, 188))
		gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgba(255, 64, 188, 25))
		gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(255, 64, 188))
	}

	if matrix.is_selecting {
		selection_area := matrix.selection_area.normalise()
		if !selection_area.empty() {
			gfx.draw_rect_filled(selection_area.min.x, selection_area.min.y, selection_area.max.x-selection_area.min.x, selection_area.max.y-selection_area.min.y, gx.rgba(224, 63, 222, 80))
		}
	}
}

fn draw_rect_empty_with_thickness(gfx &gg.Context, x f32, y f32, w f32, h f32, t int, c gx.Color) {
	cfg := gg.PenConfig{
		color: c,
		line_type: .solid,
		thickness: t,
	}
	gfx.draw_line_with_config(x, y, x+w, y, cfg)
	gfx.draw_line_with_config(x+w, y, x+w, y+h, cfg)
	gfx.draw_line_with_config(x+w, y+h, x, y+h, cfg)
	gfx.draw_line_with_config(x, y+h, x, y, cfg)
}


/*
draw_rect_empty(x f32, y f32, w f32, h f32, c gx.Color) {
	if c.a != 255 {
		sgl.load_pipeline(ctx.pipeline.alpha)
	}
	sgl.c4b(c.r, c.g, c.b, c.a)

	sgl.begin_line_strip()
	sgl.v2f(x * ctx.scale, y * ctx.scale)
	sgl.v2f((x + w) * ctx.scale, y * ctx.scale)
	sgl.v2f((x + w) * ctx.scale, (y + h) * ctx.scale)
	sgl.v2f(x * ctx.scale, (y + h) * ctx.scale)
	sgl.v2f(x * ctx.scale, (y - 1) * ctx.scale)
	sgl.end()
}
*/

fn (mut matrix Matrix) resolve_selected_cells(ops op.Stack) {
	selection_area := matrix.selection_area.normalise()
	matrix.selected_cells = []
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	for x in 0..matrix.cols {
		for y in 0..matrix.rows {
			min := Pt{ x: posx + (x*cell_width), y: posy + (y*cell_height) }
			max := Pt{ x: min.x + cell_width, y: min.y + cell_height }
			cell := Span{ min: min, max: max }
			if cell.overlaps(selection_area) {
				matrix.selected_cells << Pt{ x: x, y: y }
			}
		}
	}
}

fn (mut matrix Matrix) on_event(ops op.Stack, e &gg.Event, scale f32) bool {
	match e.typ {
		.mouse_down {
			if !matrix.contains_point(ops, e.mouse_x / scale, e.mouse_y / scale) { return false }
			match e.mouse_button {
				.right {
					sapp.set_mouse_cursor(sapp.MouseCursor.resize_all)
					matrix.is_selecting = false
					matrix.is_dragging = true
					return true
				}
				.left {
					sapp.set_mouse_cursor(sapp.MouseCursor.crosshair)
					matrix.is_selecting = true
					matrix.is_dragging = false
					matrix.selection_area = Span{
						min: Pt{
							x: e.mouse_x / scale,
							y: e.mouse_y / scale
						},
						max: Pt{
							x: e.mouse_x / scale,
							y: e.mouse_y / scale
						}
					}
					return true
				}
				else {}
			}
		}
		.mouse_move {
			if matrix.is_dragging {
				matrix.position_x += (e.mouse_dx / scale)
				matrix.position_y += (e.mouse_dy / scale)
				return true
			}

			if matrix.is_selecting {
				matrix.selection_area.max.x += (e.mouse_dx / scale)
				matrix.selection_area.max.y += (e.mouse_dy / scale)
				return true
			}
		}
		.mouse_up {
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
			matrix.is_dragging = false
			if matrix.is_selecting {
				matrix.is_selecting = false
				matrix.resolve_selected_cells(ops)
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

