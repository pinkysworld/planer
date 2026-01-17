extends Node2D
## PlanerGraphics - Procedural pixel art generator for Der Planer style graphics

class_name PlanerGraphics

# Color palette - Authentic Der Planer colors from screenshots
const WALL_COLOR: Color = Color(0.72, 0.75, 0.78)  # Light gray concrete
const WALL_SHADOW: Color = Color(0.52, 0.55, 0.58)
const FLOOR_COLOR: Color = Color(0.48, 0.52, 0.56)  # Gray floor
const DOOR_FRAME: Color = Color(0.25, 0.28, 0.32)
const DOOR_COLOR: Color = Color(0.45, 0.68, 0.82)  # Cyan door panels
const DOOR_HIGHLIGHT: Color = Color(0.65, 0.85, 0.95)
const WINDOW_COLOR: Color = Color(0.15, 0.22, 0.30)
const WINDOW_GLASS: Color = Color(0.35, 0.52, 0.68)
const HIGHLIGHT: Color = Color(0.85, 0.90, 0.95)
const SHADOW: Color = Color(0.18, 0.20, 0.24)

## Creates a door sprite with authentic Der Planer style
static func create_door_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(32, 64, false, Image.FORMAT_RGBA8)

	# Fill with dark door frame
	img.fill(DOOR_FRAME)

	# Main door panel with gradient effect
	for y in range(3, 61):
		for x in range(3, 29):
			# Vertical gradient for 3D effect
			var gradient = 1.0 - (float(y - 3) / 58.0) * 0.15
			var door_shade = Color(
				DOOR_COLOR.r * gradient,
				DOOR_COLOR.g * gradient,
				DOOR_COLOR.b * gradient
			)
			img.set_pixel(x, y, door_shade)

	# Door window (upper third) - rounded corners
	for y in range(8, 28):
		for x in range(7, 25):
			# Skip corners for rounded effect
			if (y < 10 and (x < 9 or x > 22)) or (y > 25 and (x < 9 or x > 22)):
				continue
			img.set_pixel(x, y, WINDOW_COLOR)

	# Window glass reflection (top)
	for y in range(9, 14):
		for x in range(8, 24):
			var alpha = (14 - y) / 5.0
			img.set_pixel(x, y, WINDOW_GLASS.lerp(HIGHLIGHT, alpha * 0.6))

	# Door panels (decorative rectangles)
	# Upper panel
	for y in range(32, 38):
		for x in range(7, 25):
			if x == 7 or x == 24 or y == 32 or y == 37:
				img.set_pixel(x, y, SHADOW)
			else:
				img.set_pixel(x, y, DOOR_HIGHLIGHT)

	# Lower panel
	for y in range(42, 48):
		for x in range(7, 25):
			if x == 7 or x == 24 or y == 42 or y == 47:
				img.set_pixel(x, y, SHADOW)
			else:
				img.set_pixel(x, y, DOOR_HIGHLIGHT)

	# Door handle (brass/gold colored)
	var handle_color = Color(0.85, 0.75, 0.35)
	for y in range(30, 35):
		for x in range(25, 28):
			img.set_pixel(x, y, handle_color)
	# Handle highlight
	img.set_pixel(25, 30, Color(1, 0.95, 0.7))
	img.set_pixel(25, 31, Color(1, 0.95, 0.7))

	# Right and bottom shadows for 3D depth
	for y in range(3, 61):
		img.set_pixel(28, y, SHADOW)
		img.set_pixel(27, y, SHADOW.lerp(DOOR_COLOR, 0.5))
	for x in range(3, 29):
		img.set_pixel(x, 60, SHADOW)
		img.set_pixel(x, 59, SHADOW.lerp(DOOR_COLOR, 0.5))

	# Left and top highlights
	for y in range(3, 61):
		img.set_pixel(3, y, DOOR_HIGHLIGHT)
	for x in range(3, 29):
		img.set_pixel(x, 3, DOOR_HIGHLIGHT)

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a wall section with realistic texture
static func create_wall_texture(width: int, height: int) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Base wall color
	img.fill(WALL_COLOR)

	# Create concrete/plaster texture with subtle noise
	for y in range(height):
		for x in range(width):
			# Add subtle random variation
			var noise_val = (hash(Vector2i(x / 4, y / 4)) % 20) / 200.0
			var textured = Color(
				WALL_COLOR.r + noise_val - 0.05,
				WALL_COLOR.g + noise_val - 0.05,
				WALL_COLOR.b + noise_val - 0.05
			)
			img.set_pixel(x, y, textured)

	# Add horizontal lines for wall panels
	for y in range(0, height, 60):
		for x in range(width):
			if y < height:
				img.set_pixel(x, y, WALL_SHADOW)
				if y + 1 < height:
					img.set_pixel(x, y + 1, WALL_COLOR.lightened(0.1))

	# Add subtle vertical divisions
	for x in range(0, width, 80):
		for y in range(height):
			if x < width:
				img.set_pixel(x, y, WALL_SHADOW.lerp(WALL_COLOR, 0.7))

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a floor texture with tile pattern
static func create_floor_texture(width: int, height: int) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Base floor color
	img.fill(FLOOR_COLOR)

	# Create tiles with grout lines
	var tile_size = 32
	for tile_y in range(0, height, tile_size):
		for tile_x in range(0, width, tile_size):
			# Draw each tile with subtle variation
			for y in range(tile_y + 1, min(tile_y + tile_size - 1, height)):
				for x in range(tile_x + 1, min(tile_x + tile_size - 1, width)):
					# Add slight variation to each tile
					var var_val = (hash(Vector2i(tile_x / tile_size, tile_y / tile_size)) % 15) / 300.0
					var tile_color = Color(
						FLOOR_COLOR.r + var_val,
						FLOOR_COLOR.g + var_val,
						FLOOR_COLOR.b + var_val
					)
					img.set_pixel(x, y, tile_color)

					# Add subtle highlight on left/top of tile
					if x == tile_x + 1 or y == tile_y + 1:
						img.set_pixel(x, y, tile_color.lightened(0.08))

			# Draw grout lines (darker)
			for y in range(tile_y, min(tile_y + tile_size, height)):
				if tile_x < width:
					img.set_pixel(tile_x, y, SHADOW)
			for x in range(tile_x, min(tile_x + tile_size, width)):
				if tile_y < height:
					img.set_pixel(x, tile_y, SHADOW)

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates an elevator sprite
static func create_elevator_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(48, 80, false, Image.FORMAT_RGBA8)

	# Elevator frame
	img.fill(DOOR_FRAME)

	# Elevator doors (double)
	for y in range(4, 76):
		# Left door
		for x in range(4, 22):
			img.set_pixel(x, y, Color(0.65, 0.7, 0.75))
		# Right door
		for x in range(26, 44):
			img.set_pixel(x, y, Color(0.65, 0.7, 0.75))

	# Center gap
	for y in range(4, 76):
		img.set_pixel(23, y, SHADOW)
		img.set_pixel(24, y, SHADOW)
		img.set_pixel(25, y, SHADOW)

	# Elevator buttons panel
	for y in range(20, 60):
		for x in range(24, 44):
			if y > 22 and y < 28:
				img.set_pixel(x, y, Color(0.8, 0.3, 0.3))  # Up button
			elif y > 32 and y < 38:
				img.set_pixel(x, y, Color(0.3, 0.8, 0.3))  # Down button

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a character sprite (businessman)
static func create_character_sprite() -> AnimatedSprite2D:
	var anim_sprite = AnimatedSprite2D.new()
	var sprite_frames = SpriteFrames.new()

	# Idle frame
	var idle_img = _create_character_frame(0)
	var idle_tex = ImageTexture.create_from_image(idle_img)
	sprite_frames.add_frame("idle", idle_tex)

	# Walk frames
	sprite_frames.add_animation("walk")
	sprite_frames.set_animation_loop("walk", true)
	sprite_frames.set_animation_speed("walk", 8.0)

	for i in range(4):
		var walk_img = _create_character_frame(i)
		var walk_tex = ImageTexture.create_from_image(walk_img)
		sprite_frames.add_frame("walk", walk_tex)

	anim_sprite.sprite_frames = sprite_frames
	anim_sprite.animation = "idle"
	anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return anim_sprite

static func _create_character_frame(frame: int) -> Image:
	var img = Image.create(24, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Transparent

	# Body - dark suit
	var suit_color = Color(0.2, 0.2, 0.3)
	var skin_color = Color(0.95, 0.8, 0.7)
	var shirt_color = Color(0.9, 0.9, 1.0)
	var tie_color = Color(0.6, 0.2, 0.2)

	# Head
	for y in range(4, 10):
		for x in range(8, 16):
			img.set_pixel(x, y, skin_color)

	# Hair
	for y in range(4, 7):
		for x in range(8, 16):
			img.set_pixel(x, y, Color(0.3, 0.2, 0.15))

	# Torso - suit
	for y in range(10, 22):
		for x in range(7, 17):
			img.set_pixel(x, y, suit_color)

	# Shirt (collar area)
	for y in range(10, 13):
		for x in range(10, 14):
			img.set_pixel(x, y, shirt_color)

	# Tie
	for y in range(11, 18):
		img.set_pixel(12, y, tie_color)

	# Legs
	var leg_offset = 0
	if frame == 1 or frame == 3:
		leg_offset = 2 if frame == 1 else -2

	# Left leg
	for y in range(22, 31):
		for x in range(8, 11):
			img.set_pixel(x + (leg_offset if frame % 2 == 1 else 0), y, Color(0.15, 0.15, 0.2))

	# Right leg
	for y in range(22, 31):
		for x in range(13, 16):
			img.set_pixel(x + (-leg_offset if frame % 2 == 1 else 0), y, Color(0.15, 0.15, 0.2))

	# Shoes
	for x in range(7, 11):
		img.set_pixel(x, 30, Color(0.1, 0.1, 0.1))
	for x in range(13, 17):
		img.set_pixel(x, 30, Color(0.1, 0.1, 0.1))

	# Briefcase (in hand)
	if frame == 0 or frame == 2:
		for y in range(16, 20):
			for x in range(16, 20):
				img.set_pixel(x, y, Color(0.4, 0.3, 0.2))

	return img

## Creates a window sprite
static func create_window_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(32, 48, false, Image.FORMAT_RGBA8)

	# Window frame (dark gray)
	img.fill(DOOR_FRAME)

	# Glass panes with realistic sky gradient
	for y in range(4, 44):
		for x in range(4, 28):
			# Sky gradient (lighter at top)
			var gradient = float(y - 4) / 40.0
			var sky_color = Color(
				0.50 + gradient * 0.15,
				0.60 + gradient * 0.15,
				0.80 + gradient * 0.10
			)

			# Add slight color variation for atmosphere
			var noise = (hash(Vector2i(x / 2, y / 2)) % 10) / 100.0
			sky_color = Color(
				sky_color.r + noise,
				sky_color.g + noise,
				sky_color.b + noise
			)
			img.set_pixel(x, y, sky_color)

	# Window dividers (cross pattern)
	for y in range(4, 44):
		img.set_pixel(15, y, DOOR_FRAME)
		img.set_pixel(16, y, DOOR_FRAME)
		img.set_pixel(17, y, DOOR_FRAME)
	for x in range(4, 28):
		img.set_pixel(x, 23, DOOR_FRAME)
		img.set_pixel(x, 24, DOOR_FRAME)
		img.set_pixel(x, 25, DOOR_FRAME)

	# Cloud visible through window (upper left pane)
	for y in range(8, 16):
		for x in range(7, 14):
			if (x - 10) * (x - 10) + (y - 12) * (y - 12) < 18:
				img.set_pixel(x, y, Color(0.88, 0.90, 0.95))

	# Bright reflections (highlights)
	for y in range(5, 10):
		for x in range(5, 12):
			if (x - 8) * (x - 8) + (y - 7) * (y - 7) < 8:
				img.set_pixel(x, y, Color(0.95, 0.98, 1.0))

	# Window sill (bottom edge)
	for x in range(0, 32):
		img.set_pixel(x, 45, DOOR_FRAME.lightened(0.1))
		img.set_pixel(x, 46, DOOR_FRAME.lightened(0.15))
		img.set_pixel(x, 47, DOOR_FRAME.lightened(0.2))

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a room sign
static func create_room_sign(text: String) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(64, 16, false, Image.FORMAT_RGBA8)

	# Sign background
	img.fill(Color(0.85, 0.8, 0.7))

	# Border
	for x in range(64):
		img.set_pixel(x, 0, DOOR_FRAME)
		img.set_pixel(x, 15, DOOR_FRAME)
	for y in range(16):
		img.set_pixel(0, y, DOOR_FRAME)
		img.set_pixel(63, y, DOOR_FRAME)

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	# Add text label
	var label = Label.new()
	label.text = text
	label.position = Vector2(-32, -8)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.3))
	sprite.add_child(label)

	return sprite

## Creates office furniture
static func create_furniture(type: String) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img: Image

	match type:
		"desk":
			img = _create_desk()
		"plant":
			img = _create_plant()
		"filing_cabinet":
			img = _create_filing_cabinet()
		_:
			img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.5, 0.5, 0.5))

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

static func _create_desk() -> Image:
	var img = Image.create(48, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var wood_color = Color(0.55, 0.35, 0.2)

	# Desktop
	for y in range(8, 14):
		for x in range(4, 44):
			img.set_pixel(x, y, wood_color)

	# Legs
	for y in range(14, 30):
		for x in range(6, 10):
			img.set_pixel(x, y, wood_color)
		for x in range(38, 42):
			img.set_pixel(x, y, wood_color)

	return img

static func _create_plant() -> Image:
	var img = Image.create(24, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Pot
	for y in range(24, 32):
		for x in range(8, 16):
			img.set_pixel(x, y, Color(0.6, 0.3, 0.2))

	# Plant leaves
	var leaf_color = Color(0.2, 0.6, 0.3)
	for y in range(8, 24):
		for x in range(6, 18):
			if abs(x - 12) < (24 - y) / 2:
				img.set_pixel(x, y, leaf_color)

	return img

static func _create_filing_cabinet() -> Image:
	var img = Image.create(24, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var metal_color = Color(0.6, 0.6, 0.65)

	# Cabinet body
	for y in range(4, 40):
		for x in range(4, 20):
			img.set_pixel(x, y, metal_color)

	# Drawer lines
	for d in [12, 20, 28]:
		for x in range(4, 20):
			img.set_pixel(x, d, SHADOW)

	# Handles
	for d in [8, 16, 24, 32]:
		for x in range(10, 14):
			img.set_pixel(x, d, Color(0.3, 0.3, 0.3))

	return img
