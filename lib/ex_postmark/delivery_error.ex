defmodule ExPostmark.DeliveryError do
  defexception [
    reason:  nil,
    payload: nil,
  ]

  def message(%{reason: reason, payload: payload}),
    do: "delivery error: " <> format_error(reason, payload)

  defp format_error(:from_not_set,  _),               do: "expected `from` to be set"
  defp format_error(:invalid_email, _),               do: "expected %ExPostmark.Email{}"
  defp format_error(:api_error,     {code, body}),    do: "api error - response code: #{code}. body: #{body}"
  defp format_error(:smtp_error,    {type, message}), do: "smtp error - type: #{type}. message: #{message}"
  defp format_error(reason,         _),               do: "#{inspect reason}"
end
