defmodule ExPostmark.Formatter do
  def format_recipient(nil),      do: raise_invalid_recipient(nil)
  def format_recipient(""),       do: raise_invalid_recipient("")
  def format_recipient({_, nil}), do: raise_invalid_recipient(nil)
  def format_recipient({_, ""}),  do: raise_invalid_recipient("")

  def format_recipient({name, address} = recipient)
  when is_binary(name) and is_binary(address),
    do: recipient

  def format_recipient(recipient)
  when is_binary(recipient),
    do: {"", recipient}

  def format_recipient(invalid),
    do: raise_invalid_recipient(invalid)

  defp raise_invalid_recipient(invalid) do
    raise ArgumentError, message:
    """
    The recipient `#{inspect invalid}` is invalid.
    Recipients must be a string representing an email address
    like `foo.bar@example.com` or a two-element tuple `{name, address}`,
    where name and address are strings.
    """
  end
end
