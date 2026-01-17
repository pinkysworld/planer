extends Node
## TextureGenerator - Procedural texture generation for authentic materials

class_name TextureGenerator

## Generates wood grain texture
static func generate_wood_texture(width: int, height: int, color: Color = Color(0.6, 0.4, 0.25)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Base wood color
	img.fill(color)

	# Wood grain lines (vertical with slight curves)
	for x in range(width):
		var wave_offset = sin(float(x) / 8.0) * 3.0
		for y in range(height):
			var noise = sin(float(y + wave_offset) / 4.0) * 0.1
			var grain_factor = 1.0 + noise

			# Darker grain lines
			if int(y + wave_offset) % 8 < 2:
				var dark_wood = Color(color.r * 0.7, color.g * 0.7, color.b * 0.7)
				img.set_pixel(x, y, dark_wood)
			# Lighter highlights
			elif int(y + wave_offset) % 8 == 4:
				var light_wood = Color(color.r * 1.15, color.g * 1.15, color.b * 1.15)
				img.set_pixel(x, y, light_wood)
			# Knots (circular darker areas)
			if (x - width/3) * (x - width/3) + (y - height/2) * (y - height/2) < 25:
				var knot_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5)
				img.set_pixel(x, y, knot_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates metal texture with brushed effect
static func generate_metal_texture(width: int, height: int, base_color: Color = Color(0.7, 0.7, 0.75)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Brushed metal effect (horizontal lines)
	for y in range(height):
		for x in range(width):
			var noise = (hash(Vector2i(x, y)) % 100) / 100.0
			var brightness = 0.85 + noise * 0.3
			var metal_color = Color(
				base_color.r * brightness,
				base_color.g * brightness,
				base_color.b * brightness
			)

			# Horizontal brush lines
			if y % 2 == 0:
				metal_color = metal_color.darkened(0.1)

			# Random scratches
			if noise > 0.95:
				metal_color = metal_color.lightened(0.3)

			img.set_pixel(x, y, metal_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates concrete/plaster wall texture
static func generate_concrete_texture(width: int, height: int, base_color: Color = Color(0.55, 0.6, 0.65)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(base_color)

	# Add noise and subtle variations
	for y in range(height):
		for x in range(width):
			var noise = (hash(Vector2i(x, y)) % 100) / 100.0
			var variation = -0.05 + noise * 0.1

			var concrete_color = Color(
				clamp(base_color.r + variation, 0, 1),
				clamp(base_color.g + variation, 0, 1),
				clamp(base_color.b + variation, 0, 1)
			)

			# Cracks and imperfections
			if noise > 0.98:
				concrete_color = concrete_color.darkened(0.3)

			# Speckles
			if noise < 0.05:
				concrete_color = concrete_color.lightened(0.2)

			img.set_pixel(x, y, concrete_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates ceramic tile texture
static func generate_tile_texture(size: int, base_color: Color = Color(0.9, 0.88, 0.85)) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)

	img.fill(base_color)

	# Tile surface with slight gloss
	for y in range(size):
		for x in range(size):
			var dist_from_center = sqrt(pow(x - size/2, 2) + pow(y - size/2, 2))
			var gloss = 1.0 - (dist_from_center / (size * 0.7))
			gloss = clamp(gloss, 0.8, 1.1)

			var noise = (hash(Vector2i(x, y)) % 100) / 500.0

			var tile_color = Color(
				base_color.r * gloss + noise,
				base_color.g * gloss + noise,
				base_color.b * gloss + noise
			)

			img.set_pixel(x, y, tile_color)

	# Dark border (grout)
	for i in range(size):
		img.set_pixel(i, 0, Color(0.3, 0.35, 0.4))
		img.set_pixel(i, size - 1, Color(0.3, 0.35, 0.4))
		img.set_pixel(0, i, Color(0.3, 0.35, 0.4))
		img.set_pixel(size - 1, i, Color(0.3, 0.35, 0.4))

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates glass texture with reflections
static func generate_glass_texture(width: int, height: int, tint: Color = Color(0.6, 0.75, 0.9, 0.7)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Sky gradient reflection
	for y in range(height):
		for x in range(width):
			var gradient = float(y) / float(height)
			var glass_color = Color(
				tint.r + gradient * 0.2,
				tint.g + gradient * 0.15,
				tint.b + gradient * 0.1,
				tint.a
			)

			# Reflections (bright spots)
			if y < height / 3:
				var noise = (hash(Vector2i(x, y)) % 100) / 100.0
				if noise > 0.9:
					glass_color = glass_color.lightened(0.4)

			img.set_pixel(x, y, glass_color)

	# Highlights at top
	for y in range(height / 5):
		for x in range(width / 3):
			var highlight = Color(1, 1, 1, 0.3)
			img.set_pixel(x + width / 6, y, highlight)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates carpet texture
static func generate_carpet_texture(width: int, height: int, base_color: Color = Color(0.6, 0.3, 0.2)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Fuzzy carpet appearance
	for y in range(height):
		for x in range(width):
			var noise = (hash(Vector2i(x, y)) % 100) / 100.0
			var fuzz = -0.1 + noise * 0.2

			var carpet_color = Color(
				clamp(base_color.r + fuzz, 0, 1),
				clamp(base_color.g + fuzz, 0, 1),
				clamp(base_color.b + fuzz, 0, 1)
			)

			img.set_pixel(x, y, carpet_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates leather texture
static func generate_leather_texture(width: int, height: int, base_color: Color = Color(0.4, 0.3, 0.25)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(base_color)

	# Leather grain pattern
	for y in range(height):
		for x in range(width):
			var noise = (hash(Vector2i(x, y)) % 100) / 100.0

			# Wrinkles and creases
			if noise > 0.95 or (x + y) % 7 == 0:
				var crease = Color(
					base_color.r * 0.7,
					base_color.g * 0.7,
					base_color.b * 0.7
				)
				img.set_pixel(x, y, crease)
			# Highlights
			elif noise < 0.1:
				var highlight = Color(
					base_color.r * 1.2,
					base_color.g * 1.2,
					base_color.b * 1.2
				)
				img.set_pixel(x, y, highlight)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates brick texture
static func generate_brick_texture(width: int, height: int, brick_color: Color = Color(0.7, 0.4, 0.3)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	var mortar_color = Color(0.65, 0.65, 0.6)
	var brick_height = 16
	var brick_width = 48

	# Fill with mortar
	img.fill(mortar_color)

	# Draw bricks
	var row = 0
	var y_pos = 0
	while y_pos < height:
		var x_offset = (row % 2) * (brick_width / 2)
		var x_pos = x_offset

		while x_pos < width:
			# Draw brick
			for by in range(brick_height - 2):
				for bx in range(brick_width - 2):
					var px = x_pos + bx + 1
					var py = y_pos + by + 1
					if px < width and py < height:
						# Add texture to brick
						var noise = (hash(Vector2i(px, py)) % 100) / 200.0
						var textured_brick = Color(
							brick_color.r + noise,
							brick_color.g + noise,
							brick_color.b + noise
						)
						img.set_pixel(px, py, textured_brick)

			x_pos += brick_width

		y_pos += brick_height
		row += 1

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates marble texture
static func generate_marble_texture(width: int, height: int, base_color: Color = Color(0.9, 0.88, 0.85)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	img.fill(base_color)

	# Marble veins
	for y in range(height):
		for x in range(width):
			var vein_pattern = sin(float(x) / 10.0 + float(y) / 15.0) * sin(float(x) / 7.0)

			if vein_pattern > 0.7:
				# Dark veins
				var vein_color = Color(0.5, 0.5, 0.48)
				img.set_pixel(x, y, vein_color)
			elif vein_pattern > 0.5:
				# Light veins
				var light_vein = Color(0.7, 0.68, 0.65)
				img.set_pixel(x, y, light_vein)
			else:
				# Add subtle noise to base
				var noise = (hash(Vector2i(x, y)) % 100) / 500.0
				var marble_color = Color(
					base_color.r + noise,
					base_color.g + noise,
					base_color.b + noise
				)
				img.set_pixel(x, y, marble_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Generates fabric texture
static func generate_fabric_texture(width: int, height: int, base_color: Color = Color(0.4, 0.45, 0.5)) -> ImageTexture:
	var img = Image.create(width, height, false, Image.FORMAT_RGBA8)

	# Weave pattern
	for y in range(height):
		for x in range(width):
			var weave = (x % 4 < 2) != (y % 4 < 2)
			var brightness = 1.0 if weave else 0.85

			var noise = (hash(Vector2i(x, y)) % 100) / 200.0

			var fabric_color = Color(
				base_color.r * brightness + noise,
				base_color.g * brightness + noise,
				base_color.b * brightness + noise
			)

			img.set_pixel(x, y, fabric_color)

	var texture = ImageTexture.create_from_image(img)
	return texture

## Simple hash function for noise
static func hash(v: Vector2i) -> int:
	return (v.x * 73856093) ^ (v.y * 19349663)
