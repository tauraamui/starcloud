module main

import op
import gg
import gx
import widgets
import assets

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
	assets assets.Assets
	canvas widgets.Canvas
	toolbar widgets.Toolbar
}

fn main() {
	mut app := &App{
		gg: 0
		canvas: widgets.Canvas.new()
	}
	app.gg = gg.new_context(
		bg_color: gx.rgb(30, 30, 30)
		width: win_width
		height: win_height
		create_window: true
		window_title: 'starcloud'
		frame_fn: frame
		event_fn: on_event
		keydown_fn: on_key_down
		char_fn: on_char
		user_data: app
	)
	app.assets = assets.resolve_assets(mut app.gg)
	app.toolbar = widgets.Toolbar.new(app.assets)
	app.gg.run()
}

fn frame(mut app &App) {
	app.gg.begin()
	app.gg.show_fps()
	app.canvas.draw(mut app.ops, mut app.gg)
	app.gg.scale = gg.dpi_scale()
	win_size := app.gg.window_size()
	app.ops.push_offset((win_size.width / 2) - (app.toolbar.area.max.x / 2), 0)
	app.toolbar.draw(mut app.ops, mut app.gg)
	app.ops.pop_offset()
	app.gg.end()
}

fn on_event(e &gg.Event, mut app &App) {
	app.ops.push_offset((gg.window_size().width / 2) - (app.toolbar.area.max.x / 2), 0)
	captured := app.toolbar.on_event(mut app.ops, e)
	app.ops.pop_offset()
	if captured { return }
	app.canvas.on_event(e, mut app.ops)
}

fn on_key_down(key gg.KeyCode, mod gg.Modifier, mut app &App) {
	app.canvas.on_key_down(key, mod)
	app.gg.refresh_ui()
}

fn on_char(c u32, mut app &App) {
	app.canvas.on_char(c)
}

