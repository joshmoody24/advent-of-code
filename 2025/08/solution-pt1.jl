struct Point
    x::Int
    y::Int
    z::Int
end

function parse_point(line::String)
    x, y, z = split(line, ",")
    Point(parse(Int, x), parse(Int, y), parse(Int, z))
end

distance(a::Point, b::Point) =
    sqrt((a.x-b.x)^2 + (a.y-b.y)^2 + (a.z-b.z)^2)

points = [parse_point(line) for line in eachline("input.txt")]

edges = Vector{Tuple{Point,Point,Float64}}()

# cartesian product sorted by distance
for i in points
    for j in points
      if i == j
          continue
      end
      dist = distance(i, j) # could avoid squaring but Julia has vroom vroom to spare
      push!(edges, (i, j, dist))
    end
end
sort!(edges, by = t -> t[3])

circuit_id = 0
circuits = Dict{Point, Int}()

direct_connections = Set{Tuple{Point,Point}}()
function already_directly_connected(i, j)
    return (i, j) in direct_connections || (j, i) in direct_connections
end

# initialize each point to its own circuit
for p in points
    circuits[p] = circuit_id
    global circuit_id += 1
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

stop_after = 1000

for edge in edges
    i, j, dist = edge
    num_connections = length(direct_connections)
    if num_connections >= stop_after break end
    if already_directly_connected(i, j) continue end
    if circuits[i] == circuits[j]
      push!(direct_connections, (j, i))
    else
      println("Merging circuits of points ", i, " and ", j)
      merge_circuits(i, j)
    end
end

println("Number of circuits formed: ", length(unique(values(circuits))))

# for cid in sort(collect(unique(values(circuits)))) 
#     println("Circuit ", cid, ":")
#     for (p, c) in circuits
#         if c == cid
#             println("  Point(", p.x, ", ", p.y, ", ", p.z, ")")
#         end
#     end
# end

circuit_sizes = Dict{Int, Int}()
for c in values(circuits)
    if haskey(circuit_sizes, c)
        circuit_sizes[c] += 1
    else
        circuit_sizes[c] = 1
    end
end

three_largest = sort(collect(values(circuit_sizes)), rev=true)[1:3]
product = prod(three_largest)

println("Sizes of three largest circuits: ", three_largest)
println("Product of sizes of three largest circuits: ", product)

