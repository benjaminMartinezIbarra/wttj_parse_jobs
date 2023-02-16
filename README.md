# CountryJobs

CountryJobs is an Elixir library for regrouping jobs by continent associated with a pair of coordinates
using OpenStreetMap and restcountries APIs. 
The jobs are regrouped by category and continent. The api also gives a total of job counts, per continent, and globaly.
The library supports caching to improve performance and reduce the number of API requests.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `country_jobs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:country_jobs, "~> 0.1.0"}
  ]
end
```
Then, run mix deps.get to fetch the dependency.

## Usage
To use CountryJobs, you can call the job_counts function in module CountryJobs.
The function will fetch 2 excel files, one for job descriptions:

- `id,name,category_name`
- `16,Développement Fullstack,Tech`

and another one for job offers:

- `profession_id,contract_type,name,office_latitude,office_longitude`
- `2,FULL_TIME,Dev Full Stack,48.8768868,2.3091203`

You can add your own data as long as they respect the format provided.

## Reflexion and history of development

The first step in my process was to imagine how it would be easiest to test the final result. I needed a data structure that would allow me to easily read the data, in order to produce the result in the form of an Excel spreadsheet.

My final choice was a map of the following type:
%{"Asia" => %{"total" => 1, "Dev Backend" => 1}, "Europe" => %{"total" => 2, "Tech" => 2}, "total" => 3}

This provides a total of jobs per continent, as well as a global total, which is what was required.

To speed up my development, I first opted for a mock to retrieve the continents (which I have since removed). I knew that the production code had to read an Excel file, so I developed functions that could easily read either a string (representing the file) or the final file itself. The goal was to get results quickly.

Once the unit tests were passed, I added an integration test that aimed to read the physical file. I encountered formatting problems (special characters, job_id, missing coordinates, ',' in names resulting in lines of different sizes...) which I solved as I progressed through the file reading and testing.

Once the file was fully read, I unmocked the service that retrieves continents based on 2 coordinates. I first searched for an implementation that could avoid making API calls. Some implementations may work on the margin, but are not viable for production code. The best solution was therefore to make API calls.

The solution of a cache quickly became evident, at two levels. I assume that companies with fixed coordinates will make different job requests during their lifetime. Therefore, there is a cache per coordinate, and then a cache per country (FR => Europe), which is much more frequently used. In production, it is easy to imagine persisting the cache (REDIS) and gradually making fewer API calls as files are read.
I removed the mock from the test (we should'nt do that), to have real results, and verify caching mechanisms.
Sometimes test fail because of api connection issues. So, these are more 'end to end tests'. In production we should have a separate project to do 'end to end testing'.

The improvement areas for the project are clear. We can stream the file instead of loading it into memory, parallelize the calls as long as we make the accumulator thread-safe, even if we prefer a solution based on the actor model (agents or gen_server). I'll talk about this in the scaling aside.

## Improvements
Some potential improvements to the project include:

- Adding support for multiple APIs to increase reliability and reduce the risk of rate limiting or downtime.
- Adding multithreading to improve performance and reduce response time for multiple requests.
- add streaming capabilities to file reading.

## scaling
Information and sample code are added inside de `scaling` directory.
It is more of an overview solution, with missing pieces of code (implementation details)
It should give a clear understanding on how the complete solution should be done in order to reach scalability constraints.
