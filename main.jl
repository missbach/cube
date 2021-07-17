#!/usr/bin/env julia

# INPUT

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

# Example 4x4x4 cube:
# configuration = [3, 3, 3, 2, 2, 1, 1,   1, 2, 1, 3, 3, 3, 1, 2,   1, 2, 1, 3, 3, 3, 1, 2,   1, 2, 1, 3, 3, 3, 1, 2]

logging = false

# SETUP

cube_length = Int(cbrt(sum(configuration) + 1))

cube = zeros(Int, cube_length, cube_length, cube_length)
path = zeros(Int, length(configuration))

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

# COMPUTATION

function backtrack()
    # Reset path entry
    if k <= length(path)
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

    if k == length(path) + 1
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

    # Try next direction vector
    path[k] += 1

    # Don't allow movement along the same axis as the previous step
    if k > 1 && path[k - 1] % 3 == path[k] % 3
        path[k] += 1
    end

    # For the first two steps, we only try walking along the first and second
    # direction vectors respectively, since walking in any other direction
    # would still yield the same results, albeit rotated.
    # In code: path[1] == 1 && path[2] == 2 should be true.
    # The value of path[2] will automatically be 2 in the first pass, since we
    # can't repeatedly walk in the same direction (see the other IF statement).
    # So if the conditions are not met, it's because we backtracked here...
    # This means that we've already tried all combinations, so we just abort.
    if k <= 2 && path[k] != k
        println("\n\nABORT at iteration = ", iteration_counter, "\n")
        break
    end

    # We tried all possible combinations here, but no luck
    if path[k] > 6
        backtrack()
        print_update("-> backtracking\n")
        continue
    end

    log("-> trying movement ", path[k], " (", configuration[k], "x): ",
        configuration[k] * direction_vectors[path[k], :])

    # Walk cube to check if that movement is physically_possible possible:

    physically_possible = true

    for i = configuration[k] : -1 : 1
        new_position = position + i * direction_vectors[path[k], :]

        if i == configuration[k] && !all([x in 1 : cube_length for x in new_position])
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
