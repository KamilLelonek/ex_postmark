defmodule ExPostmark.Adapters.FakeRestAdapter do
  def post(_url, headers, params, [:with_body]),
    do: response(response_code(), headers, params)

  defp response(:error, _headers, _params), do: {:error, "Request error!"}
  defp response(:ok,     headers,  params), do: {:ok, 200, headers, params}
  defp response(code,    headers,  params), do: {:ok, code, headers, params}

  defp response_code(),
    do: Process.get(:response_code)

  def set_response_code(code),
    do: Process.put(:response_code, code)
end
