defmodule Metex.PPVer.Coordinator do
  @moduledoc """
  Coordinates spawning and processes communication
  """

  alias Metex.PPVer.Results
  alias Metex.PPVer.Worker

  def temperature_of(cities \\ ~w(kyiv vyshgorod osaka)) do
    results_pid = spawn(Results, :loop, [])

    Enum.each(cities, fn city ->
      worker_pid = spawn(Worker, :loop, [])
      send(worker_pid, {results_pid, city})
    end)

    send(results_pid, {:exit, self()})

    receive do
      {:ok, temperature} ->
        IO.puts(:stdio, "In coordinator: " <> inspect(temperature))

      _ ->
        IO.puts(:stderr, "Unexpected message received")
    end
  end
end
