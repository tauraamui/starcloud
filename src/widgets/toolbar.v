module widgets

import op
import gg
import gx

pub struct Button {
	area Span
	is_pressed bool
	icon_char string
}

pub fn (button Button) draw(ops op.Stack, gfx &gg.Context) {
	min := button.area.min.offset(ops)
	gfx.draw_rounded_rect_filled(min.x, min.y, button.area.max.x, button.area.max.y, 9, gx.rgb(172, 155, 238))
}

fn (button Button) clip(posx f32, posy f32, gfx &gg.Context) {
	gfx.scissor_rect(int(posx), int(posy), int(button.area.max.x), int(button.area.max.y))
}

fn (button Button) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}

pub struct Toolbar {
pub:
	area Span
mut:
	buttons []Button
}

pub fn Toolbar.new() Toolbar {
	return Toolbar{
		area: widgets.Span{ min: widgets.Pt{0, 8}, max: widgets.Pt{312.5, 38} }
		buttons: [
			Button{ area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } } }
			Button{ area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } } }
			Button{ area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } } }
			Button{ area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } } }
		]
	}
}

pub fn (mut toolbar Toolbar) draw(mut ops op.Stack, mut gfx &gg.Context) {
	min := toolbar.area.min.offset(ops)
	toolbar.clip(min.x, min.y, gfx)
	defer { toolbar.noclip(gfx) }

	gfx.draw_rounded_rect_filled(min.x, min.y, toolbar.area.max.x, toolbar.area.max.y, 8.5, gx.rgb(3, 3, 3))

	ops.push_offset(toolbar.area.min.x, toolbar.area.min.y)
	defer { ops.pop_offset() }
	for i, b in toolbar.buttons {
		ops.push_offset((i*b.area.max.x)+((i+1)*5), (toolbar.area.max.y / 2) - (b.area.max.y / 2))
		b.draw(ops, gfx)
		ops.pop_offset()
	}
}

pub fn(mut toolbar Toolbar) on_event(ops op.Stack, e &gg.Event) bool {
	match e.typ {
		.mouse_down {
			min := toolbar.area.min.offset(ops)
			return contains_point(min, toolbar.area.max, Pt{ x: e.mouse_x / gg.dpi_scale(), y: e.mouse_y / gg.dpi_scale() })
		}
		else {}
	}
	return false
}

fn contains_point(min Pt, max Pt, pt Pt) bool {
	if pt.x > min.x && pt.x < min.x + max.x && pt.y > min.y && pt.y < min.y + max.y { return true }
	return false
}


fn (toolbar Toolbar) clip(posx f32, posy f32, gfx &gg.Context) {
	gfx.scissor_rect(int(posx), int(posy), int(toolbar.area.max.x), int(toolbar.area.max.y))
}

fn (toolbar Toolbar) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}
