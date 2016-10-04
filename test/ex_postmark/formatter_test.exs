defmodule ExPostmark.FormatterTest do
  use ExUnit.Case

  alias ExPostmark.Formatter

  describe "successful formatting" do
    test "should format a recipient when both name and email are provided" do
      recipient = {"Foo Bar", "foo@bar.com"}

      assert_formatted(recipient, recipient)
    end

    test "should format a recipient when only email is provided" do
      recipient = "foo@bar.com"

      assert_formatted(recipient, {"", recipient})
    end
  end

  describe "unsuccessful formatting" do
    test "should not format a recipient when it is empty" do
      assert_raise ArgumentError, fn ->
        format_recipient("")
      end
    end
  end

  def assert_formatted(recipient, result),
    do: assert result == format_recipient(recipient)

  def format_recipient(recipient),
    do: Formatter.format_recipient(recipient)
end
