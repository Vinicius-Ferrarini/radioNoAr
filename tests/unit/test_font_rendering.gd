extends GutTest

const FONT_IMPORTS := [
	"res://assets/fonts/CourierPrime-Regular.ttf.import",
	"res://assets/fonts/CourierPrime-Bold.ttf.import",
]


func test_fonts_are_imported_as_crisp_pixel_text() -> void:
	for path in FONT_IMPORTS:
		var source := FileAccess.get_file_as_string(path)
		assert_string_contains(source, "antialiasing=0", path)
		assert_string_contains(source, "subpixel_positioning=0", path)
		assert_string_contains(source, "hinting=1", path)


func test_theme_uses_native_2x_font_sizes() -> void:
	var source := FileAccess.get_file_as_string("res://theme/theme.tres")
	assert_string_contains(source, "default_font_size = 14")
	assert_string_contains(source, "RichTextLabel/font_sizes/normal_font_size = 14")
	assert_string_contains(source, "RichTextLabel/font_sizes/bold_font_size = 20")
