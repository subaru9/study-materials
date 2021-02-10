defmodule PoolyV3 do
  @moduledoc """
  Module with convenience functions to start Supervisor
  """
  use Application

  def start(_type, _args) do
    pools_config = [
      [name: "Pool1", size: 2, worker_mod: PoolyV3.Worker],
      [name: "Pool2", size: 3, worker_mod: PoolyV3.Worker],
      [name: "Pool3", size: 4, worker_mod: PoolyV3.Worker]
    ]

    start_pools(pools_config)
  end

  def start_pools(pools_config) do
    PoolyV3.Supervisor.start_link(pools_config)
  end

  def checkout(pool_name) do
    PoolyV3.Server.checkout(pool_name)
  end

  def checkin(pool_name, worker_pid) do
    PoolyV3.Server.checkin(pool_name, worker_pid)
  end

  def status(pool_name) do
    PoolyV3.Server.status(pool_name)
  end
end
