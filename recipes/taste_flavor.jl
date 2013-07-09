#!/usr/bin/env julia

# This runs all files inside `benchmarks/`, takes in the flavor we're testing, along with the commit and branch we're on
# 
# julia ./taste_flavor.jl vanilla master 1234abcd


# Before doing anything, make sure we have these two packages installed
try
    Pkg.init()
    Pkg.add("Curl")
    Pkg.add("JSON")
end

using Curl
using JSON
  
# global variables
codespeed_url = "http://localhost"
numTrials = 5;
time_results = Dict()
flavor = ARGS[1]

# Proactively fill out the code speed json structure.  All this information is constant across all tests
csdata = Dict()
csdata["commitid"] = ARGS[3]
csdata["project"] = "Julia"
csdata["branch"] = ARGS[2]
csdata["executable"] = flavor
csdata["environment"] = chomp(readall(`hostname`))
csdata["result_date"] = join(split(Base.commit_string)[end-1:end], " ")


# Head over to the benchmarks directory and read in the names of all our test files
cd("../benchmarks/")
benchmarks = readdir()

# Iterate over test files, including them and running their runTest() functions
for name in benchmarks
    print( "Warming up $name..." )
    Core.include("$name")

    # Do it once to warm up the JIT
    testMetadata = listTests()
    runTests()

    # Allocate space in time_results for each test defined in this file
    for test in testMetadata
        time_results[test["name"]] = Array(Float64, numTrials);
    end

    print( "Running iterations..." )

    # Store all results into time_results
    for i = 1:numTrials
        print( "$i..." )
        results = runTests()
        for test in testMetadata
            time_results[test["name"]][i] = results[test["name"]]
        end
    end

    # Upload progress to codespeed
    for test in testMetadata
        csdata["benchmark"] = test["name"]
        csdata["result_value"] = mean(time_results[test["name"]])
        csdata["std_dev"] = std(time_results[test["name"]])
        csdata["lessisbetter"] = test["lessisbetter"]
        csdata["units_title"] = test["units"]
        csdata["units"] = test["units"]
        csdata["description"] = test["description"]

        print( "POSTing to $codespeed_url/result/add/json...\n\t$(to_json([csdata]))" )
        ret = Curl.post( "$codespeed_url/result/add/json/", {:json => to_json([csdata])} )
        if( !ismatch(r".*202 ACCEPTED.*", ret.headers[1][1]) )
            warn("Error submitting $(test["name"])! Saving error page to /tmp/julia_$(flavor)_$(test["name"])_codespeed.html")
            f = open("/tmp/julia_$(flavor)_$(test["name"])_codespeed.html", "w")
            write( f, ret.text )
            close( f )
            f = open("/tmp/julia_$(flavor)_$(test["name"])_codespeed.header.txt", "w")
            write( f, ret.headers[1] )
            close( f )
        end
        print('\n')
    end
end
