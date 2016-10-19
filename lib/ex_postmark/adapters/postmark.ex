defmodule ExPostmark.Adapters.Postmark do
  @moduledoc ~S"""
  An adapter that sends email using the Postmark API.
  For reference: [Postmark API docs](http://developer.postmarkapp.com/developer-send-api.html)
  ## Example

      # config/config.exs
      config :sample, Sample.Mailer,
        adapter:          ExPostmark.Adapters.Postmark,
        server_api_key: "my-api-key"

      # lib/sample/mailer.ex
      defmodule Sample.Mailer do
        use ExPostmark.Mailer, otp_app: :sample
      end
  """
  use ExPostmark.Adapter, required_config: [:server_api_key]

  alias ExPostmark.Email

  @base_url     "https://api.postmarkapp.com"
  @api_endpoint "/email/withTemplate"

  def deliver(%Email{} = email, config) do
    headers = prepare_headers(config)
    params  = prepare_body(email)

    send_email(headers, params)
  end

  defp prepare_headers(config) do
    [
      {"User-Agent",              "ex_postmark"},
      {"X-Postmark-Server-Token", config[:server_api_key]},
      {"Content-Type",            "application/json"},
      {"Accept",                  "application/json"}
    ]
  end

  defp prepare_body(email),
    do: email |> body() |> Poison.encode!()

  def body(email) do
    Map.new()
    |> prepare_from(email)
    |> prepare_to(email)
    |> prepare_cc(email)
    |> prepare_bcc(email)
    |> prepare_reply_to(email)
    |> prepare_template_id(email)
    |> prepare_template_model(email)
  end

  defp prepare_from(body, %Email{from: {_name, from}}), do: Map.put(body, "From", from)

  defp prepare_to(body, %Email{to: to}), do: Map.put(body, "To", prepare_recipients(to))

  defp prepare_cc(body, %Email{cc: []}), do: body
  defp prepare_cc(body, %Email{cc: cc}), do: Map.put(body, "Cc", prepare_recipients(cc))

  defp prepare_bcc(body, %Email{bcc: []}),  do: body
  defp prepare_bcc(body, %Email{bcc: bcc}), do: Map.put(body, "Bcc", prepare_recipients(bcc))

  defp prepare_reply_to(body, %Email{reply_to: nil}),      do: body
  defp prepare_reply_to(body, %Email{reply_to: reply_to}), do: Map.put(body, "ReplyTo", prepare_recipient(reply_to))

  defp prepare_recipients(recipients) do
    recipients
    |> Enum.map(&prepare_recipient(&1))
    |> Enum.join(",")
  end

  defp prepare_recipient({"",   address}), do: address
  defp prepare_recipient({name, address}), do: "\"#{name}\" <#{address}>"

  defp prepare_template_id(body, %Email{template_id: nil}), do: body
  defp prepare_template_id(body, %Email{template_id: val}), do: Map.put(body, "TemplateId", val)

  defp prepare_template_model(body ,%Email{template_model: nil}), do: body
  defp prepare_template_model(body ,%Email{template_model: val}), do: Map.put(body, "TemplateModel", val)

  defp send_email(headers, params) do
    case post_request(headers, params) do
      {:ok, 200, _headers, body} ->
        {:ok, %{id: Poison.decode!(body)["MessageID"]}}
      {:ok, code, _headers, body} ->
        {:error, {code, Poison.decode!(body)}}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp post_request(headers, params),
    do: rest_adapter().post(url(), headers, params, [:with_body])

  defp rest_adapter(),
    do: Application.get_env(:ex_postmark, :rest_adapter)

  defp url(), do: [@base_url, @api_endpoint]
end
