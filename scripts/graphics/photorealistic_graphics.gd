extends Node
## PhotorealisticGraphics - High-quality photorealistic pixel art for Der Planer

class_name PhotorealisticGraphics

## Creates a highly detailed photorealistic door
static func create_realistic_door(width: int = 64, height: int = 128) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Door frame (dark wood/metal)
	var frame_color = Color(0.18, 0.15, 0.12)
	img.fill(frame_color)

	# Main door panel with realistic shading
	for y in range(4, height - 4):
		for x in range(4, width - 4):
			# Calculate distance from edges for lighting
			var dist_from_left = float(x - 4)
			var dist_from_top = float(y - 4)
			var dist_from_right = float(width - 4 - x)
			var dist_from_bottom = float(height - 4 - y)

			# Base door color (cyan/turquoise like in screenshots)
			var base = Color(0.35, 0.60, 0.75)

			# Add realistic lighting gradient
			var lighting = 1.0
			if dist_from_left < 8:
				lighting += (dist_from_left / 8.0) * 0.3  # Left highlight
			if dist_from_top < 12:
				lighting += (dist_from_top / 12.0) * 0.2  # Top highlight

			if dist_from_right < 8:
				lighting -= (8 - dist_from_right) / 8.0 * 0.3  # Right shadow
			if dist_from_bottom < 12:
				lighting -= (12 - dist_from_bottom) / 12.0 * 0.2  # Bottom shadow

			# Add subtle noise for texture
			var noise = (hash(Vector2i(x / 2, y / 2)) % 20) / 400.0 - 0.025
			lighting += noise

			var door_color = Color(
				clamp(base.r * lighting, 0, 1),
				clamp(base.g * lighting, 0, 1),
				clamp(base.b * lighting, 0, 1)
			)
			img.set_pixel(x, y, door_color)

	# Door window (upper portion) with realistic glass
	var window_top = int(height * 0.15)
	var window_bottom = int(height * 0.45)
	var window_left = int(width * 0.2)
	var window_right = int(width * 0.8)

	for y in range(window_top, window_bottom):
		for x in range(window_left, window_right):
			# Window frame
			if x < window_left + 3 or x > window_right - 3 or y < window_top + 3 or y > window_bottom - 3:
				img.set_pixel(x, y, Color(0.15, 0.12, 0.10))
			else:
				# Glass with realistic sky reflection
				var glass_y_progress = float(y - window_top) / float(window_bottom - window_top)
				var sky_color = Color(
					0.45 + glass_y_progress * 0.25,
					0.55 + glass_y_progress * 0.20,
					0.75 + glass_y_progress * 0.10
				)

				# Add reflection highlights
				var dist_from_glass_top = float(y - window_top - 3)
				if dist_from_glass_top < 10:
					var highlight = (10 - dist_from_glass_top) / 10.0 * 0.4
					sky_color = sky_color.lightened(highlight)

				# Add subtle variations
				var glass_noise = (hash(Vector2i(x, y)) % 15) / 150.0
				sky_color.r += glass_noise
				sky_color.g += glass_noise
				sky_color.b += glass_noise

				img.set_pixel(x, y, sky_color)

	# Window dividers (cross pattern)
	var window_center_x = (window_left + window_right) / 2
	var window_center_y = (window_top + window_bottom) / 2

	for y in range(window_top + 3, window_bottom - 3):
		for x in range(window_center_x - 1, window_center_x + 2):
			img.set_pixel(x, y, Color(0.12, 0.10, 0.08))

	for x in range(window_left + 3, window_right - 3):
		for y in range(window_center_y - 1, window_center_y + 2):
			img.set_pixel(x, y, Color(0.12, 0.10, 0.08))

	# Decorative panels (lower door)
	var panel_configs = [
		[0.52, 0.68],  # Upper panel
		[0.72, 0.88]   # Lower panel
	]

	for config in panel_configs:
		var panel_top = int(height * config[0])
		var panel_bottom = int(height * config[1])
		var panel_left = int(width * 0.15)
		var panel_right = int(width * 0.85)

		# Panel border (inset)
		for y in range(panel_top, panel_bottom):
			for x in range(panel_left, panel_right):
				if y == panel_top or y == panel_bottom - 1 or x == panel_left or x == panel_right - 1:
					img.set_pixel(x, y, Color(0.25, 0.45, 0.58))
				elif y == panel_top + 1 or x == panel_left + 1:
					img.set_pixel(x, y, Color(0.45, 0.70, 0.85))  # Highlight

	# Door handle (metallic brass)
	var handle_y = int(height * 0.62)
	var handle_x = int(width * 0.80)

	for y in range(handle_y, handle_y + 12):
		for x in range(handle_x, handle_x + 8):
			var handle_color = Color(0.82, 0.70, 0.35)  # Brass color

			# Add metallic sheen
			var dist_from_handle_top = float(y - handle_y)
			if dist_from_handle_top < 4:
				handle_color = handle_color.lightened((4 - dist_from_handle_top) / 4.0 * 0.3)

			img.set_pixel(x, y, handle_color)

	# Strong highlights on handle
	for y in range(handle_y, handle_y + 3):
		for x in range(handle_x, handle_x + 3):
			img.set_pixel(x, y, Color(0.95, 0.88, 0.60))

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

## Creates photorealistic office desk with detailed computer setup
static func create_realistic_office_desk(width: int = 200, height: int = 120) -> Sprite2D:
	var sprite = Sprite2D.new()
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(Color(0, 0, 0, 0))  # Transparent background

	# Desk surface with wood grain texture
	var desk_top = int(height * 0.35)
	var desk_bottom = int(height * 0.50)

	for y in range(desk_top, desk_bottom):
		for x in range(0, width):
			# Wood grain pattern
			var grain = sin(float(x) * 0.15 + float(y) * 0.05) * 0.08
			var wood_base = Color(0.48, 0.32, 0.20)
			var wood_color = Color(
				clamp(wood_base.r + grain, 0, 1),
				clamp(wood_base.g + grain, 0, 1),
				clamp(wood_base.b + grain, 0, 1)
			)

			# Add wood knots
			if (x % 85) < 12 and (y - desk_top) > 5 and (y - desk_top) < 12:
				wood_color = wood_color.darkened(0.35)

			img.set_pixel(x, y, wood_color)

	# Desk edge shadow
	for x in range(0, width):
		img.set_pixel(x, desk_bottom, Color(0.22, 0.15, 0.10))
		img.set_pixel(x, desk_bottom + 1, Color(0.28, 0.18, 0.12))

	# Desk legs
	var leg_positions = [15, width - 25]
	for leg_x in leg_positions:
		for y in range(desk_bottom + 2, height):
			for x in range(leg_x, leg_x + 10):
				var leg_color = Color(0.32, 0.20, 0.12)
				# Add shading
				if x == leg_x or x == leg_x + 9:
					leg_color = leg_color.darkened(0.2)
				elif x == leg_x + 1:
					leg_color = leg_color.lightened(0.1)
				img.set_pixel(x, y, leg_color)

	# Computer monitor (detailed LCD display)
	var monitor_x = 30
	var monitor_y = desk_top - 60
	var monitor_width = 70
	var monitor_height = 55

	# Monitor frame (dark gray/black)
	for y in range(monitor_y, monitor_y + monitor_height):
		for x in range(monitor_x, monitor_x + monitor_width):
			var frame_color = Color(0.15, 0.15, 0.18)
			# Frame border
			if x < monitor_x + 3 or x > monitor_x + monitor_width - 4 or y < monitor_y + 3 or y > monitor_y + monitor_height - 4:
				img.set_pixel(x, y, frame_color)
			else:
				# LCD screen (dark with green phosphor glow)
				var screen_base = Color(0.05, 0.08, 0.06)
				img.set_pixel(x, y, screen_base)

				# Add green text lines
				if (y - monitor_y) % 6 == 0 and x > monitor_x + 6 and x < monitor_x + monitor_width - 10:
					img.set_pixel(x, y, Color(0.15, 0.95, 0.25))

				# Screen reflection (top left)
				var dist_from_top_left = (x - monitor_x - 5) * (x - monitor_x - 5) + (y - monitor_y - 5) * (y - monitor_y - 5)
				if dist_from_top_left < 80:
					var reflection = Color(0.3, 0.4, 0.5, 0.3)
					img.set_pixel(x, y, screen_base.blend(reflection))

	# Monitor stand
	var stand_x = monitor_x + monitor_width / 2 - 8
	for y in range(monitor_y + monitor_height, desk_top):
		for x in range(stand_x, stand_x + 16):
			if x > stand_x + 2 and x < stand_x + 14:
				var stand_color = Color(0.18, 0.18, 0.20)
				if x == stand_x + 3:
					stand_color = stand_color.lightened(0.15)
				img.set_pixel(x, y, stand_color)

	# Keyboard (compact, detailed)
	var keyboard_x = 75
	var keyboard_y = desk_top + 8
	var keyboard_width = 55
	var keyboard_height = 12

	for y in range(keyboard_y, keyboard_y + keyboard_height):
		for x in range(keyboard_x, keyboard_x + keyboard_width):
			var key_color = Color(0.60, 0.62, 0.65)  # Light gray keys

			# Individual key shapes
			var key_x_offset = (x - keyboard_x) % 8
			var key_y_offset = (y - keyboard_y) % 4

			if key_x_offset < 6 and key_y_offset < 3:
				# Key top
				if key_y_offset == 0:
					key_color = key_color.lightened(0.2)
				img.set_pixel(x, y, key_color)
			else:
				# Gap between keys
				img.set_pixel(x, y, Color(0.25, 0.25, 0.28))

	# Mouse (simple but detailed)
	var mouse_x = keyboard_x + keyboard_width + 8
	var mouse_y = keyboard_y + 2
	for y in range(mouse_y, mouse_y + 8):
		for x in range(mouse_x, mouse_x + 10):
			var mouse_color = Color(0.55, 0.57, 0.60)
			var dist_from_top = y - mouse_y
			if dist_from_top < 3:
				mouse_color = mouse_color.lightened(0.15)
			img.set_pixel(x, y, mouse_color)

	# Papers/documents on desk
	var paper_x = width - 45
	var paper_y = desk_top + 5
	for y in range(paper_y, paper_y + 20):
		for x in range(paper_x, paper_x + 35):
			var paper_color = Color(0.92, 0.90, 0.88)
			# Add text lines
			if (y - paper_y) % 3 == 0 and x > paper_x + 3 and x < paper_x + 30:
				if (x - paper_x) % 2 == 0:
					img.set_pixel(x, y, Color(0.25, 0.25, 0.25))
			else:
				img.set_pixel(x, y, paper_color)

	var texture = ImageTexture.create_from_image(img)
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	return sprite

static func hash(v: Vector2i) -> int:
	return (v.x * 73856093) ^ (v.y * 19349663)
