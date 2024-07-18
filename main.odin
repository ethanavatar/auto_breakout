package main
import "core:fmt"
import "vendor:raylib"

game_title :: "Bouncing Thingy"
canvas_width :: 600
canvas_height :: 800

initial_width :: 800
initial_height :: 1000

should_close := false
canvas_texture : raylib.RenderTexture2D
window_texture : raylib.RenderTexture2D

canvas_source := raylib.Rectangle{
    0, 0,
    cast(f32)canvas_width, -cast(f32)canvas_height
}
canvas_dest := raylib.Rectangle{
    0, 0,
    cast(f32)initial_width, cast(f32)initial_height
}

tile_size :: 60
tile_count_x :: canvas_width / tile_size
tile_count_y :: canvas_height / tile_size

grid : [tile_count_x * tile_count_y]bool

top_ball : Ball
bottom_ball : Ball

Ball :: struct {
    position : raylib.Vector2,
    direction : raylib.Vector2,
    speed : f32,
    collision_value : bool
}

reset_grid :: proc() {
    for i := 0; i < tile_count_x * tile_count_y; i += 1 {
        grid[i] = i < tile_count_x * tile_count_y / 2
    }
}

draw_tile :: proc(i : int) {
    if grid[i] == false {
        return
    }

    x_position : int = (i % tile_count_x) * tile_size
    y_position : int = (i / tile_count_x) * tile_size
    raylib.DrawRectangle(
        cast(i32)x_position, cast(i32)y_position,
        tile_size, tile_size,
        raylib.BLACK
    )
}

reset_balls :: proc() {
    top_ball.position = raylib.Vector2{canvas_width / 2, canvas_height * 3 / 4}
    top_ball.direction = raylib.Vector2{cast(f32)raylib.GetRandomValue(-1, 1), -1}
    top_ball.speed = 10
    top_ball.collision_value = true

    bottom_ball.position = raylib.Vector2{canvas_width / 2, canvas_height / 4}
    bottom_ball.direction = raylib.Vector2{cast(f32)raylib.GetRandomValue(-1, 1), 1}
    bottom_ball.speed = 10
    bottom_ball.collision_value = false
}

update_ball :: proc(ball : ^Ball) {
    ball.position += ball.direction * ball.speed

    // bounce off walls
    if ball.position.x < 0 || ball.position.x > canvas_width {
        ball.direction.x = -ball.direction.x
    }

    if ball.position.y < 0 || ball.position.y > canvas_height {
        ball.direction.y = -ball.direction.y
    }

    // bounce off grid
    x_tile := cast(int)ball.position.x / tile_size
    y_tile := cast(int)ball.position.y / tile_size

    if x_tile >= 0 && x_tile < tile_count_x && y_tile >= 0 && y_tile < tile_count_y {
        if grid[y_tile * tile_count_x + x_tile] == ball.collision_value {
            ball.direction.y = -ball.direction.y
            grid[y_tile * tile_count_x + x_tile] ~= true
        }
    }
}

main :: proc() {
    raylib.InitWindow(initial_width, initial_height, game_title)
    raylib.SetTargetFPS(60)

    canvas_texture = raylib.LoadRenderTexture(canvas_width, canvas_height)
    window_texture = raylib.LoadRenderTexture(initial_width, initial_height)

    reset_grid()
    reset_balls()

    for should_close == false && raylib.WindowShouldClose() == false {

        raylib.BeginTextureMode(canvas_texture)
            raylib.ClearBackground(raylib.RAYWHITE)

            for i := 0; i < tile_count_x * tile_count_y; i += 1 {
                draw_tile(i)
            }

            raylib.DrawCircleV(top_ball.position, 20, raylib.BLACK)
            raylib.DrawCircleV(bottom_ball.position, 20, raylib.RAYWHITE)
        raylib.EndTextureMode()

        raylib.BeginDrawing()
            raylib.ClearBackground(raylib.RAYWHITE)
            raylib.DrawTexturePro(
                canvas_texture.texture,
                canvas_source, canvas_dest,
                raylib.Vector2{0, 0}, 0,
                raylib.WHITE,
            )
        raylib.EndDrawing()

        if raylib.IsKeyPressed(raylib.KeyboardKey.R) {
            reset_grid()
            reset_balls()
        }

        update_ball(&top_ball)
        update_ball(&bottom_ball)
    }

    raylib.CloseWindow()
}
