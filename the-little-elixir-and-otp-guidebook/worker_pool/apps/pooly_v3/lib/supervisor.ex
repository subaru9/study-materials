defmodule PoolyV3.Supervisor do
  use Supervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(pools_config) do
    Supervisor.start_link(__MODULE__, pools_config, name: __MODULE__)
  end

  #############
  # Callbacks #
  #############

  def init(pools_config) do
    children = [
      {PoolyV3.PoolsSupervisor, []},
      {PoolyV3.Server, pools_config}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
