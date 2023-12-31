module widgets

import op
import gg
import gx
import assets
import sokol.sapp

const (
	mouse_pointer_icon_width = 17
	mouse_pointer_icon_height = 17
)

pub struct Button {
	area Span
	icon Icon
mut:
	is_pressed bool
	is_hovered_over bool
}

pub fn (button Button) draw(ops op.Stack, gfx &gg.Context, active bool) {
	min := button.area.min.offset(ops)
	render_fn := if button.is_pressed { gfx.draw_rounded_rect_empty } else { gfx.draw_rounded_rect_filled }
	color := if active { gx.rgb(172, 155, 238) } else { if button.is_pressed { gx.rgb(172, 155, 238) } else { gx.rgba(172, 155, 238, 110) } }
	render_fn(min.x, min.y, button.area.max.x, button.area.max.y, 9, color)
	button.icon.draw(ops, gfx, min, button.area.max, active)
}

struct Icon {
	active_id int
	inactive_id int
	width f32
	height f32
}

fn (icon Icon) draw(ops op.Stack, gfx &gg.Context, min Pt, max Pt, active bool) {
	// NOTE:(tauraamui) -> not really sure what I am doing here,
	//                     I think I am summing an alpha color shaded
	//                     copy of the icon ontop of the black base, it's
	//                     not perfect, will do for now
	icon_id := if active { icon.active_id } else { icon.inactive_id }
	gfx.draw_image_with_config(gg.DrawImageConfig{
		img_id: icon_id,
		img_rect: gg.Rect{
			x: min.x + ((max.x / 2) - (icon.width / 1.6)),
			y: min.y + ((max.y / 2) - (icon.height / 1.8)),
			width: icon.width, height: icon.height
		},
		color: gx.rgb(255, 190, 190)
	})
}

fn (mut button Button) on_event(ops op.Stack, e &gg.Event, id int, update_active fn(int), active bool) bool {
	min := button.area.min.offset(ops)
	match e.typ {
		.mouse_down {
			if e.mouse_button == gg.MouseButton.left {
				if contains_point(min, button.area.max, Pt{ x: e.mouse_x / gg.dpi_scale(), y: e.mouse_y / gg.dpi_scale() }) {
					if active { return false }
					sapp.set_mouse_cursor(sapp.MouseCursor.pointing_hand)
					button.is_pressed = true
					return true
				}
			}
		}
		.mouse_move {
			if button.is_pressed { return true }
			if contains_point(min, button.area.max, Pt{ x: e.mouse_x / gg.dpi_scale(), y: e.mouse_y / gg.dpi_scale() }) {
				button.is_hovered_over = true
				if !active { sapp.set_mouse_cursor(sapp.MouseCursor.pointing_hand) }
				return false
			}

			if button.is_hovered_over {
				button.is_hovered_over = false
				sapp.set_mouse_cursor(sapp.MouseCursor.default)
			}
		}
		.mouse_up {
			sapp.set_mouse_cursor(sapp.MouseCursor.default)
			if button.is_pressed {
				button.is_pressed = false
				if contains_point(min, button.area.max, Pt{ x: e.mouse_x / gg.dpi_scale(), y: e.mouse_y / gg.dpi_scale() }) {
					update_active(id)
				}
			}
		}
		else {}
	}
	return false
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
	active_button_id int
	buttons []Button
}

pub fn Toolbar.new(ass assets.Assets) Toolbar {
	return Toolbar{
		area: widgets.Span{ min: widgets.Pt{0, 8}, max: widgets.Pt{312.5, 38} }
		buttons: [
			Button{
				area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } },
				icon: Icon{
					active_id: ass.mouse_pointer_icon_id, inactive_id: ass.mouse_pointer_outline_icon_id,
					width: mouse_pointer_icon_width, height: mouse_pointer_icon_height
				}
			}
			Button{
				area: Span{ min: Pt{ 0, 0 }, max: Pt{ x: 30, y: 28 } },
				icon: Icon{
					active_id: ass.mouse_pointer_icon_id, inactive_id: ass.mouse_pointer_outline_icon_id,
					width: mouse_pointer_icon_width, height: mouse_pointer_icon_height
				}
			}
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
	ops.push_offset(5, 5)
	defer { ops.pop_offset() }
	for i, b in toolbar.buttons {
		b.draw(ops, gfx, i == toolbar.active_button_id)
		ops.push_offset((b.area.min.x + b.area.max.x) + 5, 0)
	}
	for i := 0; i < toolbar.buttons.len; i++ {
		ops.pop_offset()
	}
}

pub fn(mut toolbar Toolbar) on_event(mut ops op.Stack, e &gg.Event) bool {
	ops.push_offset(toolbar.area.min.x, toolbar.area.min.y)
	ops.push_offset(5, 5)

	update_active := fn [mut toolbar] (id int) {
		toolbar.active_button_id = id
	}

	mut captured := false
	mut maxi := 0
	for i, mut b in toolbar.buttons {
		captured = b.on_event(ops, e, i, update_active, i == toolbar.active_button_id)
		ops.push_offset((b.area.min.x + b.area.max.x) + 5, 0)
		maxi = i+1
		if captured {
			break
		}
	}
	for _ in 0..maxi {
		ops.pop_offset()
	}
	ops.pop_offset()
	ops.pop_offset()
	if captured { return true }
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
