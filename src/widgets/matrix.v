module widgets

import gg
import gx
import op
import sokol.sapp
import time
import math
import data

const (
	cell_width = 80
	cell_height = 20
)

struct Matrix {
mut:
	mdata data.Matrix
	position_x f32
	position_y f32
	time_left_pressed time.Time
	time_since_left_clicked time.Time
	left_down bool
	right_down bool
	is_selecting bool
	selection_area Span
	selected_cells []Pt
	fast_click_count u8
	double_clicked bool
	cell_in_edit_mode Pt
	caret_position int
	consume_control_char bool
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

fn (mut matrix Matrix) draw(mut ops op.Stack, gfx &gg.Context) {
	if matrix.left_down {
		if time.since(matrix.time_left_pressed).milliseconds() >= 100 {
			sapp.set_mouse_cursor(sapp.MouseCursor.crosshair)
		}
	}
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	matrix.clip(posx, posy, gfx) // TODO:(tauraamui) -> expand clip by 1 px to allow for elapsed cell border draws
	defer { matrix.noclip(gfx) }
	for x in 0..matrix.mdata.width {
		for y in 0..matrix.mdata.height {
			if matrix.cell_in_edit_mode.x == x && matrix.cell_in_edit_mode.y == y { continue }
			gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(245, 245, 245))
			gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(115, 115, 115))

			x_offset := 2
			y_offset := (cell_height / 2) - (16 / 2)
			gfx.draw_text_def(int(posx + (x*cell_width))+x_offset, int(posy + (y*cell_height)+y_offset), matrix.mdata.get_value_as_str(x, y))
		}
	}

	for _, cell in matrix.selected_cells {
		x, y := cell.x, cell.y
		gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgba(255, 64, 188, 25))
		gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(255, 64, 188))
	}

	if matrix.cell_in_edit_mode.x > -1 && matrix.cell_in_edit_mode.y > -1 {
		x, y := matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y
		gfx.draw_rect_filled(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(235, 235, 235))
		gfx.draw_rect_empty(posx + (x*cell_width), posy + (y*cell_height), cell_width, cell_height, gx.rgb(115, 115, 115))
		x_offset := 2
		y_offset := (cell_height / 2) - (16 / 2)
		line := matrix.mdata.get_value_as_str(x, y)
		gfx.draw_text_def(int(posx + (x*cell_width))+x_offset, int(posy + (y*cell_height)+y_offset), line)
		mut new_ops := op.Stack{}
		new_ops.push_offset(posx+(x*cell_width), posy+(y*cell_height))
		mut edit_cell_posx, edit_cell_posy := new_ops.offset(3, 1)
		edit_cell_posx += gfx.text_width(line)
		gfx.draw_line(edit_cell_posx, edit_cell_posy, edit_cell_posx, edit_cell_posy+cell_height-3, gx.black)
		new_ops.pop_offset()
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

fn (mut matrix Matrix) resolve_selected_cells(ops op.Stack) {
	selection_area := matrix.selection_area.normalise()
	matrix.selected_cells = []
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	for x in 0..matrix.mdata.width {
		for y in 0..matrix.mdata.height {
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
			return matrix.handle_mouse_down_event(ops, e, scale)
		}
		.mouse_move {
			return matrix.handle_mouse_move_event(ops, e, scale)
		}
		.mouse_up {
			return matrix.handle_mouse_up_event(ops, e, scale)
		}
		else {}
	}
	return false
}

fn (mut matrix Matrix) handle_mouse_down_event(ops op.Stack, e &gg.Event, scale f32) bool {
	match e.mouse_button {
		.right {
			sapp.set_mouse_cursor(sapp.MouseCursor.resize_all)
			matrix.right_down = true
			matrix.left_down = false
			return true
		}
		.left {
			if time.since(matrix.time_since_left_clicked).milliseconds() <= 190 {
				// double clicked handling
				posx, posy := ops.offset(matrix.position_x, matrix.position_y)
				position_within_matrix := widgets.Pt{x: (e.mouse_x / scale) - posx, y: (e.mouse_y / scale) - posy }
				matrix.selected_cells = []
				matrix.cell_in_edit_mode = widgets.Pt{ x: f32(math.floor(position_within_matrix.x / f32(cell_width))), y: f32(math.floor(position_within_matrix.y / f32(cell_height))) }
				matrix.caret_position = matrix.mdata.get_value_as_str(matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y).len
				return true
			}

			posx, posy := ops.offset(matrix.position_x, matrix.position_y)
			position_within_matrix := widgets.Pt{x: (e.mouse_x / scale) - posx, y: (e.mouse_y / scale) - posy }
			pressed_cell := widgets.Pt{ x: f32(math.floor(position_within_matrix.x / f32(cell_width))), y: f32(math.floor(position_within_matrix.y / f32(cell_height))) }
			if pressed_cell.x != matrix.cell_in_edit_mode.x && pressed_cell.y != matrix.cell_in_edit_mode.y {
				matrix.cell_in_edit_mode = widgets.Pt{ x: -1, y: -1 }
			}

			matrix.time_left_pressed = time.now()
			matrix.left_down = true
			matrix.right_down = false
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
	return false
}

fn (mut matrix Matrix) handle_mouse_move_event(ops op.Stack, e &gg.Event, scale f32) bool {
	if matrix.right_down {
		matrix.position_x += (e.mouse_dx / scale)
		matrix.position_y += (e.mouse_dy / scale)
		return true
	}

	if matrix.left_down {
		matrix.is_selecting = true
		matrix.selection_area.max.x += (e.mouse_dx / scale)
		matrix.selection_area.max.y += (e.mouse_dy / scale)
		return true
	}

	return false
}

fn (mut matrix Matrix) handle_mouse_up_event(ops op.Stack, e &gg.Event, scale f32) bool {
	if matrix.left_down {
		sapp.set_mouse_cursor(sapp.MouseCursor.default)
		matrix.left_down = false
		matrix.is_selecting = false
		matrix.resolve_selected_cells(ops)
		matrix.selection_area = Span{ min: Pt{ -1, -1}, max: Pt{ -1, -1 } }
		matrix.time_since_left_clicked = time.now()
	}

	if matrix.right_down {
		matrix.right_down = false
		sapp.set_mouse_cursor(sapp.MouseCursor.default)
	}

	return false
}

fn (mut matrix Matrix) on_key_down(key gg.KeyCode, mod gg.Modifier) {
	x, y := matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y
	if x == -1 && y == -1 {
		return
	}
	// TODO:(tauraamui) -> handle control key events
	match key {
		.backspace {
			matrix.consume_control_char = true
			matrix.backspace(x, y)
			return
		}
		.enter {}
		.escape {}
		.tab {
			// ved.view.insert_text('\t')
		}
		else {}
	}
}

fn (mut matrix Matrix) backspace(cell_x f32, cell_y f32) {
	x, y := matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y
	if x != -1 && y != -1 {
		matrix.caret_position = matrix.mdata.remove_text_at(x, y, matrix.caret_position).len
	}
}

fn (mut matrix Matrix) on_char(c string) {
	if matrix.consume_control_char {
		matrix.consume_control_char
		matrix.consume_control_char = false
		return
	}
	x, y := matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y
	if x != -1 && y != -1 {
		matrix.caret_position = matrix.mdata.insert_text_at(x, y, matrix.caret_position, c).len
	}
}

fn (matrix Matrix) contains_point(ops op.Stack, pt_x f32, pt_y f32) bool {
	area := matrix.area(ops)
	if pt_x > area.x && pt_x < area.x + area.width && pt_y > area.y && pt_y < area.y + area.height { return true }
	return false
}

fn (matrix Matrix) area(ops op.Stack) gg.Rect {
	posx, posy := ops.offset(matrix.position_x, matrix.position_y)
	width := matrix.mdata.width * cell_width
	height := matrix.mdata.height * cell_height
	return gg.Rect{ x: posx, y: posy, width: width, height: height }
}

fn (matrix Matrix) clip(posx f32, posy f32, gfx &gg.Context) {
	width := matrix.mdata.width * cell_width
	height := matrix.mdata.height * cell_height
	gfx.scissor_rect(int(posx), int(posy), width, height)
}

fn (matrix Matrix) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}

