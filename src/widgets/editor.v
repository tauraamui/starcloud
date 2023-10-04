module widgets

import op
import gg
import gx
import draw

struct Area {
	pos  Pt
	size Pt
}

struct Editor {
	area                 Area
	bg_color             gx.Color
	txt_color            gx.Color
	on_value_change_fn   fn (value string, d voidptr) = unsafe { nil }
	user_data            voidptr = unsafe { nil }

mut:
	consume_control_char bool
	active               bool
	line                 Line
}

struct Line {
mut:
	data string
}

fn (editor Editor) draw(ops op.Stack, gfx &gg.Context) {
	posx, posy := ops.offset(editor.area.pos.x, editor.area.pos.y)
	draw.cell(gfx, posx, posy, editor.bg_color, draw.default_cell_border_color)
}

fn (mut editor Editor) on_key_down(key gg.KeyCode, mod gg.Modifier) {
	// TODO:(tauraamui) -> handle control key events
	match key {
		.backspace {
			editor.consume_control_char = true
			editor.backspace()
			return
		}
		else {}
	}
}

fn (mut editor Editor) backspace() {
}

fn (mut editor Editor) on_char(c string) {
	/*
	if matrix.consume_control_char {
		matrix.consume_control_char = false
		return
	}
	x, y := matrix.cell_in_edit_mode.x, matrix.cell_in_edit_mode.y
	if x != -1 && y != -1 {
		matrix.caret_position = matrix.mdata.insert_text_at(x, y, matrix.caret_position, c).len
	}
	*/
	editor.line.insert_text_at(0, c)
	editor.on_value_change_fn(editor.line.data, editor.user_data)
}

fn (mut line Line) insert_text_at(pos int, s string) string {
	if line.data.len == 0 {
		line.data = "${s}"
	} else {
		uline := line.data.runes()
		mut upos := pos
		if upos > uline.len {
			upos = uline.len
		}
		left := uline[..upos].string()
		right := uline[pos..uline.len].string()
		line.data = "${left}${s}${right}"
	}
	return line.data
}

fn (mut line Line) remove_text_at(pos int) string {
	uline := line.data.runes()
	if pos == 0 { return uline.string() }
	left := uline[..pos - 1].string()
	mut right := ""
	if pos < uline.len {
		right = uline[pos..].string()
	}
	line.data = "${left}${right}"
	return line.data
}
