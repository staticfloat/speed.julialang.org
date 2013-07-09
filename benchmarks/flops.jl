# Example testing file meant to measure the same as is measured in base/util.jl/peakflops()

function test_flops(n=1500)
    a = randn(n,n)
    t = @elapsed a*a
    return float64(n)^3/t
end

function listTests()
    tests = [{
        "name"=>"flops",  
        "description"=>"Floating-Point Operations Per Second",
        "units"=>"FlOPS",
        "lessisbetter"=>false
    }]
    return tests
end

function runTests()
    results = Dict()
    results["flops"] = test_flops()
    return results
end
