defmodule ExPostmark.AdapterTest do
  use ExUnit.Case, async: true

  alias ExPostmark.Adapter

  defmodule FakeAdapter do
    use Adapter, required_config: [:api_key]

    def deliver(email, _config), do: {:ok, email}
  end

  test "should provide a required config" do
    assert :ok = FakeAdapter.validate_config(api_key: "123")
  end

  test "should not provide a required config" do
    config = []

    assert_raise(
      ArgumentError,
      "expected [:api_key] to be set, got: #{inspect config}",
      fn -> FakeAdapter.validate_config(config) end
    )
  end

  test "should provide an invalid config" do
    assert_raise(
      ArgumentError,
      "expected [:api_key] to be set, got: [:test]",
      fn -> FakeAdapter.validate_config([test: :test]) end
    )
  end
end
