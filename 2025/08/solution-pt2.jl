using Base.Iterators

struct Point
    x::Int
    y::Int
    z::Int
end

parse_point(line::AbstractString) =
    Point(parse.(Int, split(line, ','))...)

distance2(a::Point, b::Point) =
    (a.x-b.x)^2 + (a.y-b.y)^2 + (a.z-b.z)^2

function main()
    points = [parse_point(line) for line in eachline("input.txt")]

    edges = Vector{Tuple{Point,Point,Float64}}()

    # combinations (didn't want to install combinatorics package)
    for (i, j) in product(points, points)
        if i != j
          dist = distance2(i, j)
          push!(edges, (i, j, dist))
        end
    end
    sort!(edges, by = t -> t[3])

    circuit_id = 0
    circuits = Dict{Point, Int}()

    # initialize each point to its own circuit
    for p in points
        circuits[p] = circuit_id
        circuit_id += 1
    end

    function merge_circuits(i, j)
        id_i = circuits[i]
        id_j = circuits[j]
        for (p, cid) in circuits
            if cid == id_j
                circuits[p] = id_i
            end
        end
    end

    all_in_same_circuit() =
      length(unique(values(circuits))) == 1

    for edge in edges
        i, j, dist = edge
        merge_circuits(i, j)
        if all_in_same_circuit()
            println("Part 2 answer: ", i.x * j.x)
            break
        end
    end
end

main()
