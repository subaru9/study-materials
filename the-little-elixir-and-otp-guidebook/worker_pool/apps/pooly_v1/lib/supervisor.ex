defmodule PoolyV1.Supervisor do
  use Supervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(pool_config) do
    Supervisor.start_link(__MODULE__, pool_config, name: __MODULE__)
  end

  #############
  # Callbacks #
  #############

  def init(pool_config) do
    children = [
      {PoolyV1.Server, [self(), pool_config]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
