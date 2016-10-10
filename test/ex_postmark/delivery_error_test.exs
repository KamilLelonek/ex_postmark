defmodule ExPostmark.DeliveryErrorTest do
  use ExUnit.Case, async: true

  alias ExPostmark.DeliveryError

  test "should raise DeliveryError" do
    assert_raise_delivery_error(:from_not_set,  "expected `from` to be set")
    assert_raise_delivery_error(:invalid_email, "expected %ExPostmark.Email{}")
    assert_raise_delivery_error(:api_error,     "api error - response code: 404. body: not found", {404, "not found"})
    assert_raise_delivery_error(:smtp_error,    "smtp error - type: forbidden. message: Access denied", {:forbidden, "Access denied"})
    assert_raise_delivery_error(:whatever,      ":whatever")
  end

  defp assert_raise_delivery_error(reason, message, payload \\ {}) do
    assert_raise(
      DeliveryError,
      "delivery error: " <> message,
      fn -> raise DeliveryError, reason: reason, payload: payload end
    )
  end
end
