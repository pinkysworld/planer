extends Node2D
## PlanerGraphics - Procedural pixel art generator for Der Planer style graphics

class_name PlanerGraphics

# Color palette - Classic Der Planer colors
const WALL_COLOR: Color = Color(0.5, 0.6, 0.7)
const FLOOR_COLOR: Color = Color(0.4, 0.45, 0.5)
const DOOR_FRAME: Color = Color(0.3, 0.35, 0.4)
const DOOR_COLOR: Color = Color(0.55, 0.7, 0.85)
const WINDOW_COLOR: Color = Color(0.2, 0.3, 0.4)
const HIGHLIGHT: Color = Color(0.7, 0.8, 0.9)
const SHADOW: Color = Color(0.2, 0.25, 0.3)

## Creates a door sprite with Der Planer style
static func create_door_sprite() -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(32, 64, false, Image.FORMAT_RGBA8)

	# Fill with door frame
	img.fill(DOOR_FRAME)

	# Main door panel (inset)
	for y in range(2, 62):
		for x in range(2, 30):
			img.set_pixel(x, y, DOOR_COLOR)

	# Door window (upper part)
	for y in range(8, 24):
		for x in range(8, 24):
			img.set_pixel(x, y, WINDOW_COLOR)

	# Window highlight
	for y in range(8, 10):
		for x in range(8, 24):
			img.set_pixel(x, y, HIGHLIGHT)

	# Door handle
	for y in range(32, 36):
		for x in range(24, 28):
			img.set_pixel(x, y, Color(0.8, 0.7, 0.3))

	# Shadows
	for y in range(2, 62):
		img.set_pixel(29, y, SHADOW)
	for x in range(2, 30):
		img.set_pixel(x, 61, SHADOW)

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a wall section
static func create_wall_texture(width: int, height: int) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(WALL_COLOR)

	# Add some texture variation
	for y in range(0, height, 8):
		for x in range(0, width, 8):
			if (x + y) % 16 == 0:
				img.set_pixel(x, y, Color(WALL_COLOR.r * 0.95, WALL_COLOR.g * 0.95, WALL_COLOR.b * 0.95))

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates a floor texture
static func create_floor_texture(width: int, height: int) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(FLOOR_COLOR)

	# Tile pattern
	for y in range(0, height, 16):
		for x in range(0, width, 16):
			# Tile lines
			for i in range(width):
				img.set_pixel(i, y, SHADOW)
			for i in range(height):
				if i < height:
					img.set_pixel(x, i, SHADOW)

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

	# Window frame
	img.fill(DOOR_FRAME)

	# Glass panes
	for y in range(4, 44):
		for x in range(4, 28):
			# Sky/outside color
			var sky_var = (y % 8) / 8.0
			img.set_pixel(x, y, Color(0.6 + sky_var * 0.1, 0.7 + sky_var * 0.1, 0.9))

	# Window divider
	for y in range(4, 44):
		img.set_pixel(16, y, DOOR_FRAME)
	for x in range(4, 28):
		img.set_pixel(x, 24, DOOR_FRAME)

	# Reflections
	for y in range(6, 12):
		for x in range(6, 14):
			img.set_pixel(x, y, Color(1, 1, 1, 0.3))

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
