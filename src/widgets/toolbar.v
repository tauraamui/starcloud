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

fn (toolbar Toolbar) clip(posx f32, posy f32, gfx &gg.Context) {
	gfx.scissor_rect(int(posx), int(posy), int(toolbar.area.max.x), int(toolbar.area.max.y))
}

fn (matrix Toolbar) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}
