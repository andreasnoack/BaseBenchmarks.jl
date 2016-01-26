module ArrayBenchmarks

import ..BaseBenchmarks
using ..BenchmarkTrackers
using ..BaseBenchmarks.samerand

############
# indexing #
############

# PR #10525 #
#-----------#

include("sumindex.jl")

@track BaseBenchmarks.TRACKER "array index sum" begin
    @setup begin
        int_arrs = (makearrays(Int32, 3, 5)..., makearrays(Int32, 300, 500)...)
        float_arrs = (makearrays(Float32, 3, 5)..., makearrays(Float32, 300, 500)...)
        arrays = (int_arrs..., float_arrs...)
    end
    @benchmarks begin
        [(:sumelt, string(typeof(A)), size(A)) => perf_sumelt(A) for A in arrays]
        [(:sumeach, string(typeof(A)), size(A)) => perf_sumeach(A) for A in arrays]
        [(:sumlinear, string(typeof(A)), size(A)) => perf_sumlinear(A) for A in arrays]
        [(:sumcartesian, string(typeof(A)), size(A)) => perf_sumcartesian(A) for A in arrays]
        [(:sumcolon, string(typeof(A)), size(A)) => perf_sumcolon(A) for A in arrays]
        [(:sumrange, string(typeof(A)), size(A)) => perf_sumrange(A) for A in arrays]
        [(:sumlogical, string(typeof(A)), size(A)) => perf_sumlogical(A) for A in arrays]
        [(:sumvector, string(typeof(A)), size(A)) => perf_sumvector(A) for A in arrays]
    end
    @tags "array" "sum" "indexing" "simd"
end

# Issue #10301 #
#--------------#

include("loadindex.jl")

@track BaseBenchmarks.TRACKER "array index load" begin
    @setup n = 10^6
    @benchmarks begin
        (:rev_load_slow!,) => perf_rev_load_slow!(samerand(n))
        (:rev_load_fast!,) => perf_rev_load_fast!(samerand(n))
        (:rev_loadmul_slow!,) => perf_rev_loadmul_slow!(samerand(n), samerand(n))
        (:rev_loadmul_fast!,) => perf_rev_loadmul_fast!(samerand(n), samerand(n))
    end
    @tags "array" "load" "indexing" "reverse"
end

###############################
# SubArray (views vs. copies) #
###############################

include("subarray.jl")

# LU factorization with complete pivoting. These functions deliberately allocate
# a lot of temprorary arrays by working on vectors instead of looping through
# the elements of the matrix. Both a view (SubArray) version and a copy version
# are provided.
@track BaseBenchmarks.TRACKER "array subarray" begin
    @setup sizes = (100, 250, 500, 1000)
    @benchmarks begin
        [(:lucompletepivCopy!, n) => perf_lucompletepivCopy!(samerand(n, n)) for n in sizes]
        [(:lucompletepivSub!, n) => perf_lucompletepivSub!(samerand(n, n)) for n in sizes]
    end
    @tags "lucompletepiv" "array" "linalg" "copy" "subarray" "factorization"
end

#################
# concatenation #
#################

include("cat.jl")

@track BaseBenchmarks.TRACKER "array cat" begin
    @setup begin
        sizes = (5, 500)
        arrays = map(n -> samerand(n, n), sizes)
    end
    @benchmarks begin
        [(:hvcat, size(A, 1)) => perf_hvcat(A, A) for A in arrays]
        [(:hvcat_setind, size(A, 1)) => perf_hvcat_setind(A, A) for A in arrays]
        [(:hcat, size(A, 1)) => perf_hcat(A, A) for A in arrays]
        [(:hcat_setind, size(A, 1)) => perf_hcat_setind(A, A) for A in arrays]
        [(:vcat, size(A, 1)) => perf_vcat(A, A) for A in arrays]
        [(:vcat_setind, size(A, 1)) => perf_vcat_setind(A, A) for A in arrays]
        [(:catnd, n) => perf_catnd(n) for n in sizes]
        [(:catnd_setind, n) => perf_catnd_setind(n) for n in sizes]
    end
    @tags "array" "indexing" "cat" "hcat" "vcat" "hvcat" "setindex"
end

#################
# comprehension #
#################

# Issue #13401 #
#--------------#

perf_compr_collect(X) = [x for x in X]
perf_compr_iter(X) = [sin(x) + x^2 - 3 for x in X]
perf_compr_index(X) = [sin(X[i]) + (X[i])^2 - 3 for i in eachindex(X)]

@track BaseBenchmarks.TRACKER "array comprehension" begin
    @setup begin
        order = 7
        ls = linspace(0,1,10^order)
        rg = 0.0:(10.0^(-order)):1.0
        arr = collect(ls)
        iters = (ls, arr, rg)
    end
    @benchmarks begin
        [(:collect, string(typeof(i))) => collect(i) for i in iters]
        [(:comprehension_collect, string(typeof(i))) => perf_compr_collect(i) for i in iters]
        [(:comprehension_iteration, string(typeof(i))) => perf_compr_iter(i) for i in iters]
        [(:comprehension_indexing, string(typeof(i))) => perf_compr_index(i) for i in iters]
    end
    @tags "array" "comprehension" "iteration" "indexing" "linspace" "collect" "range"
end

end # module
