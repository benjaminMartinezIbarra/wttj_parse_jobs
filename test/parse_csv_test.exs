defmodule CountryJobsTest do
  use ExUnit.Case, async: false
  import Mock

  test "calculates job counts per continent, no jobs" do

    job_offers = []
    job_descriptions = %{"1"=> {"Développement Fullstack","Tech"}}
    job_counts = CountryJobs.job_counts(job_offers, job_descriptions)
    assert job_counts == %{}
  end


  test "calculates job counts per continent, simple category" do

    job_offers = [{"1","FULL_TIME","Dev Full Stack","48.8768868","2.3091203"}, {"1","PART_TIME","Dev Backend","51.5074","0.1278"}]
    job_descriptions = %{"1"=> {"Développement Fullstack","Tech"}}
    job_counts = CountryJobs.job_counts(job_offers, job_descriptions)
    assert job_counts == %{"Europe" => %{"Tech" => 2, "total" => 2},"total" => 2}

  end

  test "calculates job counts per continent, two categories" do

    job_offers = [{"1","FULL_TIME","Dev Full Stack","48.8768868","2.3091203"}, {"3","PART_TIME","Dev Backend","51.5074","0.1278"}]
    job_descriptions =
      %{"1"=> {"Développement Fullstack","Tech"},
        "2"=> {"Medical","Nurse"},
        "3"=> {"Tech","Dev Backend"}
      }
    job_counts = CountryJobs.job_counts(job_offers, job_descriptions)
    assert job_counts == %{"Europe" => %{"Tech" => 1,"Dev Backend" => 1, "total" => 2}, "total" => 2}
  end

  test "calculates job counts per continent, two categories, multiple continents" do

    job_offers = [{"1","FULL_TIME","Dev Full Stack","48.8768868","2.3091203"}, {"3","PART_TIME","Dev Backend Pekin","39.9042","116.4074"}, {"1","PART_TIME","Dev Backend Madrid","48.8768868","2.3091203"}]
    job_descriptions =
      %{"1"=> {"Développement Fullstack","Tech"},
        "2"=> {"Medical","Nurse"},
        "3"=> {"Tech","Dev Backend"}
      }

      job_counts = CountryJobs.job_counts(job_offers, job_descriptions)
      assert job_counts ==  %{"Asia" => %{"total" => 1, "Dev Backend" => 1}, "Europe" => %{"total" => 2, "Tech" => 2}, "total" => 3}

  end

  test "calculates job counts per continent, two categories, multiple continents, from excel file" do

      job_counts = CountryJobs.job_counts()

      assert job_counts ==  %{
               "Americas" => %{"Retail" => 1, "total" => 1},
               "Europe" => %{"Business" => 3, "Marketing / Comm'" => 2, "Tech" => 2, "total" => 7},
               "total" => 8}

  end

end
