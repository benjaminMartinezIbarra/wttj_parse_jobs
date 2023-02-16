defmodule JobFinder do
  @moduledoc """
  The `JobFinder` application is designed to efficiently process and manage job data for multiple continents and job categories.

  By spawning a series of `ContinentJobManager` and `CategoryJobManager` processes and using message passing between them,
  the application can efficiently handle large volumes of job data and provide instant results for job counts by continent and category.

  a persistence layer to store job data should be added to store the data periodically.
    When an actor is restarted it should build itself from the state in the database.

    """

end


defmodule JobStreamer do
  # caller should create a ContinentJobManager for each continent
  # Spawn an ExcelStream actor to handle the file, with the list of all ContinentJobManager actors
  def start(continent_job_managers) do
    # Read the Excel file line by line and parse each line
    # For each line, extract the continent and send the line to the corresponding ContinentJobManager
    Stream.resource(
      fn -> File.stream!("jobs.xlsx") end,
      &process_line/1,
      fn -> :timer.sleep(500) end
    )
    |> Stream.map(&{&1.continent, &1.job})
    |> Enum.each(fn {continent, job} ->
      GenServer.cast(continent_job_managers[continent], {:add_job, job})
    end)
  end

  # Parse a line of the Excel file and extract the continent and job information
  def process_line(line) do
    [profession_id, contract_type, name, latitude, longitude] = line
    continent = getContinent(latitude, longitude)
    %{continent: continent, job: {profession_id, contract_type, name, latitude, longitude}}
  end
end

defmodule GetContinent do
  def start_link do
    # spawn process to handle requests for continent by name
    # if continent exists in cache, return it
    # else, make a request to an external API to get the continent and cache it
    # ...
  end
end

defmodule ContinentJobManager do
  # Start a ContinentJobManager actor for a given continent, with a list of all CategoryJobManager actors
  def start_link(continent_name) do
    GenServer.start_link(__MODULE__, %{continent_name: continent_name, jobs_per_category: %{}, category_job_managers: %{}, total_jobs: 0}, [])
  end

    # Handle the message to add a job for a given category
    def handle_cast({:add_job, job_info}, state) do
         # Determine the category for the job
         category_name = get_category_name(job)
         # Get or start the category job manager for this category
         category_job_manager =
         state.category_job_managers
         |> Map.get(category_name)
         |> case do
               nil ->
               {:ok, pid} = CategoryJobManager.start_link(category_name)
                            Map.put(state.category_job_managers, category_name, pid)
               pid
               pid -> pid
               end

         # Call :add_job on the category job manager
         {:job_added, category_name, job_count} = GenServer.call(category_job_manager, {:add_job, job})

        # Update state with new job count
        new_state = state
        |> Map.put(:total_jobs, state.total_jobs + job_count)
        |> Map.update(:jobs, [], &([job | &1]))

       # Send message to caller with category name and number of jobs added
       {:noreply, {:job_added, state.category_name, job_count}, new_state}
  end

def handle_call(:get_jobs, _from, state) do
               {:reply, state, state}
               end

end

defmodule CategoryJobManager do
       # Start a CategoryJobManager actor for a given category
       def start_link(category_name) do
       GenServer.start_link(__MODULE__, %{category_name: category_name, total_jobs: 0, jobs: []}, [])
       end

       # Handle the message to add a job for this category
       def handle_call({:add_job, job}, _from, state) do
      # Update state with new job and total jobs
      new_jobs = [job | state.jobs]
      new_state = %{state | total_jobs: state.total_jobs + 1, jobs: new_jobs}

      # Send message to caller with category name and number of jobs added
      {:reply, {:job_added, state.category_name, 1}, new_state}

      end
       end

defmodule JobReader do
  def start_link do
    # spawn process to handle requests for job information by category_name and total job count for the continent
    # send request to the appropriate ContinentJobManager actor
    # ...
  end
  # Handle the message to get the total job count for a given continent
  def get_total_jobs(continent_name) do
     continent_manager = get_continent_manager(continent_name)
     GenServer.call(continent_manager, :get_jobs)
     end

     defp get_continent_manager(continent_name) do
      # retrieve correct continentManager
     end
end
