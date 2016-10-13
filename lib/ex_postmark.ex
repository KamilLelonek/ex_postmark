defmodule ExPostmark do
  use Application

  import Supervisor.Spec, warn: false

  def  start(_type, _args), do: Supervisor.start_link(children(), options())

  defp options() do
    [
      strategy: :one_for_one,
      name:     ExPostmark.Supervisor,
    ]
  end

  defp children() do
    [
      worker(ExPostmark.Adapters.Local.Storage, []),
    ]
  end
end
