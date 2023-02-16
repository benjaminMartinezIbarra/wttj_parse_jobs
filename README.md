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


## Improvements
Some potential improvements to the project include:

- Adding support for multiple APIs to increase reliability and reduce the risk of rate limiting or downtime.
- Adding multithreading to improve performance and reduce response time for multiple requests.
- add streaming capabilities to file reading.

## scaling