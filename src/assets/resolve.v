module assets

import gg

const (
	mouse_pointer_icon_img = $embed_file('../icons/mouse-pointer.png')
	mouse_pointer_outline_icon_img = $embed_file('../icons/mouse-pointer-outline.png')
)

pub struct Assets {
pub:
	mouse_pointer_icon_id int
}

pub fn resolve_assets(mut gfx &gg.Context) Assets {
	mut mouse_pointer_icon_img_copy := mouse_pointer_icon_img
	mouse_pointer_icon := gfx.create_image_from_memory(mouse_pointer_icon_img_copy.data(), mouse_pointer_icon_img.len) or {
		println("assets load error: unable to create mouse pointer icon image")
		exit(1)
	}
	return Assets {
		mouse_pointer_icon_id: gfx.cache_image(mouse_pointer_icon)
	}
}

