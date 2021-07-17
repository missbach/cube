#!/usr/bin/env julia

# INPUTS

# Real world cube:
configuration = [2, 2, 2, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 2, 1, 1, 2]

# Result should be:
# 3×3×3 Array{Int64, 3}:
# [:, :, 1] =
#   1  13   4
#  -1  14  -1
#   2  -1   3
#
# [:, :, 2] =
#  10  -1  -1
#  -1  -1   7
#   9  -1   8
#
# [:, :, 3] =
#  11  12   5
#  16  15   6
#  17  -1  18

# Alternative, simple cube:
# configuration = [2, 2, 2, 1, 1,   1, 1, 1, 2, 2, 2,   1, 2, 2, 2, 1, 1]

# SETUP

cube_volume = sum(configuration) + 1
cube_length = Int(cbrt(cube_volume))

cube = zeros(Int, cube_length, cube_length, cube_length)
path = zeros(Int, cube_volume)

direction_vectors = [
     1  0  0
     0  1  0
     0  0  1
    -1  0  0
     0 -1  0
     0  0 -1
]

k = 1
position = [1, 1, 1]

function print_update()
    display(cube)
    println("\n")
    println("Position = ", position)
    println("Element k = ", k, "\n")
end

# COMPUTATION

print_update()

while true

    if k == length(configuration) + 1
        cube[position[1], position[2], position[3]] = k

        println("SUCESS!\n")
        println("Result:")
        display(cube)
        println("\n")
        break
    end

    # Try next direction
    path[k] += 1

    # Don't allow movement in the same axis
    if k > 1 && path[k - 1] % 3 == path[k] % 3
        path[k] += 1
    end

    # We tried all possible combinations here, no luck
    if path[k] > 6
        # Reset path entry
        path[k] = 0

        # Backtrack
        global k -= 1

        # Free indices in cube matrix... Walking cube
        for i = 1 : configuration[k]
            global position -= direction_vectors[path[k], :]

            cube[position[1], position[2], position[3]] = 0
        end

        println("-> backtracking", "\n")
        print_update()
        continue
    end

    println("-> trying movement ", path[k], " (", configuration[k], "x): ", configuration[k] * direction_vectors[path[k], :])

    # Walk cube to check if that movement is physically_possible possible:

    physically_possible = true

    for i = 1 : configuration[k]
        new_position = position + i * direction_vectors[path[k], :]

        if !all([x in 1:3 for x in new_position])
            println("-> outside bounds at ", new_position)
            physically_possible = false
            break
        end

        if cube[new_position[1], new_position[2], new_position[3]] != 0
            println("-> field occupied at ", new_position)
            physically_possible = false
            break
        end
    end

    if !physically_possible
        continue
    end

    # Looks good!

    # Occupy indices in cube matrix... Walking cube
    for i = 1 : configuration[k]
        value = i == 1 ? k : -1 # -1 for intermediary element

        cube[position[1], position[2], position[3]] = value

        global position += direction_vectors[path[k], :]
    end

    # Advance to the next element
    global k += 1

    println("-> success\n")
    print_update()

end
