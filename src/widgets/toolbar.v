module widgets

import op
import gg
import gx

pub struct Toolbar {
pub:
	area Span
}

pub fn (mut toolbar Toolbar) draw(ops op.Stack, gfx &gg.Context) {
	min := toolbar.area.min.offset(ops)
	toolbar.clip(min.x, min.y, gfx)
	defer { toolbar.noclip(gfx) }

	gfx.draw_rounded_rect_filled(min.x, min.y, toolbar.area.max.x, toolbar.area.max.y, 3.9, gx.rgb(7, 7, 7))
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

fn (matrix Toolbar) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}
