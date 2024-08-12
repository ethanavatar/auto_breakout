package main
import "vendor:raylib"

BoundingBox :: struct {
    position, half_extents : raylib.Vector2,
}

draw_bounds :: proc(aabb : BoundingBox, color : raylib.Color) {
    raylib.DrawCircleV(aabb.position, 2, color)
    raylib.DrawRectangleLines(
        cast(i32)(aabb.position.x - aabb.half_extents.x),
        cast(i32)(aabb.position.y - aabb.half_extents.y),
        cast(i32)(aabb.half_extents.x * 2),
        cast(i32)(aabb.half_extents.y * 2),
        color,
    )
}

