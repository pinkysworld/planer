extends Node
## TextureCache - Caches generated textures for better performance

const TextureGenerator = preload("res://scripts/graphics/texture_generator.gd")

var texture_cache: Dictionary = {}
var cache_hits: int = 0
var cache_misses: int = 0

func get_wood_texture(width: int, height: int, color: Color = Color(0.6, 0.4, 0.25)) -> ImageTexture:
	var key = "wood_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_wood_texture(width, height, color))

func get_metal_texture(width: int, height: int, color: Color = Color(0.7, 0.7, 0.75)) -> ImageTexture:
	var key = "metal_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_metal_texture(width, height, color))

func get_concrete_texture(width: int, height: int, color: Color = Color(0.55, 0.6, 0.65)) -> ImageTexture:
	var key = "concrete_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_concrete_texture(width, height, color))

func get_tile_texture(size: int, color: Color = Color(0.9, 0.88, 0.85)) -> ImageTexture:
	var key = "tile_%d_%s" % [size, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_tile_texture(size, color))

func get_glass_texture(width: int, height: int, tint: Color = Color(0.6, 0.75, 0.9, 0.7)) -> ImageTexture:
	var key = "glass_%d_%d_%s" % [width, height, tint.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_glass_texture(width, height, tint))

func get_carpet_texture(width: int, height: int, color: Color = Color(0.6, 0.3, 0.2)) -> ImageTexture:
	var key = "carpet_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_carpet_texture(width, height, color))

func get_leather_texture(width: int, height: int, color: Color = Color(0.4, 0.3, 0.25)) -> ImageTexture:
	var key = "leather_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_leather_texture(width, height, color))

func get_marble_texture(width: int, height: int, color: Color = Color(0.9, 0.88, 0.85)) -> ImageTexture:
	var key = "marble_%d_%d_%s" % [width, height, color.to_html()]
	return _get_or_create(key, func(): return TextureGenerator.generate_marble_texture(width, height, color))

func _get_or_create(key: String, generator: Callable) -> ImageTexture:
	if texture_cache.has(key):
		cache_hits += 1
		return texture_cache[key]

	cache_misses += 1
	var texture = generator.call()
	texture_cache[key] = texture
	return texture

func clear_cache() -> void:
	texture_cache.clear()
	cache_hits = 0
	cache_misses = 0

func get_cache_stats() -> Dictionary:
	return {
		"size": texture_cache.size(),
		"hits": cache_hits,
		"misses": cache_misses,
		"hit_rate": float(cache_hits) / max(1, cache_hits + cache_misses)
	}

func preload_common_textures() -> void:
	# Preload frequently used textures
	get_wood_texture(96, 32, Color(0.6, 0.4, 0.25))
	get_metal_texture(48, 96, Color(0.3, 0.32, 0.35))
	get_glass_texture(28, 28)
	get_tile_texture(32)
	get_concrete_texture(256, 180)
	get_carpet_texture(128, 80)
	get_marble_texture(128, 80)
	get_leather_texture(40, 24)
