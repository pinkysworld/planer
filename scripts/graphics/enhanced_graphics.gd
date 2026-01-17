extends Node
## EnhancedGraphics - Enhanced Der Planer style graphics with textures

class_name EnhancedGraphics

# Textures are now cached via TextureCache autoload for better performance

# Enhanced color palette with gradients
const WALL_LIGHT: Color = Color(0.6, 0.68, 0.75)
const WALL_MID: Color = Color(0.5, 0.58, 0.65)
const WALL_DARK: Color = Color(0.4, 0.48, 0.55)
const FLOOR_LIGHT: Color = Color(0.55, 0.6, 0.65)
const FLOOR_DARK: Color = Color(0.45, 0.5, 0.55)
const DOOR_CYAN: Color = Color(0.4, 0.75, 0.85)
const DOOR_DARK: Color = Color(0.3, 0.55, 0.65)
const WOOD_COLOR: Color = Color(0.6, 0.4, 0.25)
const METAL_COLOR: Color = Color(0.65, 0.65, 0.7)

## Creates an enhanced door with gradient and detail
static func create_enhanced_door() -> Control:
	var door_container = Control.new()
	door_container.custom_minimum_size = Vector2(48, 96)

	# Door frame (dark)
	var frame = ColorRect.new()
	frame.size = Vector2(48, 96)
	frame.color = Color(0.25, 0.3, 0.35)
	door_container.add_child(frame)

	# Door panel with gradient effect
	for i in range(42):
		var stripe = ColorRect.new()
		stripe.position = Vector2(3, 3 + i)
		stripe.size = Vector2(42, 1)
		# Create vertical gradient
		var gradient_factor = float(i) / 42.0
		stripe.color = DOOR_CYAN.lerp(DOOR_DARK, gradient_factor * 0.3)
		door_container.add_child(stripe)

	# Door window with reflection
	var window_bg = ColorRect.new()
	window_bg.position = Vector2(10, 15)
	window_bg.size = Vector2(28, 28)
	window_bg.color = Color(0.15, 0.25, 0.35)
	door_container.add_child(window_bg)

	# Window reflection (lighter top)
	var reflection = ColorRect.new()
	reflection.position = Vector2(12, 17)
	reflection.size = Vector2(24, 8)
	reflection.color = Color(0.5, 0.7, 0.9, 0.5)
	door_container.add_child(reflection)

	# Door handle (metallic)
	var handle_shadow = ColorRect.new()
	handle_shadow.position = Vector2(37, 50)
	handle_shadow.size = Vector2(6, 10)
	handle_shadow.color = Color(0.2, 0.2, 0.2)
	door_container.add_child(handle_shadow)

	var handle = ColorRect.new()
	handle.position = Vector2(36, 49)
	handle.size = Vector2(6, 10)
	handle.color = Color(0.85, 0.8, 0.4)
	door_container.add_child(handle)

	# Handle highlight
	var handle_light = ColorRect.new()
	handle_light.position = Vector2(36, 49)
	handle_light.size = Vector2(2, 4)
	handle_light.color = Color(1, 0.95, 0.7)
	door_container.add_child(handle_light)

	# Door bottom shadow
	for i in range(42):
		var shadow = ColorRect.new()
		shadow.position = Vector2(3 + i, 90)
		shadow.size = Vector2(1, 3)
		shadow.color = Color(0, 0, 0, 0.3 - (float(i) / 42.0) * 0.2)
		door_container.add_child(shadow)

	return door_container

## Creates enhanced floor with tile pattern
static func create_textured_floor(width: int) -> Control:
	var floor_container = Control.new()
	floor_container.custom_minimum_size = Vector2(width, 80)

	# Base floor
	var base = ColorRect.new()
	base.size = Vector2(width, 80)
	base.color = FLOOR_MID
	floor_container.add_child(base)

	# Tile pattern with shading
	for x in range(0, width, 32):
		for y in range(0, 80, 32):
			# Tile highlight
			var highlight = ColorRect.new()
			highlight.position = Vector2(x + 1, y + 1)
			highlight.size = Vector2(30, 30)
			highlight.color = FLOOR_LIGHT
			floor_container.add_child(highlight)

			# Tile shadow
			var shadow = ColorRect.new()
			shadow.position = Vector2(x + 16, y + 16)
			shadow.size = Vector2(15, 15)
			shadow.color = FLOOR_DARK
			floor_container.add_child(shadow)

			# Tile grout lines
			var line_v = ColorRect.new()
			line_v.position = Vector2(x + 31, y)
			line_v.size = Vector2(1, 32)
			line_v.color = Color(0.3, 0.35, 0.4)
			floor_container.add_child(line_v)

			var line_h = ColorRect.new()
			line_h.position = Vector2(x, y + 31)
			line_h.size = Vector2(32, 1)
			line_h.color = Color(0.3, 0.35, 0.4)
			floor_container.add_child(line_h)

	return floor_container

## Creates textured wall
static func create_textured_wall(width: int, height: int) -> Control:
	var wall_container = Control.new()
	wall_container.custom_minimum_size = Vector2(width, height)

	# Base wall with vertical gradient
	for y in range(height):
		var stripe = ColorRect.new()
		stripe.position = Vector2(0, y)
		stripe.size = Vector2(width, 1)
		var gradient = float(y) / float(height)
		stripe.color = WALL_LIGHT.lerp(WALL_DARK, gradient * 0.4)
		wall_container.add_child(stripe)

	# Add subtle texture pattern
	for x in range(0, width, 8):
		for y in range(0, height, 8):
			if (x + y) % 16 == 0:
				var dot = ColorRect.new()
				dot.position = Vector2(x, y)
				dot.size = Vector2(1, 1)
				dot.color = WALL_DARK
				wall_container.add_child(dot)

	return wall_container

## Creates window with reflections
static func create_detailed_window() -> Control:
	var window_container = Control.new()
	window_container.custom_minimum_size = Vector2(48, 64)

	# Window frame
	var frame = ColorRect.new()
	frame.size = Vector2(48, 64)
	frame.color = Color(0.28, 0.32, 0.36)
	window_container.add_child(frame)

	# Glass with gradient (sky reflection)
	for y in range(60):
		var glass_line = ColorRect.new()
		glass_line.position = Vector2(2, 2 + y)
		glass_line.size = Vector2(44, 1)
		var sky_gradient = float(y) / 60.0
		glass_line.color = Color(0.55 + sky_gradient * 0.15, 0.7 + sky_gradient * 0.1, 0.9, 0.8)
		window_container.add_child(glass_line)

	# Window reflection (bright area at top)
	var reflection = ColorRect.new()
	reflection.position = Vector2(8, 8)
	reflection.size = Vector2(20, 15)
	reflection.color = Color(1, 1, 1, 0.4)
	window_container.add_child(reflection)

	# Window dividers
	var div_h = ColorRect.new()
	div_h.position = Vector2(2, 32)
	div_h.size = Vector2(44, 2)
	div_h.color = Color(0.25, 0.28, 0.32)
	window_container.add_child(div_h)

	var div_v = ColorRect.new()
	div_v.position = Vector2(23, 2)
	div_v.size = Vector2(2, 60)
	div_v.color = Color(0.25, 0.28, 0.32)
	window_container.add_child(div_v)

	return window_container

## Creates info panel with beige background (Der Planer style)
static func create_info_panel(width: int, height: int, title: String) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(width, height)

	# Beige background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.92, 0.85, 0.7)
	style.border_color = Color(0.5, 0.4, 0.3)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	panel.add_theme_stylebox_override("panel", style)

	# Title bar (darker beige)
	var title_bar = ColorRect.new()
	title_bar.size = Vector2(width - 4, 24)
	title_bar.position = Vector2(2, 2)
	title_bar.color = Color(0.85, 0.75, 0.6)
	panel.add_child(title_bar)

	# Title text
	var title_label = Label.new()
	title_label.text = title
	title_label.position = Vector2(10, 4)
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
	title_bar.add_child(title_label)

	return panel

## Creates a desk with computer
static func create_office_desk() -> Control:
	var desk_container = Control.new()
	desk_container.custom_minimum_size = Vector2(96, 64)

	# Desk surface (wood texture)
	var desk = ColorRect.new()
	desk.position = Vector2(0, 32)
	desk.size = Vector2(96, 32)
	desk.color = WOOD_COLOR
	desk_container.add_child(desk)

	# Desk highlight
	var highlight = ColorRect.new()
	highlight.position = Vector2(2, 34)
	highlight.size = Vector2(92, 4)
	highlight.color = Color(0.7, 0.5, 0.35)
	desk_container.add_child(highlight)

	# Computer monitor
	var monitor = ColorRect.new()
	monitor.position = Vector2(30, 8)
	monitor.size = Vector2(36, 28)
	monitor.color = Color(0.85, 0.82, 0.78)
	desk_container.add_child(monitor)

	# Monitor screen
	var screen = ColorRect.new()
	screen.position = Vector2(33, 11)
	screen.size = Vector2(30, 20)
	screen.color = Color(0.15, 0.25, 0.35)
	desk_container.add_child(screen)

	# Screen reflection
	var screen_light = ColorRect.new()
	screen_light.position = Vector2(35, 13)
	screen_light.size = Vector2(12, 8)
	screen_light.color = Color(0.5, 0.7, 0.9, 0.5)
	desk_container.add_child(screen_light)

	# Keyboard
	var keyboard = ColorRect.new()
	keyboard.position = Vector2(35, 38)
	keyboard.size = Vector2(26, 8)
	keyboard.color = Color(0.75, 0.72, 0.68)
	desk_container.add_child(keyboard)

	return desk_container

## Creates a textured door with real wood/metal textures
static func create_textured_door() -> Control:
	var door_container = Control.new()
	door_container.custom_minimum_size = Vector2(48, 96)

	# Door frame (metal texture)
	var frame = TextureRect.new()
	frame.texture = TextureCache.get_metal_texture(48, 96, Color(0.3, 0.32, 0.35))
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_TILE
	frame.size = Vector2(48, 96)
	door_container.add_child(frame)

	# Wood door panel
	var door_panel = TextureRect.new()
	door_panel.texture = TextureCache.get_wood_texture(42, 90, Color(0.55, 0.4, 0.3))
	door_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	door_panel.stretch_mode = TextureRect.STRETCH_TILE
	door_panel.position = Vector2(3, 3)
	door_panel.size = Vector2(42, 90)
	door_container.add_child(door_panel)

	# Glass window
	var window = TextureRect.new()
	window.texture = TextureCache.get_glass_texture(28, 28)
	window.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	window.position = Vector2(10, 15)
	window.size = Vector2(28, 28)
	door_container.add_child(window)

	# Metal handle
	var handle = TextureRect.new()
	handle.texture = TextureCache.get_metal_texture(6, 10, Color(0.85, 0.8, 0.4))
	handle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	handle.position = Vector2(36, 48)
	handle.size = Vector2(6, 10)
	door_container.add_child(handle)

	return door_container

## Creates textured wall with concrete
static func create_textured_wall_with_bitmaps(width: int, height: int) -> Control:
	var wall_container = Control.new()
	wall_container.custom_minimum_size = Vector2(width, height)

	var wall_texture = TextureRect.new()
	wall_texture.texture = TextureCache.get_concrete_texture(width, height, WALL_MID)
	wall_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wall_texture.stretch_mode = TextureRect.STRETCH_TILE
	wall_texture.size = Vector2(width, height)
	wall_container.add_child(wall_texture)

	return wall_container

## Creates tiled floor with ceramic tiles
static func create_tiled_floor(width: int) -> Control:
	var floor_container = Control.new()
	floor_container.custom_minimum_size = Vector2(width, 80)

	# Create tiled pattern
	for x in range(0, width, 32):
		for y in range(0, 80, 32):
			var tile = TextureRect.new()
			tile.texture = TextureCache.get_tile_texture(32, Color(0.88, 0.85, 0.82))
			tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tile.position = Vector2(x, y)
			tile.size = Vector2(32, 32)
			floor_container.add_child(tile)

	return floor_container

## Creates marble floor (luxury)
static func create_marble_floor(width: int) -> Control:
	var floor_container = Control.new()
	floor_container.custom_minimum_size = Vector2(width, 80)

	var marble = TextureRect.new()
	marble.texture = TextureCache.get_marble_texture(width, 80)
	marble.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	marble.stretch_mode = TextureRect.STRETCH_TILE
	marble.size = Vector2(width, 80)
	floor_container.add_child(marble)

	return floor_container

## Creates office desk with wood texture
static func create_textured_desk() -> Control:
	var desk_container = Control.new()
	desk_container.custom_minimum_size = Vector2(96, 64)

	# Wood desk surface
	var desk = TextureRect.new()
	desk.texture = TextureCache.get_wood_texture(96, 32, WOOD_COLOR)
	desk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	desk.position = Vector2(0, 32)
	desk.size = Vector2(96, 32)
	desk_container.add_child(desk)

	# Metal monitor
	var monitor_base = TextureRect.new()
	monitor_base.texture = TextureCache.get_metal_texture(36, 28, Color(0.75, 0.75, 0.75))
	monitor_base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	monitor_base.position = Vector2(30, 8)
	monitor_base.size = Vector2(36, 28)
	desk_container.add_child(monitor_base)

	# Glass screen
	var screen = TextureRect.new()
	screen.texture = TextureCache.get_glass_texture(30, 20, Color(0.2, 0.3, 0.4, 0.9))
	screen.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	screen.position = Vector2(33, 11)
	screen.size = Vector2(30, 20)
	desk_container.add_child(screen)

	return desk_container

## Creates leather office chair
static func create_office_chair() -> Control:
	var chair_container = Control.new()
	chair_container.custom_minimum_size = Vector2(48, 64)

	# Seat (leather)
	var seat = TextureRect.new()
	seat.texture = TextureCache.get_leather_texture(40, 24, Color(0.3, 0.2, 0.15))
	seat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	seat.position = Vector2(4, 24)
	seat.size = Vector2(40, 24)
	chair_container.add_child(seat)

	# Back (leather)
	var back = TextureRect.new()
	back.texture = TextureCache.get_leather_texture(32, 32, Color(0.3, 0.2, 0.15))
	back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	back.position = Vector2(8, 0)
	back.size = Vector2(32, 32)
	chair_container.add_child(back)

	# Base (metal)
	var base = TextureRect.new()
	base.texture = TextureCache.get_metal_texture(48, 12, Color(0.4, 0.4, 0.42))
	base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	base.position = Vector2(0, 52)
	base.size = Vector2(48, 12)
	chair_container.add_child(base)

	return chair_container

## Creates carpet for executive offices
static func create_carpet(width: int, height: int) -> Control:
	var carpet_container = Control.new()
	carpet_container.custom_minimum_size = Vector2(width, height)

	var carpet = TextureRect.new()
	carpet.texture = TextureCache.get_carpet_texture(width, height, Color(0.5, 0.25, 0.2))
	carpet.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	carpet.stretch_mode = TextureRect.STRETCH_TILE
	carpet.size = Vector2(width, height)
	carpet_container.add_child(carpet)

	return carpet_container

## Creates filing cabinet with metal texture
static func create_filing_cabinet() -> Control:
	var cabinet_container = Control.new()
	cabinet_container.custom_minimum_size = Vector2(48, 72)

	var cabinet = TextureRect.new()
	cabinet.texture = TextureCache.get_metal_texture(48, 72, Color(0.55, 0.55, 0.58))
	cabinet.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cabinet.size = Vector2(48, 72)
	cabinet_container.add_child(cabinet)

	# Drawer lines (darker metal)
	for i in range(4):
		var drawer_line = ColorRect.new()
		drawer_line.position = Vector2(0, 18 * i + 17)
		drawer_line.size = Vector2(48, 1)
		drawer_line.color = Color(0.2, 0.2, 0.22)
		cabinet_container.add_child(drawer_line)

	return cabinet_container
