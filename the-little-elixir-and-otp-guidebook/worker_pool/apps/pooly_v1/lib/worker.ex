defmodule PoolyV1.Worker do
  use GenServer

  # API

  def start_link(state) do
    GenServer.start_link(__MODULE__, state)
  end

  def stop(pid) do
    GenServer.call(pid, :stop)
  end

  def child_spec(arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [arg]}
    }
  end

  ## Callbacks

  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_call(:stop, _from, state) do
    {:stop, :normal, :ok, state}
  end
end
