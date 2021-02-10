defmodule PoolyV3.PoolsSupervisor do
  use DynamicSupervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callbacks

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
