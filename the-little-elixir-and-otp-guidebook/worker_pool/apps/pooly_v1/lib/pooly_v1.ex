defmodule PoolyV1 do
  @moduledoc """
  Module with convenience functions to start Supervisor
  """
  use Application

  def start(_type, _args) do
    pool_config = [size: 3, worker_mod: PoolyV1.Worker]
    start_pool(pool_config)
  end

  def start_pool(pool_config) do
    PoolyV1.Supervisor.start_link(pool_config)
  end

  def checkout do
    PoolyV1.Server.checkout()
  end

  def checkin(worker_pid) do
    PoolyV1.Server.checkin(worker_pid)
  end

  def status do
    PoolyV1.Server.status()
  end
end
