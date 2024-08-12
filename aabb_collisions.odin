package main
import "core:math"
import "vendor:raylib"

Hit :: struct {
    is_hit : bool,
    time : f32,
    position : raylib.Vector2,
}

ray_intersect_bounds :: proc(
    position : raylib.Vector2,
    magnitude : raylib.Vector2,
    bounds : BoundingBox
) -> Hit {
    hit := Hit{}
    min := bounds.position - bounds.half_extents
    max := bounds.position + bounds.half_extents

    last_entry : f32 = -math.F32_MAX
    first_exit : f32 = math.F32_MAX

    for dimension := 0; dimension < 2; dimension += 1 {
        if (magnitude[dimension] != 0) {
            t0 := (min[dimension] - position[dimension]) / magnitude[dimension]
            t1 := (max[dimension] - position[dimension]) / magnitude[dimension]

            last_entry = math.max(last_entry, math.min(t0, t1)) 
            first_exit = math.min(first_exit, math.max(t0, t1))
        } else if (position[dimension] < min[dimension] || position[dimension] > max[dimension]) {
            return hit
        }
    }

    if (last_entry < first_exit && last_entry >= 0 && last_entry <= 1) {
        hit.is_hit = true
        hit.time = last_entry
        hit.position = position + magnitude * last_entry
    }

    return hit
}

sweep_and_deflect :: proc(
    a : BoundingBox, // The box that is moving and will be deflected
    b : BoundingBox, // The box to deflect off of
    velocity : raylib.Vector2,
) -> (BoundingBox, raylib.Vector2) {
    combined_box := BoundingBox{b.position, a.half_extents + b.half_extents};
    destination := BoundingBox{a.position + velocity, a.half_extents}
    new_velocity := velocity

    hit := ray_intersect_bounds(a.position, velocity, combined_box)
    if (!hit.is_hit) {
        return destination, new_velocity
    }

    swept_box := BoundingBox{hit.position, a.half_extents}

    hit_distance := hit.position - b.position
    normal := math.abs(hit_distance.x) > math.abs(hit_distance.y) ? raylib.Vector2{hit_distance.x, 0} : raylib.Vector2{0, hit_distance.y}

    collision_angle := math.atan2(a.position.y - hit.position.y, a.position.x - hit.position.x)
    deflection_angle := collision_angle + math.PI
    deflection_vector := raylib.Vector2{math.cos(deflection_angle), math.sin(deflection_angle)}

    if (normal.x != 0) {
        deflection_vector.x = -deflection_vector.x
    } else {
        deflection_vector.y = -deflection_vector.y
    }

    absolute_distance := raylib.Vector2{math.abs(velocity.x), math.abs(velocity.y)}
    deflection_magnitude := (1.0 - hit.time) * raylib.Vector2Length(absolute_distance)

    deflected_box := BoundingBox{
        hit.position + deflection_vector * deflection_magnitude,
        a.half_extents
    }

    if (normal.x != 0) {
        new_velocity.x = -velocity.x
    } else {
        new_velocity.y = -velocity.y
    }

    return deflected_box, new_velocity
}

