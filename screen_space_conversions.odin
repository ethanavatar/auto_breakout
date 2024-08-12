package main
import "vendor:raylib"

window_to_canvas_position :: proc(window_position : raylib.Vector2) -> raylib.Vector2 {
    return raylib.Vector2{
        window_position.x / cast(f32)window_width * cast(f32)canvas_width,
        window_position.y / cast(f32)window_height * cast(f32)canvas_height,
    }
}
