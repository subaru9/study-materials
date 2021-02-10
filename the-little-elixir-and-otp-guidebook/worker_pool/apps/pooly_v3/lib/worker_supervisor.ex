defmodule PoolyV3.WorkerSupervisor do
  use DynamicSupervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(pool_sever, init_arg) do
    DynamicSupervisor.start_link(__MODULE__, [pool_sever, init_arg])
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  # Callbacks

  def init([pool_sever, init_arg]) do
    Process.link(pool_sever)

    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5,
      extra_arguments: init_arg
    )
  end
end
