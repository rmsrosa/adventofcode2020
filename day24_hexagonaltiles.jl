# Advent of Code 2020 - Day 24

test_str = "sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew"

test_list = split(test_str, '\n')

list = readlines("day24_input.txt")


function count_blacks(list)
    blacks = Set()
    for i = 1:length(list)
        steps = list[i]
        for subs in ("ne" => "o", "nw" => "m", "se" => "t", "sw" => "r")
            steps = replace(steps, subs)
        end
        position = [count(==('e'), steps) - count(==('w'), steps) +
                        (count(==('o'), steps) + count(==('t'), steps))//2 -
                        (count(==('m'), steps) + count(==('r'), steps))//2
                    (count(==('o'), steps) + count(==('m'), steps))//2 -
                        (count(==('r'), steps) + count(==('t'), steps))//2]
        if position ∈ blacks
            delete!(blacks, position)
        else
            push!(blacks, position)
        end
    end
    return length(blacks)
end

function count_blacks_int(list)
    blacks = Set()
    for i = 1:length(list)
        steps = replace(replace(replace(replace(list[i], "ne" => "o"), "nw" => "m"), "se" => "t"), "sw" => "r")
        position = [2*(count(==('e'), steps) - count(==('w'), steps)) + count(==('o'), steps) + count(==('t'), steps) - count(==('m'), steps) - count(==('r'), steps)
                    count(==('o'), steps) + count(==('m'), steps) - count(==('r'), steps) - count(==('t'), steps)]
        if position ∈ blacks
            delete!(blacks, position)
        else
            push!(blacks, position)
        end
    end
    return length(blacks)
end

@show count_blacks(test_list) == 10
@show count_blacks(list) == 356
@show count_blacks_int(test_list) == 10
@show count_blacks_int(list) == 356

#= 
# Just a slight gain with an integer lattice
```julia
julia> @btime count_blacks(list);
  1.641 ms (22293 allocations: 1.37 MiB)

julia> @btime count_blacks_int(list);
  1.523 ms (22259 allocations: 1.36 MiB)  
```
 =#

function count_blacks_moving(list, moves)
    blacks = Set()
    function get_neighbors(position)
        displacements = [[1,0], [1//2,1//2], [1//2,-1//2], [-1,0],[-1//2,-1//2],[-1//2,1//2]]
        return [position .+ displacement for displacement in displacements]
    end
    for i = 1:length(list)
        steps = replace(replace(replace(replace(list[i], "ne" => "o"), "nw" => "m"), "se" => "t"), "sw" => "r")
        position = [count(==('e'), steps) - count(==('w'), steps) + (count(==('o'), steps) + count(==('t'), steps))//2 - (count(==('m'), steps) + count(==('r'), steps))//2
                    (count(==('o'), steps) + count(==('m'), steps))//2 - (count(==('r'), steps) + count(==('t'), steps))//2]
        if position ∈ blacks
            delete!(blacks, position)
        else
            push!(blacks, position)
        end
    end
    for n = 1:moves
        new_blacks = Set()
        for position in blacks
            neighbors = get_neighbors(position)
            if length(neighbors ∩ blacks) ∈ (1,2)
                push!(new_blacks, position)
            end
            for neighbor in neighbors
                if neighbor ∉ blacks && length(get_neighbors(neighbor) ∩ blacks) == 2
                    push!(new_blacks, neighbor)
                end
            end
        end
        blacks = new_blacks
    end
    return length(blacks)
end

@show count_blacks_moving(test_list, 100) == 2208
@show count_blacks_moving(list, 100) == 3887

nothing

```julia
julia> @btime count_blacks_moving(list, 100)
  11.514 s (19853339 allocations: 1.87 GiB)
```