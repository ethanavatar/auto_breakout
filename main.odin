package main
import "core:fmt"
import "vendor:raylib"

game_title :: "Bouncing Thingy"
canvas_width :: 600
canvas_height :: 800

window_width :: 800
window_height :: 1000

should_close := false
canvas_texture : raylib.RenderTexture2D
window_texture : raylib.RenderTexture2D

canvas_source := raylib.Rectangle{
    0, 0,
    cast(f32)canvas_width, -cast(f32)canvas_height
}
canvas_dest := raylib.Rectangle{
    0, 0,
    cast(f32)window_width, cast(f32)window_height
}

tile_size :: 60
tile_count_x :: canvas_width / tile_size
tile_count_y :: canvas_height / tile_size

grid : [tile_count_x * tile_count_y]bool

top_ball : Ball
bottom_ball : Ball

Ball :: struct {
    position : raylib.Vector2,
    velocity : raylib.Vector2,
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
    direction := raylib.Vector2{cast(f32)raylib.GetRandomValue(-1, 1), -1}
    top_ball.velocity = direction * 10
    top_ball.collision_value = true

    bottom_ball.position = raylib.Vector2{canvas_width / 2, canvas_height / 4}
    direction = raylib.Vector2{cast(f32)raylib.GetRandomValue(-1, 1), 1}
    bottom_ball.velocity = direction * 10
    bottom_ball.collision_value = false
}

update_ball :: proc(ball : ^Ball) {
    ball_bounds := BoundingBox{ball.position, raylib.Vector2{20, 20}}
    draw_bounds(ball_bounds, raylib.RED)

    destination_bounds := BoundingBox{ball.position + ball.velocity, raylib.Vector2{20, 20}}
    draw_bounds(destination_bounds, raylib.GREEN)

    destination_tile := cast(int)(destination_bounds.position.x / tile_size) +
                        cast(int)(destination_bounds.position.y / tile_size) * tile_count_x

    if destination_tile >= 0 && destination_tile < tile_count_x * tile_count_y {
        if grid[destination_tile] == ball.collision_value {
            tile_bounds := BoundingBox{
                raylib.Vector2{
                    cast(f32)(destination_tile % tile_count_x) * tile_size,
                    cast(f32)(destination_tile / tile_count_x) * tile_size,
                },
                raylib.Vector2{tile_size, tile_size},
            }
            draw_bounds(tile_bounds, raylib.BLUE)

            new_bounds, new_velocity := sweep_and_deflect(ball_bounds, tile_bounds, ball.velocity)
            fmt.println(ball_bounds.position, ball.velocity, new_bounds.position, new_velocity)
            
            ball.position = new_bounds.position
            ball.velocity = new_velocity
            grid[destination_tile] = !grid[destination_tile]

        } else {
            ball.position += ball.velocity
        }
    }
}

main :: proc() {
    raylib.InitWindow(window_width, window_height, game_title)
    raylib.SetTargetFPS(10)

    canvas_texture = raylib.LoadRenderTexture(canvas_width, canvas_height)
    window_texture = raylib.LoadRenderTexture(window_width, window_height)

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
            update_ball(&top_ball)
            update_ball(&bottom_ball)
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
    }

    raylib.CloseWindow()
}
