defmodule ExPostmark do
  use Application

  import Supervisor.Spec, warn: false

  def  start(_, _), do: Supervisor.start_link(children(), options())
  defp options(),   do: [strategy: :one_for_one, name: ExPostmark.Supervisor]
  defp children(),  do: []
end
