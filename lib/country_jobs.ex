defmodule CountryJobs do
  @moduledoc """
  The `CountryJobs` module provides functions for counting job offers by continent and category.

    ## Usage

    To use `CountryJobs`, call the `job_counts/0` function. This function will call the `FileParser` module to get job offers and descriptions, and then calculate job counts by continent and category.

    ## Example
  iex> CountryJobs.job_counts()
  %{
  "Asia" => %{
  "engineering" => 2,
  "total" => 2
  },
  "Europe" => %{
  "marketing" => 1,
  "engineering" => 1,
  "total" => 2
  },
  "total" => 4
  }
  ## Function Reference

  * `job_counts/0`: Calls the `job_counts/2` function with job offers and descriptions from the `FileParser` module.
  * `job_counts/2`: Calculates job counts by continent and category for the given job offers and descriptions.
  * `update_cache/3`: Updates a cache with a given key-value pair.
  """


    # This function is a wrapper for the `job_counts/2` function that calls `FileParser` to get job offers and descriptions
  def job_counts() do
    job_counts(FileParser.get_job_offers(), FileParser.get_job_descriptions())
  end

  # This is the main function that calculates job counts by continent and category
  def job_counts(job_offers, job_descriptions) do
    job_counts = %{} # Initialize a map to store job counts by continent and category

    # Initialize two caches to store continent information for job offers
    coordinated_continent_cache = %{}
    country_continent_cache = %{}

    # Iterate through each job offer and update the `job_counts` map
    {total_counts, _,_} = job_offers
                          |> Enum.reduce({job_counts,coordinated_continent_cache, country_continent_cache} , fn({profession_id, _contract_type, _name, office_latitude, office_longitude}, acc) ->
      {job_counts, cache_coords, cache_country} = acc

      # Get the job description for this job offer
      {name, category} = Map.get(job_descriptions, profession_id)

      # Determine the continent based on the latitude and longitude
      {continent,  job_offers_continent_cache,  job_offers_country_continent_cache} =
        ContinentFinder.get_continent(office_latitude, office_longitude, &update_cache/3, cache_coords, cache_country)

      # Update the job counts for the continent and category
      job_counts = Map.update(job_counts, continent, %{category => 1, "total" => 1}, fn(counts) ->
        counts = Map.update(counts, category, 1, & &1 + 1)
        counts = Map.update(counts, "total", 1, & &1 + 1) end)
      job_counts = Map.update(job_counts, "total", 1, fn(total) -> total + 1 end)

      # Return the updated job counts and cache information
      {job_counts, job_offers_continent_cache,  job_offers_country_continent_cache}
    end)

    total_counts # Return the total number of job offers
  end

  # This function updates a cache with a given key-value pair
  def update_cache(cache, key, value) do
    Map.put(cache, key, value)
  end

end