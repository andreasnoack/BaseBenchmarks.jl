module SortBenchmarks

import BaseBenchmarks
using BenchmarkTrackers

const LIST_SIZE = 50000
const LISTS = (
    (:ascending, collect(1:LIST_SIZE)),
    (:descending, collect(LIST_SIZE:-1:1)),
    (:ones, ones(LIST_SIZE)),
    (:random, rand(MersenneTwister(1), LIST_SIZE))
)

#####################################
# QuickSort/MergeSort/InsertionSort #
#####################################

for (tag, T) in (("quicksort", QuickSort), ("mergesort", MergeSort), ("insertionsort", InsertionSort))

    # sort/sort! #
    #------------#
    @track BaseBenchmarks.TRACKER begin
        @benchmarks begin
            [(:sort, T, kind) => sort(list; alg = T) for (kind, list) in LISTS]
            [(:sort_rev, T, kind) => sort(list; alg = T, rev = true) for (kind, list) in LISTS]
            [(:sort!, T, kind) => sort!(copy(list); alg = T) for (kind, list) in LISTS]
            [(:sort!_rev, T, kind) => sort!(copy(list); alg = T, rev = true) for (kind, list) in LISTS]
        end
        @tags "sort" "sort!" tag
    end

    # sortperm/sortperm! #
    #--------------------#
    @track BaseBenchmarks.TRACKER begin
        @benchmarks begin
            [(:sortperm, T, kind) => sort(list; alg = T) for (kind, list) in LISTS]
            [(:sortperm_rev, T, kind) => sort(list; alg = T, rev = true) for (kind, list) in LISTS]
            [(:sortperm!, T, kind) => sort!(copy(list); alg = T) for (kind, list) in LISTS]
            [(:sortperm!_rev, T, kind) => sort!(copy(list); alg = T, rev = true) for (kind, list) in LISTS]
        end
        @tags "sort" "sort!" "sortperm" "sortperm!" tag
    end
end

############
# issorted #
############

@track BaseBenchmarks.TRACKER begin
    @benchmarks begin
        [(:issorted, kind) => issorted(list) for (kind, list) in LISTS]
        [(:issorted_rev, kind) => issorted(list; rev = true) for (kind, list) in LISTS]
    end
    @tags "sort" "issorted"
end

end # module
