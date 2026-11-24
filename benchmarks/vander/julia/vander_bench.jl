#!/usr/bin/env julia
#
# Vandermonde benchmark, Julia version.
#
# Figure 2-1 of Jeff Bezanson, "Abstraction in Technical Computing" (MIT, 2015),
# updated to Julia 1.x syntax.  The original 2015 code was:
#
#     function vander(x, N::Int)
#       x = convert(AbstractVector, x)
#       M = length(x)
#       v = Array(promote_type(eltype(x),Int), M, N)
#       if N > 0
#         v[:, 1] = 1
#       end
#       if N > 1
#         for i = 2:N; v[:, i] = x; end
#         accumulate(multiply, v, v)
#       end
#       return v
#     end
#
#     function accumulate(op, input, output)
#       M, N = size(input)
#       for i = 2:N
#         for j = 1:M
#           output[j,i] = op(input[j,i], input[j,i-1])
#         end
#       end
#     end
#
# Changes: `Array(T, M, N)` -> `Array{T}(undef, M, N)`; `accumulate` renamed to
# `myaccumulate!` (Base exports `accumulate` in Julia 1.x); the column
# assignments are written as explicit loops so that the Julia, Nim and NumPy
# versions all do exactly the same amount of work.

using Printf

multiply(a, b) = a * b

function myaccumulate!(op, input, output)
    M, N = size(input)
    for i = 2:N
        @inbounds for j = 1:M
            output[j, i] = op(input[j, i], input[j, i-1])
        end
    end
    return output
end

function vander(x, N::Int)
    x = convert(AbstractVector, x)
    M = length(x)
    v = Array{promote_type(eltype(x), Int)}(undef, M, N)
    if N > 0
        @inbounds for j = 1:M
            v[j, 1] = 1
        end
    end
    if N > 1
        @inbounds for i = 2:N, j = 1:M
            v[j, i] = x[j]
        end
        myaccumulate!(multiply, v, v)
    end
    return v
end

# --- "with dispatch" variant -------------------------------------------------
# The thesis simulates the case where the compiler cannot infer the type of `v`,
# so the call to `accumulate` has to be dispatched at run time.  `Ref{Any}(v)[]`
# is the standard inference barrier: the value is unchanged, but its type is
# only known at run time, so the call below goes through dynamic dispatch once
# per call (the method that is finally invoked is still fully specialised).

inferencebarrier(@nospecialize(x)) = Ref{Any}(x)[]

function vander_dyn(x, N::Int)
    x = convert(AbstractVector, x)
    M = length(x)
    v = Array{promote_type(eltype(x), Int)}(undef, M, N)
    if N > 0
        @inbounds for j = 1:M
            v[j, 1] = 1
        end
    end
    if N > 1
        @inbounds for i = 2:N, j = 1:M
            v[j, i] = x[j]
        end
        myaccumulate!(multiply, inferencebarrier(v), inferencebarrier(v))
    end
    return v
end

# --- driver ------------------------------------------------------------------

function make_x(m::Int)
    m == 1 && return [1.0]
    return [0.9 + 0.2 * (i - 1) / (m - 1) for i = 1:m]
end

function bench(fn, x, N, iters, reps)
    fn(x, N)                       # warm up / force compilation
    best = Inf
    chk = 0.0
    for _ = 1:reps
        acc = 0.0
        t0 = time_ns()
        for _ = 1:iters
            v = fn(x, N)
            acc += v[N, N]         # keep the result alive
        end
        dt = (time_ns() - t0) / 1e9
        best = min(best, dt)
        chk = sum(fn(x, N))
        @assert acc >= 0.0
    end
    return best, chk
end

function main()
    reps = 5
    cases = [(4, 250_000), (2000, 1)]
    entries = String[]

    for (m, iters) in cases
        x = make_x(m)
        for (label, fn) in (("julia", vander), ("julia (with dispatch)", vander_dyn))
            secs, chk = bench(fn, x, m, iters, reps)
            @printf(stderr, "%-22s %dx%d x%-7d %9.4f s  checksum=%.10e\n",
                    label, m, m, iters, secs, chk)
            push!(entries, """    {"impl": "$label", "size": $m, "iters": $iters, "seconds": $secs, "checksum": $chk}""")
        end
    end

    open("results_julia.json", "w") do io
        println(io, "{")
        println(io, """  "runtime": "Julia $(VERSION)",""")
        println(io, """  "results": [""")
        println(io, join(entries, ",\n"))
        println(io, "  ]")
        println(io, "}")
    end
end

main()
