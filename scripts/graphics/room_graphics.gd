extends Node
## RoomGraphics - Authentic Der Planer room and object pixel art with realistic textures

class_name RoomGraphics

# Color palette for room objects
const DESK_WOOD: Color = Color(0.55, 0.35, 0.20)
const DESK_DARK: Color = Color(0.35, 0.22, 0.12)
const METAL_GRAY: Color = Color(0.65, 0.68, 0.72)
const METAL_DARK: Color = Color(0.45, 0.48, 0.52)
const SCREEN_DARK: Color = Color(0.08, 0.12, 0.16)
const SCREEN_GREEN: Color = Color(0.2, 1.0, 0.3)
const CHAIR_BLUE: Color = Color(0.25, 0.35, 0.55)
const PLANT_GREEN: Color = Color(0.25, 0.55, 0.30)
const PLANT_DARK: Color = Color(0.15, 0.35, 0.20)
const TRUCK_RED: Color = Color(0.85, 0.15, 0.15)
const TRUCK_BODY: Color = Color(0.90, 0.88, 0.85)
const GARAGE_FLOOR: Color = Color(0.42, 0.44, 0.46)
const WALL_LIGHT: Color = Color(0.72, 0.75, 0.78)

## Creates an office desk with computer using photorealistic graphics
static func create_office_desk() -> Node2D:
	# Use photorealistic desk instead
	return PhotorealisticGraphics.create_realistic_office_desk()

## Creates an office chair
static func create_office_chair() -> Node2D:
	var chair_node = Node2D.new()
	var img = Image.create(48, 64, false, Image.FORMAT_RGBA8)

	img.fill(Color(0, 0, 0, 0))  # Transparent

	# Chair back (blue fabric)
	for y in range(8, 35):
		for x in range(12, 36):
			if x == 12 or x == 35 or y == 8 or y == 34:
				img.set_pixel(x, y, CHAIR_BLUE.darkened(0.3))
			else:
				img.set_pixel(x, y, CHAIR_BLUE)

	# Chair seat
	for y in range(35, 45):
		for x in range(8, 40):
			if y == 35 or y == 44 or x == 8 or x == 39:
				img.set_pixel(x, y, CHAIR_BLUE.darkened(0.3))
			else:
				img.set_pixel(x, y, CHAIR_BLUE)

	# Chair legs (metal)
	# Center column
	for y in range(45, 58):
		for x in range(22, 26):
			img.set_pixel(x, y, METAL_GRAY)

	# Wheel base
	for y in range(58, 62):
		for x in range(10, 38):
			if (x - 24) * (x - 24) + (y - 60) * (y - 60) < 150:
				img.set_pixel(x, y, METAL_DARK)

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	chair_node.add_child(sprite)

	return chair_node

## Creates a filing cabinet
static func create_filing_cabinet() -> Node2D:
	var cabinet_node = Node2D.new()
	var img = Image.create(48, 80, false, Image.FORMAT_RGBA8)

	# Cabinet body (metal gray)
	img.fill(METAL_GRAY)

	# Drawers (3 drawers)
	for drawer in range(3):
		var drawer_y = 10 + drawer * 22

		# Drawer outline (darker)
		for y in range(drawer_y, drawer_y + 20):
			img.set_pixel(4, y, METAL_DARK)
			img.set_pixel(43, y, METAL_DARK)
		for x in range(4, 44):
			img.set_pixel(x, drawer_y, METAL_DARK)
			img.set_pixel(x, drawer_y + 19, METAL_DARK)

		# Drawer handle
		for y in range(drawer_y + 8, drawer_y + 12):
			for x in range(20, 28):
				img.set_pixel(x, y, METAL_DARK)

	# Top surface highlight
	for x in range(0, 48):
		img.set_pixel(x, 0, METAL_GRAY.lightened(0.2))
		img.set_pixel(x, 1, METAL_GRAY.lightened(0.1))

	# Side shadows
	for y in range(0, 80):
		img.set_pixel(47, y, METAL_DARK)
		img.set_pixel(46, y, METAL_GRAY.darkened(0.1))

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cabinet_node.add_child(sprite)

	return cabinet_node

## Creates a potted plant
static func create_potted_plant() -> Node2D:
	var plant_node = Node2D.new()
	var img = Image.create(40, 60, false, Image.FORMAT_RGBA8)

	img.fill(Color(0, 0, 0, 0))  # Transparent

	# Pot (terracotta)
	var pot_color = Color(0.72, 0.42, 0.28)
	for y in range(42, 60):
		for x in range(8, 32):
			var pot_width = 12 + (y - 42) * 0.4
			if x > 20 - pot_width and x < 20 + pot_width:
				img.set_pixel(x, y, pot_color)
				if x == int(20 - pot_width) or x == int(20 + pot_width) - 1:
					img.set_pixel(x, y, pot_color.darkened(0.3))

	# Soil
	for y in range(40, 44):
		for x in range(10, 30):
			img.set_pixel(x, y, Color(0.3, 0.2, 0.1))

	# Plant stems and leaves
	# Center stem
	for y in range(20, 42):
		for x in range(19, 21):
			img.set_pixel(x, y, PLANT_DARK)

	# Leaves (simple rounded shapes)
	var leaf_positions = [
		[15, 15], [25, 15], [12, 25], [28, 25], [20, 10]
	]

	for leaf_pos in leaf_positions:
		var lx = leaf_pos[0]
		var ly = leaf_pos[1]
		for y in range(ly, ly + 8):
			for x in range(lx, lx + 8):
				var dx = x - (lx + 4)
				var dy = y - (ly + 4)
				if dx * dx + dy * dy < 16:
					if dx * dx + dy * dy < 12:
						img.set_pixel(x, y, PLANT_GREEN)
					else:
						img.set_pixel(x, y, PLANT_DARK)

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	plant_node.add_child(sprite)

	return plant_node

## Creates a delivery van (for garage)
static func create_delivery_van() -> Node2D:
	var van_node = Node2D.new()
	var img = Image.create(140, 80, false, Image.FORMAT_RGBA8)

	img.fill(Color(0, 0, 0, 0))  # Transparent

	# Van body (red)
	for y in range(15, 55):
		for x in range(20, 120):
			img.set_pixel(x, y, TRUCK_RED)

	# Cargo area (lighter)
	for y in range(15, 55):
		for x in range(60, 120):
			img.set_pixel(x, y, TRUCK_RED.lightened(0.1))

	# Windshield
	for y in range(18, 35):
		for x in range(20, 40):
			img.set_pixel(x, y, Color(0.3, 0.45, 0.6))

	# Windshield reflection
	for y in range(18, 25):
		for x in range(22, 38):
			img.set_pixel(x, y, Color(0.6, 0.75, 0.9))

	# Front bumper
	for y in range(50, 55):
		for x in range(15, 25):
			img.set_pixel(x, y, Color(0.2, 0.2, 0.2))

	# Headlight
	for y in range(42, 48):
		for x in range(15, 20):
			img.set_pixel(x, y, Color(0.95, 0.95, 0.7))

	# Wheels
	# Front wheel
	for y in range(50, 65):
		for x in range(30, 45):
			var dx = x - 37.5
			var dy = y - 57.5
			if dx * dx + dy * dy < 50:
				if dx * dx + dy * dy < 35:
					img.set_pixel(x, y, Color(0.15, 0.15, 0.15))
				else:
					img.set_pixel(x, y, Color(0.1, 0.1, 0.1))

	# Rear wheel
	for y in range(50, 65):
		for x in range(95, 110):
			var dx = x - 102.5
			var dy = y - 57.5
			if dx * dx + dy * dy < 50:
				if dx * dx + dy * dy < 35:
					img.set_pixel(x, y, Color(0.15, 0.15, 0.15))
				else:
					img.set_pixel(x, y, Color(0.1, 0.1, 0.1))

	# Door lines
	for y in range(15, 55):
		img.set_pixel(58, y, TRUCK_RED.darkened(0.3))
		img.set_pixel(59, y, TRUCK_RED.darkened(0.3))

	# Door handle
	for y in range(32, 38):
		for x in range(45, 50):
			img.set_pixel(x, y, Color(0.4, 0.4, 0.4))

	# Side mirror
	for y in range(22, 28):
		for x in range(12, 18):
			img.set_pixel(x, y, Color(0.2, 0.2, 0.2))

	# Highlights and shadows
	for y in range(15, 20):
		for x in range(20, 120):
			img.set_pixel(x, y, TRUCK_RED.lightened(0.15))

	for y in range(50, 55):
		for x in range(20, 120):
			img.set_pixel(x, y, TRUCK_RED.darkened(0.2))

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	van_node.add_child(sprite)

	return van_node

## Creates a mechanic character
static func create_mechanic_character() -> Node2D:
	var char_node = Node2D.new()
	var img = Image.create(32, 48, false, Image.FORMAT_RGBA8)

	img.fill(Color(0, 0, 0, 0))  # Transparent

	# Head (skin tone)
	var skin = Color(0.85, 0.65, 0.50)
	for y in range(8, 16):
		for x in range(12, 20):
			img.set_pixel(x, y, skin)

	# Hair
	for y in range(8, 12):
		for x in range(12, 20):
			img.set_pixel(x, y, Color(0.25, 0.2, 0.15))

	# Work shirt (blue)
	var shirt = Color(0.3, 0.4, 0.6)
	for y in range(16, 30):
		for x in range(10, 22):
			img.set_pixel(x, y, shirt)

	# Pants (dark blue)
	var pants = Color(0.2, 0.25, 0.35)
	for y in range(30, 42):
		for x in range(11, 21):
			img.set_pixel(x, y, pants)

	# Shoes
	for y in range(42, 46):
		for x in range(11, 15):
			img.set_pixel(x, y, Color(0.15, 0.15, 0.15))
		for x in range(17, 21):
			img.set_pixel(x, y, Color(0.15, 0.15, 0.15))

	# Arms
	for y in range(18, 30):
		# Left arm
		for x in range(8, 11):
			img.set_pixel(x, y, shirt)
		# Right arm
		for x in range(21, 24):
			img.set_pixel(x, y, shirt)

	# Hands
	for y in range(28, 32):
		for x in range(7, 10):
			img.set_pixel(x, y, skin)
		for x in range(22, 25):
			img.set_pixel(x, y, skin)

	# Tool in hand (wrench)
	for y in range(30, 36):
		for x in range(24, 28):
			img.set_pixel(x, y, Color(0.6, 0.6, 0.65))

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	char_node.add_child(sprite)

	return char_node

## Creates garage equipment (tool chest)
static func create_tool_chest() -> Node2D:
	var chest_node = Node2D.new()
	var img = Image.create(64, 56, false, Image.FORMAT_RGBA8)

	# Chest body (red metal)
	var chest_red = Color(0.75, 0.15, 0.15)
	img.fill(chest_red)

	# Drawers
	for drawer in range(4):
		var y_pos = 8 + drawer * 12
		# Drawer line
		for x in range(0, 64):
			img.set_pixel(x, y_pos, Color(0.2, 0.05, 0.05))

		# Handle
		for y in range(y_pos + 4, y_pos + 8):
			for x in range(28, 36):
				img.set_pixel(x, y, Color(0.4, 0.4, 0.4))

	# Side highlights
	for y in range(0, 56):
		img.set_pixel(0, y, chest_red.lightened(0.2))
		img.set_pixel(63, y, chest_red.darkened(0.3))

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	chest_node.add_child(sprite)

	return chest_node

## Creates a poster/sign for wall decoration
static func create_wall_poster(text: String) -> Node2D:
	var poster_node = Node2D.new()
	var img = Image.create(80, 60, false, Image.FORMAT_RGBA8)

	# Poster background (white/beige)
	img.fill(Color(0.95, 0.93, 0.88))

	# Border
	for y in range(0, 60):
		img.set_pixel(0, y, Color(0.2, 0.2, 0.2))
		img.set_pixel(79, y, Color(0.2, 0.2, 0.2))
	for x in range(0, 80):
		img.set_pixel(x, 0, Color(0.2, 0.2, 0.2))
		img.set_pixel(x, 59, Color(0.2, 0.2, 0.2))

	# Simple graphic (truck silhouette)
	for y in range(15, 30):
		for x in range(20, 60):
			if (y > 18 and y < 27 and x > 25 and x < 55):
				img.set_pixel(x, y, Color(0.3, 0.3, 0.3))

	var texture = ImageTexture.create_from_image(img)
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	poster_node.add_child(sprite)

	# Add text label
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	label.position = Vector2(-35, 20)
	poster_node.add_child(label)

	return poster_node
