defmodule PoolyV1.WorkerSupervisor do
  use DynamicSupervisor

  ## API

  # Starts a module-based supervisor process with the given module and init_arg.
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__, debug: [:trace])
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  # def child_spec(arg) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :start_link, [arg]}
  #     # restart: :temporary
  #   }
  # end

  #############
  # Callbacks #
  #############

  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      max_restarts: 5,
      max_seconds: 5,
      extra_arguments: init_arg
    )
  end
end
