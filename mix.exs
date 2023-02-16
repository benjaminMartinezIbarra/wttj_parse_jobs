defmodule CountryJobs.MixProject do
  use Mix.Project

  def project do
    [
      app: :country_jobs,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_files: ["test/**/*.exs"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:mock, "~> 0.3.0", only: :test},
      {:nimble_csv, "~> 1.1"},
      {:httpoison, "~> 2.0"},
      {:poison, "~> 5.0"}
    ]
  end
end
