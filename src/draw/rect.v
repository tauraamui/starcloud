module draw

import gg
import gx

pub fn rect(gfx &gg.Context, x f32, y f32, width f32, height f32, bg gx.Color) {
	gfx.draw_rect_filled(x, y, width, height, bg)
}
