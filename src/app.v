module main

import op
import gg
import gx
import widgets

const (
	win_width  = 800
	win_height = 600

	cell_width = 80
	cell_height = 20
)

struct App {
mut:
	gg    &gg.Context = unsafe { nil }

	ops op.Stack
	canvas widgets.Canvas
	matrix_x_pos f32
	matrix_y_pos f32
	is_dragging bool
	is_selecting bool
	selection_start_pos_x f32
	selection_start_pos_y f32
	selection_pending_pos_x f32
	selection_pending_pos_y f32
}

fn main() {
	mut app := &App{
		gg: 0
		canvas: widgets.Canvas.new()
		matrix_x_pos: 20
		matrix_y_pos: 20
	}
	app.gg = gg.new_context(
		bg_color: gx.rgb(18, 18, 18)
		width: win_width
		height: win_height
		create_window: true
		window_title: 'starcloud'
		frame_fn: frame
		event_fn: on_event
		user_data: app
	)
	app.gg.run()
}

fn frame(mut app &App) {
	app.gg.begin()
	app.gg.show_fps()
	app.canvas.draw(mut app.ops, mut app.gg)
	// app.toolbar.draw(mut app.ops, app.gg)
	app.gg.end()
}

fn on_event(e &gg.Event, mut app &App) {
	app.canvas.on_event(e, mut app.ops)
}

