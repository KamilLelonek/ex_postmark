defmodule ExPostmark.Mailer do
  @moduledoc ~S"""
  Defines a mailer.

  A mailer is a wrapper around an adapter that makes it easy for you to swap the
  adapter without having to change your code.

  It is also responsible for doing some sanity checks before handing down the
  email to the adapter.

  When used, the mailer expects `:otp_app` as an option.
  The `:otp_app` should point to an OTP application that has the mailer
  configuration. For example, the mailer:

      defmodule Sample.Mailer do
        use ExPostmark.Mailer, otp_app: :sample
      end

  Could be configured with:

      config :sample, Sample.Mailer,
        adapter: ExPostmark.Adapters.Postmark,
        api_key: "abc123"

  ## Examples

  Once configured you can use your mailer like this:

      # in an IEx console
      iex> email = new |> from("tony.stark@example.com") |> to("steve.rogers@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, ...}
      iex> Mailer.deliver(email)
      :ok
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      {adapter, config} = ExPostmark.Mailer.parse_config(__MODULE__, opts)

      @adapter adapter
      @config  config

      def deliver!(email) do
        case deliver(email) do
          {:ok,    result}          -> result
          {:error, reason}          -> raise ExPostmark.DeliveryError, reason: reason
          {:error, reason, payload} -> raise ExPostmark.DeliveryError, reason: reason, payload: payload
        end
      end

      def deliver(email),
        do: ExPostmark.Mailer.deliver(@adapter, email, @config)
    end
  end

  @doc """
  Parses the OTP configuration at compile time.
  """
  def parse_config(mailer, opts) do
    otp_app = Keyword.fetch!(opts, :otp_app)
    config  = Application.get_env(otp_app, mailer, [])
    adapter = config[:adapter]

    unless adapter do
      raise ArgumentError, """
                           missing :adapter configuration in
                           config #{inspect otp_app}, #{inspect mailer}
                           """
    end

    {adapter, config}
  end

  def deliver(_adapter, %ExPostmark.Email{from: nil}, _config),
    do: {:error, :from_not_set}
  def deliver(_adapter, %ExPostmark.Email{from: {_name, address}}, _config)
  when address in ["", nil],
    do: {:error, :from_not_set}
  def deliver(adapter, %ExPostmark.Email{} = email, config) do
    :ok = config |> Keyword.delete(:adapter) |> adapter.validate_config()

    adapter.deliver(email, config)
  end
end
