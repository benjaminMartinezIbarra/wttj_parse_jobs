defmodule ContinentFinder do

  @moduledoc """
  This module provides functionality for finding the continent associated with a given latitude and longitude.
  It uses two caches to minimize the number of HTTP requests: one cache associates coordinates with continents,
  and the other associates countries with continents. If a country is not found in the second cache, this module
  uses an external API to retrieve the continent associated with the country.
  """


  def get_continent(latitude, longitude, update_cache_fn, job_offers_continent_cache, job_offers_country_continent_cache) do
    country = get_country(latitude, longitude)
    if country == "Error retrieving country" do
      "Error retrieving country"
    else
    #trying to retrieve the continent associated to the country in this second cache
      case Map.get(job_offers_country_continent_cache,country) do
        nil ->
          continent = get_continent_from_country(country)
          # Update the cache maps
          job_offers_continent_cache = update_cache_fn.(job_offers_continent_cache, {latitude, longitude}, continent)
          job_offers_country_continent_cache = update_cache_fn.(job_offers_country_continent_cache, country, continent)
          {continent, job_offers_continent_cache, job_offers_country_continent_cache}
        continent ->
          {continent, job_offers_continent_cache, job_offers_country_continent_cache}
      end
    end

  end

  defp get_country(latitude, longitude) do
    url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=#{latitude}&lon=#{longitude}"
    response = HTTPoison.get!(url)
    case response.status_code do
      200 ->
        body = Poison.decode!(response.body)
        country = body["address"]["country_code"]
        country
      _ -> "Error retrieving country"
    end
  end

  defp get_continent_from_country(country) do
    url = "https://restcountries.com/v3.1/alpha/#{country}"
    response = HTTPoison.get!(url)
    case response.status_code do
      200 ->
        body = Poison.decode!(response.body)
        [%{"region" => region}] = body
        region
      _ -> "Error retrieving region"
    end
  end

end




