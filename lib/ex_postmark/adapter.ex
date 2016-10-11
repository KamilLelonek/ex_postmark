defmodule ExPostmark.Adapter do
  @moduledoc ~S"""
  Specification of the email delivery adapter.
  """
  @type t     :: module
  @type email :: Email.t

  @doc """
  Delivers an email.
  """
  @callback deliver(email) :: {:ok, term} | {:error, term}

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @required_config opts[:required_config] || []

      @behaviour ExPostmark.Adapter

      def validate_config(config),
        do: config |> Keyword.keys() |> raise_on_missing_config()

      defp raise_on_missing_config(@required_config),
        do: :ok
      defp raise_on_missing_config(keys),
        do: raise ArgumentError, "expected #{inspect @required_config} to be set, got: #{inspect keys}"
    end
  end
end
