# Example testing file meant to measure the same as was measured in test/perf/perf.jl

function fib(n)
    return n < 2 ? n : fib(n-1) + fib(n-2)
end

function parseintperf(t)
    local n, m
    for i=1:t
        n = rand(Uint32)
        s = hex(n)   
        m = uint32(parseint(s,16))
    end
    @assert n == m
    return m
end

function test_rfib(n=32)
    return @elapsed fib(n)
end

function test_parseintperf(n=1024)
    return @elapsed parseintperf(n)
end

function listTests()
    tests = [{
        "name"=>"rfib",
        "description"=>"Recursive Fibonacci",
        "units"=>"seconds",
        "lessisbetter"=>true
    },{
        "name"=>"parseint",
        "description"=>"Integer Parsing",
        "units"=>"seconds",
        "lessisbetter"=>true
    }]
    return tests
end

function runTests()
    results = Dict()
    results["rfib"] = test_rfib()
    results["parseint"] = test_parseintperf()
    return results
end
