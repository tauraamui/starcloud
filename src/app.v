module main

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
		event_fn: app.canvas.on_event
		user_data: app
	)
	app.gg.run()
}

fn frame(mut app &App) {
	app.gg.begin()
	app.gg.show_fps()
	app.canvas.draw(app.gg)
	app.gg.end()
}

fn (mut app App) draw() {
	for x in 0..15 {
		for y in 0..100 {
			app.gg.draw_rect_filled(app.matrix_x_pos + (x*cell_width), app.matrix_y_pos + (y*cell_height), cell_width, cell_height, gx.rgb(245, 245, 245))
			app.gg.draw_rect_empty(app.matrix_x_pos + (x*cell_width), app.matrix_y_pos + (y*cell_height), cell_width, cell_height, gx.rgb(55, 55, 55))
		}
	}

	if app.selection_start_pos_x != 0 && app.selection_start_pos_y != 0 && app.selection_pending_pos_x != 0 && app.selection_pending_pos_y != 0 {
		app.gg.draw_rect_filled(app.selection_start_pos_x, app.selection_start_pos_y, app.selection_pending_pos_x-app.selection_start_pos_x, app.selection_pending_pos_y-app.selection_start_pos_y, gx.rgba(224, 63, 222, 80))
	}
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.mouse_move {
			if app.is_dragging {
				app.matrix_x_pos += e.mouse_dx
				app.matrix_y_pos += e.mouse_dy
			}
			if app.is_selecting {
				app.selection_pending_pos_x = e.mouse_x
				app.selection_pending_pos_y = e.mouse_y
			}
		}
		.mouse_down {
			if e.mouse_button == gg.MouseButton.right  { app.is_dragging = true }
			if e.mouse_button == gg.MouseButton.left {
				app.is_dragging = false
				app.is_selecting = true
				app.selection_start_pos_x = e.mouse_x
				app.selection_start_pos_y = e.mouse_y
			}
		}
		.mouse_up {
			app.is_dragging = false
			app.is_selecting = false
			app.selection_start_pos_x = 0
			app.selection_start_pos_y = 0
			app.selection_pending_pos_x = 0
			app.selection_pending_pos_y = 0
		}
		else {}
	}
}
