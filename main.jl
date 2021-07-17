#!/usr/bin/env julia

# INPUTS

# Real world cube:
configuration = [2, 2, 2, 2, 1, 1, 1, 2, 2, 1, 1, 2, 1, 2, 1, 1, 2]

# Result n° 1 at iteration = 411:
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

logging = false

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

iteration_counter = 0
result_counter = 0

# HELPER FUNCTIONS

function log(args...)
    if logging
        println(args...)
    end
end

function print_update(args...)
    if !logging
        return
    end

    println(args...)

    display(cube)
    println("\n")
    println("Position = ", position)
    println("Element k = ", k, "\n")
end

# COMPUTATIONS

function backtrack()
    # Reset path entry
    if k <= length(configuration)
        path[k] = 0
    end

    # Backtrack
    global k -= 1

    # Free indices in cube matrix... Walking cube
    for i = 1 : configuration[k]
        global position -= direction_vectors[path[k], :]

        cube[position[1], position[2], position[3]] = 0
    end
end

println("STARTING!\n")
print_update()

while true

    if k == length(configuration) + 1
        global result_counter += 1

        cube[position[1], position[2], position[3]] = k

        log("SUCESS!")
        println("\n\nResult n° ", result_counter, " at iteration = ", iteration_counter, ":")
        display(cube)
        println("\n")
        log("Now backtracking again...\n")

        cube[position[1], position[2], position[3]] = 0

        backtrack()
        continue
    end

    global iteration_counter += 1

    if !logging && iteration_counter % 25 == 0
        print(".")
    end

    # Try next direction
    path[k] += 1

    # Don't allow movement in the same axis
    if k > 1 && path[k - 1] % 3 == path[k] % 3
        path[k] += 1
    end

    # We tried all possible combinations here, no luck
    # FYI: For the first element, we only try the first direction since walking
    # in the others would always yield the same results, albeit rotated.
    # TODO The remaining result set my still contain equivalent results that
    # just have been rotated.
    if path[k] > 6 || (k == 1 && path[k] != 1)
        if k == 1
            println("\n\nABORT at iteration = ", iteration_counter, "\n")
            break
        end

        backtrack()

        print_update("-> backtracking\n")
        continue
    end

    log("-> trying movement ", path[k], " (", configuration[k], "x): ",
        configuration[k] * direction_vectors[path[k], :])

    # Walk cube to check if that movement is physically_possible possible:

    physically_possible = true

    for i = 1 : configuration[k]
        new_position = position + i * direction_vectors[path[k], :]

        if !all([x in 1 : cube_length for x in new_position])
            log("-> outside bounds at ", new_position)
            physically_possible = false
            break
        end

        if cube[new_position[1], new_position[2], new_position[3]] != 0
            log("-> field occupied at ", new_position)
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

    print_update("-> success\n")

end
