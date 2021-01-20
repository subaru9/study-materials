defmodule PoolyV3 do
  @moduledoc """
  Module with convenience functions to start Supervisor
  """
  use Application

  def start(_type, _args) do
    pool_config = [size: 3, worker_mod: PoolyV3.Worker]
    start_pool(pool_config)
  end

  def start_pool(pool_config) do
    PoolyV3.Supervisor.start_link(pool_config)
  end

  def checkout do
    PoolyV3.Server.checkout()
  end

  def checkin(worker_pid) do
    PoolyV3.Server.checkin(worker_pid)
  end

  def status do
    PoolyV3.Server.status()
  end
end
