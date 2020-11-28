defmodule Metex.GSVer.Worker do
  @moduledoc """
  Poll weather service
  """

  use GenServer

  @name WeatherWorker

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: @name])
  end

  def get_temperature(location) do
    GenServer.call(@name, {:location, location})
  end

  def get_stats do
    GenServer.call(@name, :get_stats)
  end

  def reset_stats do
    GenServer.cast(@name, :reset_stats)
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:location, location}, _from, stats) do
    {:ok, temp} = location |> temperature_of()

    {
      :reply,
      temp,
      stats |> update_stats(location)
    }
  end

  def handle_call(:get_stats, _from, stats) do
    {
      :reply,
      stats,
      stats
    }
  end

  def handle_cast(:reset_stats, _from, _stats) do
    {
      :noreply,
      %{}
    }
  end

  def handle_cast(:stop, stats) do
    {:stop, :normal, stats}
  end

  def terminate(reason, stats) do
    IO.puts("server terminated because of #{inspect(reason)}")
    inspect(stats)
    :ok
  end

  def handle_info(msg, stats) do
    IO.puts("received #{inspect(msg)}")
    {:noreply, stats}
  end

  ## Helper Functions

  defp update_stats(stats, location) do
    Map.update(stats, location, 1, &(&1 + 1))
  end

  def temperature_of(location) do
    location
    |> url()
    |> request()
    |> parse_response()
  end

  defp url(location) do
    Application.fetch_env!(:weather_service, :base_url)
    |> Kernel.<>(location |> URI.encode())
  end

  defp request(url) do
    :hackney.request(
      :get,
      url,
      [],
      "",
      with_body: true
    )
  end

  defp parse_response({:ok, status, _headers, body}) when status in 200..299 do
    try do
      {:ok, Jason.decode!(body)["main"]["temp"]}
    rescue
      _ -> {:error, {:parsing}}
    end
  end

  defp parse_response({:ok, status, headers, body}) do
    {:error, {:request, status, headers, body}}
  end

  defp parse_response({:error, reason}) do
    {:error, {:network, reason}}
  end
end
