defmodule Metex.PPVer.Results do
  @moduledoc """
  Collects and reports results
  """
  def loop(results \\ []) do
    receive do
      {:ok, result} ->
        loop([result | results])

      {:exit, results_receiver_pid} ->
        message =
          results
          |> Enum.sort()
          |> Enum.join(", ")

        send(results_receiver_pid, {:ok, message})

      _ ->
        IO.puts(:stderr, "Unexpected message received")
        loop(results)
    end
  end
end
