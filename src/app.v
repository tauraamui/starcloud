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
	toolbar widgets.Toolbar
}

fn main() {
	mut app := &App{
		gg: 0
		canvas: widgets.Canvas.new()
		toolbar: widgets.Toolbar{ area: widgets.Span{ min: widgets.Pt{0, 8}, max: widgets.Pt{250, 31.5} } }
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
	app.gg.scale = gg.dpi_scale()
	win_size := app.gg.window_size()
	app.ops.push_offset((win_size.width / 2) - (app.toolbar.area.max.x / 2), 0)
	app.gg.scissor_rect(0, 0, win_size.width, win_size.height)
	app.toolbar.draw(app.ops, app.gg)
	app.ops.pop_offset()
	app.gg.end()
}

fn on_event(e &gg.Event, mut app &App) {
	app.canvas.on_event(e, mut app.ops)
}

