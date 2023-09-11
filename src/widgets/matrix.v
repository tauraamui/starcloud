module widgets

import gg
import gx
import op

const (
	cell_width = 80
	cell_height = 20
)

struct Matrix {
	position_x f32
	position_y f32
	cols int
	rows int
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
}

fn (matrix Matrix) clip(posx f32, posy f32, gfx &gg.Context) {
	width := matrix.cols * cell_width
	height := matrix.rows * cell_height
	gfx.scissor_rect(int(posx), int(posy), width, height)
}

fn (matrix Matrix) noclip(gfx &gg.Context) {
	gfx.scissor_rect(0,0,0,0)
}

