defmodule PPVer.MixProject do
  use Mix.Project

  def project do
    [
      app: :pure_processes_version,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, github: "michalmuskala/jason", override: true},
      {:hackney, github: "benoitc/hackney"},
      {:credo, github: "rrrene/credo"}
    ]
  end
end
