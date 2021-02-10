defmodule PoolyV3.Server do
  @moduledoc """
  Top level logic
  """
  use GenServer

  require Logger

  # API

  def start_link(pools_config) do
    GenServer.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  def checkout(pool_name) do
    GenServer.call(:"#{pool_name}Server", :checkout)
  end

  def checkin(pool_name, worker_pid) do
    GenServer.cast(:"#{pool_name}Server", {:checkin, worker_pid})
  end

  def status(pool_name) do
    GenServer.call(:"#{pool_name}Server", :status)
  end

  # Callbacks

  def init(pools_config) do
    pools_config
    |> Enum.each(fn pool_config ->
      send(self(), {:start_pool, pool_config})
    end)

    {:ok, pools_config}
  end

  def handle_info({:start_pool, pool_config}, state) do
    # Logger.warn(inspect(state))

    {:ok, _pools_sup} =
      DynamicSupervisor.start_child(
        PoolyV3.PoolsSupervisor,
        # {PoolyV3.PoolSupervisor, pool_config}
        %{
          id: :"#{pool_config[:name]}Supervisor",
          start: {PoolyV3.PoolSupervisor, :start_link, [pool_config]}
        }
      )

    {:noreply, state}
  end
end
