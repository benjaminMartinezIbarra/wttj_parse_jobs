defmodule FileParser do
  @moduledoc """
  A module that provides functions to parse job offers and job descriptions
  from CSV files.

  ## Public functions

  * `get_job_offers/0`: Reads the job offers from `technical-test-jobs.csv`
    and returns the job offers as a list of tuples.

  * `get_job_descriptions/0`: Reads the job descriptions from
    `technical-test-professions.csv` and returns a map with job description
    ID as key and a tuple of job name and category as value.

  """

  # Get the job offers from the CSV file and parse them
  def get_job_offers() do
    {:ok, jobs} = File.read("lib/technical-test-jobs.csv")

    # Split the CSV string into a list of rows, remove the first row (the header), and remove any empty rows
    parsed_job = jobs
                 |> String.split("\n")
                 |> Enum.drop(1)
                 |> Enum.reject(&(&1 == ""))

    parse_job_offers(parsed_job)  # Parse the job offers into a list of maps
  end

  # Get the job descriptions from the CSV file and parse them
  def get_job_descriptions() do
    {:ok, jobs_descriptions} = File.read("lib/technical-test-professions.csv")

    # Split the CSV string into a list of rows, remove the first row (the header), and remove any empty rows
    parsed_jobs_descriptions =
      jobs_descriptions
      |> String.split("\n")
      |> Enum.drop(1)
      |> Enum.reject(&(&1 == ""))

    parse_job_descriptions(parsed_jobs_descriptions)  # Parse the job descriptions into a map of id -> {name, category}
  end

  # Parse a list of job offers into a list of tuples
  def parse_job_offers(job_offers_string) do
    job_offers_string
    |> Enum.map(&String.split(&1, ","))
    |> Enum.reject(&Enum.at(&1, 0) == ""  or Enum.at(&1, 3) == "" or Enum.at(&1, 4) == "")  # Remove rows with missing data
    |> Enum.map(fn(list) ->
      case length(list) do
        5 -> {String.trim(Enum.at(list, 0)),
               String.trim(Enum.at(list, 1)),
               String.trim(String.replace(Regex.replace(~r/\xAD/,Enum.at(list, 2), ""),"\"", "")),  # Replace special character and quotes
               String.trim(Enum.at(list, 3)),
               String.trim(Enum.at(list, 4))}
        n when n > 5 ->
          name = Regex.replace( ~r/\xAD/, Enum.slice(list, 2, n-3)  # Handle job names that span multiple cells
                                          |> Enum.join(",")
                                          |> String.replace("\"", "")
                                          |> String.trim(), "")
          {String.trim(Enum.at(list, 0)),
            String.trim(Enum.at(list, 1)),
            name,
            String.trim(Enum.at(list, n-2)),
            String.trim(Enum.at(list, n-1))}
      end
    end)
  end

  # Parse a list of job descriptions into a map of id -> {name, category}
  def parse_job_descriptions(job_descriptions_string) do
    job_descriptions_string
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(fn([id, name, category]) ->
      {String.trim(id),
        {String.trim(name), String.trim(category)}}
    end)
    |> Enum.into(%{})
  end

end
