module draw

import gg
import gx
import math

pub const (
	cell_width = 80
	cell_height = 20

	default_cell_bg_color = gx.rgb(245, 245, 245)
	default_cell_border_color = gx.rgb(115, 115, 115)

	selected_cell_bg_color = gx.rgba(255, 64, 188, 25)
	selected_cell_border_color = gx.rgb(255, 64, 188)
)

pub fn cell(gfx &gg.Context, x f32, y f32, bg gx.Color, border gx.Color) {
	clip(x, y, gfx)
	defer { noclip(gfx) }
	gfx.draw_rect_filled(x, y, cell_width, cell_height, bg)
	gfx.draw_rect_empty(x, y, cell_width, cell_height, border)
}

pub fn default_cell(gfx &gg.Context, x f32, y f32) {
	cell(gfx, x, y, default_cell_bg_color, default_cell_border_color)
}

pub fn selected_cell(gfx &gg.Context, x f32, y f32) {
	cell(gfx, x, y, selected_cell_bg_color, selected_cell_border_color)
}

fn clip(posx f32, posy f32, gfx &gg.Context) {
	gfx.scissor_rect(int(math.round(posx)), int(math.round(posy)), cell_width, cell_height)
}

fn noclip(gfx &gg.Context) {
	gfx.scissor_rect(0, 0, 0, 0)
}
