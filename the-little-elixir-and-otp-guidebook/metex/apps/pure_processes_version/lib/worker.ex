defmodule Metex.PPVer.Worker do
  @moduledoc """
  Poll weather service
  """
  def loop() do
    receive do
      {results_pid, location} ->
        results_pid
        |> send(temperature_of(location))

      _ ->
        IO.puts(:stderr, "Unexpected message received")
    end
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
