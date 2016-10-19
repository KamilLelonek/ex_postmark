defmodule ExPostmark.Email do
  @moduledoc """
  Defines an Email.

  This module defines a `ExPostmark.Email` struct and the main functions for composing an email. As it is the contract for
  the public APIs of ExPostmark it is a good idea to make use of these functions rather than build the struct yourself.

  ## Email fields

  * `from`           - an email address of the sender, example: `{"Tony Stark", "tony.stark@example.com"}`
  * `to`             - an email address for the recipient(s), example: `[{"Steve Rogers", "steve.rogers@example.com"}]`
  * `cc`             - an intended carbon copy recipient(s) of the email, example: `[{"Bruce Banner", "hulk.smash@example.com"}]`
  * `bcc`            - an intended blind carbon copy recipient(s) of the email, example: `[{"Janet Pym", "wasp.avengers@example.com"}]`
  * `reply_to`       - an email address that should receive replies, example: `{"Clints Barton", "hawk.eye@example.com"}`
  * `headers`        - a map of headers that should be included in the email, example: `%{"X-Accept-Language" => "en-us, en"}`
  * `template_id`    - a template to use when sending this message, example: `97854`
  * `template_model` - a model to be applied to the specified template to generate `HtmlBody`, `TextBody`, and `Subject`, example: `%{team: "Avengers"}`

  ## Examples

      email =
        new
        |> to("tony.stark@example.com")
        |> from("bruce.banner@example.com")
        |> template_id(97854)
        |> template_model(%{team: Avengers})

  The composable nature makes it very easy to continue expanding upon a given Email.

      email =
        email
        |> cc({"Steve Rogers", "steve.rogers@example.com"})
        |> cc("wasp.avengers@example.com")
        |> bcc(["thor.odinson@example.com", {"Henry McCoy", "beast.avengers@example.com"}])

  You can also directly pass arguments to the `new/1` function.

      email = new(from: "tony.stark@example.com", to: "steve.rogers@example.com")
  """

  import ExPostmark.Formatter

  defstruct from:           nil,
            to:             [],
            cc:             [],
            bcc:            [],
            reply_to:       nil,
            headers:        %{},
            template_id:    nil,
            template_model: %{}

  @type name    :: String.t
  @type address :: String.t
  @type mailbox :: {name, address}

  @type t :: %__MODULE__{
    from:           mailbox | nil,
    to:             [mailbox],
    cc:             [mailbox] | [],
    bcc:            [mailbox] | [],
    reply_to:       mailbox | nil,
    headers:        map(),
    template_id:    pos_integer(),
    template_model: map()
  }

  @doc """
  Returns a `ExPostmark.Email` struct.

  You can pass a keyword list or a map argument to the function that will be used
  to populate the fields of that struct. Note that it will silently ignore any
  fields that it doesn't know about.

  ## Examples
      iex> new
      %ExPostmark.Email{}

      iex> new(from: "tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}}
      iex> new(from: {"Tony Stark", "tony.stark@example.com"})
      %ExPostmark.Email{from: {"Tony Stark", "tony.stark@example.com"}}

      iex> new(to: "steve.rogers@example.com")
      %ExPostmark.Email{to: [{"", "steve.rogers@example.com"}]}
      iex> new(to: {"Steve Rogers", "steve.rogers@example.com"})
      %ExPostmark.Email{to: [{"Steve Rogers", "steve.rogers@example.com"}]}
      iex> new(to: [{"Bruce Banner", "bruce.banner@example.com"}, "thor.odinson@example.com"])
      %ExPostmark.Email{to: [{"Bruce Banner", "bruce.banner@example.com"}, {"", "thor.odinson@example.com"}]}

      iex> new(cc: "steve.rogers@example.com")
      %ExPostmark.Email{cc: [{"", "steve.rogers@example.com"}]}
      iex> new(cc: {"Steve Rogers", "steve.rogers@example.com"})
      %ExPostmark.Email{cc: [{"Steve Rogers", "steve.rogers@example.com"}]}
      iex> new(cc: [{"Bruce Banner", "bruce.banner@example.com"}, "thor.odinson@example.com"])
      %ExPostmark.Email{cc: [{"Bruce Banner", "bruce.banner@example.com"}, {"", "thor.odinson@example.com"}]}

      iex> new(bcc: "steve.rogers@example.com")
      %ExPostmark.Email{bcc: [{"", "steve.rogers@example.com"}]}
      iex> new(bcc: {"Steve Rogers", "steve.rogers@example.com"})
      %ExPostmark.Email{bcc: [{"Steve Rogers", "steve.rogers@example.com"}]}
      iex> new(bcc: [{"Bruce Banner", "bruce.banner@example.com"}, "thor.odinson@example.com"])
      %ExPostmark.Email{bcc: [{"Bruce Banner", "bruce.banner@example.com"}, {"", "thor.odinson@example.com"}]}

      iex> new(reply_to: "edwin.jarvis@example.com")
      %ExPostmark.Email{reply_to: {"", "edwin.jarvis@example.com"}}
      iex> new(reply_to: {"Edwin Jarvis", "edwin.jarvis@example.com"})
      %ExPostmark.Email{reply_to: {"Edwin Jarvis", "edwin.jarvis@example.com"}}

      iex> new(headers: %{"X-Accept-Language" => "en"})
      %ExPostmark.Email{headers: %{"X-Accept-Language" => "en"}}

      iex> new(template_id: 1)
      %ExPostmark.Email{template_id: 1}

      iex> new(template_model: %{team: "Avengers"})
      %ExPostmark.Email{template_model: %{team: "Avengers"}}

  You can obviously combine these arguments together:

      iex> new(to: "steve.rogers@example.com", template_id: 1)
      %ExPostmark.Email{to: [{"", "steve.rogers@example.com"}], template_id: 1}
  """
  @spec new(none | Enum.t) :: t
  def new(opts \\ []),
    do: Enum.reduce(opts, %__MODULE__{}, &do_new/2)

  defp do_new({key, value}, email)
  when key in ~w(from to cc bcc reply_to template_id)a,
    do: apply(__MODULE__, key, [email, value])

  defp do_new({key, map}, email)
  when key in ~w(headers template_model)a,
    do: Enum.reduce(map, email, &put(&1, &2, key))

  defp do_new({key, value}, _email) do
    raise ArgumentError, message:
    """
    invalid field `#{inspect key}` (value=#{inspect value}) for ExPostmark.Email.new/1.
    """
  end

  defp put({key, value}, email, name),
    do: apply(__MODULE__, :"put_#{name}", [email, key, value])

  @doc """
  Sets a recipient in the `from` field.

  The recipient must be either; a tuple specifying the name and address of the recipient; a string specifying the
  address of the recipient.

  ## Examples

      iex> new |> from({"Steve Rogers", "steve.rogers@example.com"})
      %ExPostmark.Email{bcc: [], cc: [],
       from: {"Steve Rogers", "steve.rogers@example.com"}, headers: %{},
       reply_to: nil, template_id: nil,
       template_model: nil, to: []}

      iex> new |> from("steve.rogers@example.com")
      %ExPostmark.Email{bcc: [], cc: [],
       from: {"", "steve.rogers@example.com"}, headers: %{},
       reply_to: nil, template_id: nil, template_model: nil,
       to: []}
  """
  @spec from(t, mailbox | address) :: t
  def from(%__MODULE__{} = email, from) do
    from = format_recipient(from)

    %{email | from: from}
  end

  @doc """
  Adds new recipients in the `to` field.

  The recipient must be; a tuple specifying the name and address of the recipient; a string specifying the
  address of the recipient; or an array comprised of a combination of either.

  ## Examples

      iex> new |> to("steve.rogers@example.com")
      %ExPostmark.Email{bcc: [], cc: [], from: nil, headers: %{},
       reply_to: nil, template_id: nil,
       template_model: nil, to: [{"", "steve.rogers@example.com"}]}
  """
  @spec to(t, mailbox | address | [mailbox | address]) :: t
  def to(%__MODULE__{to: to} = email, recipients) when is_list(recipients) do
    recipients =
      recipients
      |> Enum.map(&format_recipient(&1))
      |> Enum.concat(to)

    %{email | to: recipients}
  end
  def to(%__MODULE__{} = email, recipient),
    do: to(email, [recipient])

  @doc """
  Puts new recipients in the `to` field.

  It will replace any previously added `to` recipients.
  """
  @spec put_to(t, mailbox | address | [mailbox | address]) :: t
  def put_to(%__MODULE__{} = email, recipients) when is_list(recipients) do
    recipients = Enum.map(recipients, &format_recipient(&1))

    %{email | to: recipients}
  end
  def put_to(%__MODULE__{} = email, recipient),
    do: put_to(email, [recipient])

  @doc """
  Adds new recipients in the `cc` field.

  The recipient must be; a tuple specifying the name and address of the recipient; a string specifying the
  address of the recipient; or an array comprised of a combination of either.

  ## Examples

      iex> new |> cc("steve.rogers@example.com")
      %ExPostmark.Email{bcc: [], cc: [{"", "steve.rogers@example.com"}],
       from: nil, headers: %{}, reply_to: nil,
       template_id: nil, template_model: nil, to: []}
  """
  @spec cc(t, mailbox | address | [mailbox | address]) :: t
  def cc(%__MODULE__{cc: cc} = email, recipients) when is_list(recipients) do
    recipients =
      recipients
      |> Enum.map(&format_recipient(&1))
      |> Enum.concat(cc)

    %{email | cc: recipients}
  end
  def cc(%__MODULE__{} = email, recipient),
    do: cc(email, [recipient])

  @doc """
  Puts new recipients in the `cc` field.

  It will replace any previously added `cc` recipients.
  """
  @spec put_cc(t, mailbox | address | [mailbox | address]) :: t
  def put_cc(%__MODULE__{} = email, recipients) when is_list(recipients) do
    recipients = Enum.map(recipients, &format_recipient(&1))

    %{email | cc: recipients}
  end
  def put_cc(%__MODULE__{} = email, recipient),
    do: put_cc(email, [recipient])

  @doc """
  Adds new recipients in the `bcc` field.

  The recipient must be; a tuple specifying the name and address of the recipient; a string specifying the
  address of the recipient; or an array comprised of a combination of either.

      iex> new |> bcc("steve.rogers@example.com")
      %ExPostmark.Email{bcc: [{"", "steve.rogers@example.com"}], cc: [],
       from: nil, headers: %{}, reply_to: nil,
       template_id: nil, template_model: nil, to: []}
  """
  @spec bcc(t, mailbox | address | [mailbox | address]) :: t
  def bcc(%__MODULE__{bcc: bcc} = email, recipients) when is_list(recipients) do
    recipients =
      recipients
      |> Enum.map(&format_recipient(&1))
      |> Enum.concat(bcc)

    %{email | bcc: recipients}
  end
  def bcc(%__MODULE__{} = email, recipient),
    do: bcc(email, [recipient])

  @doc """
  Puts new recipients in the `bcc` field.

  It will replace any previously added `bcc` recipients.
  """
  @spec put_bcc(t, mailbox | address | [mailbox | address]) :: t
  def put_bcc(%__MODULE__{} = email, recipients) when is_list(recipients) do
    recipients = Enum.map(recipients, &format_recipient(&1))

    %{email | bcc: recipients}
  end
  def put_bcc(%__MODULE__{} = email, recipient),
    do: put_bcc(email, [recipient])


  @doc """
  Sets a recipient in the `reply_to` field.

  The recipient must be either; a tuple specifying the name and address of the recipient; a string specifying the
  address of the recipient.

  ## Examples

      iex> new |> reply_to({"Steve Rogers", "steve.rogers@example.com"})
      %ExPostmark.Email{bcc: [], cc: [], from: nil, headers: %{},
       reply_to: {"Steve Rogers", "steve.rogers@example.com"},
       template_id: nil, template_model: nil, to: []}

      iex> new |> reply_to("steve.rogers@example.com")
      %ExPostmark.Email{bcc: [], cc: [], from: nil, headers: %{},
       reply_to: {"", "steve.rogers@example.com"},
       template_id: nil, template_model: nil, to: []}
  """
  @spec reply_to(t, mailbox | address) :: t
  def reply_to(%__MODULE__{} = email, reply_to) do
    reply_to = format_recipient(reply_to)

    %{email | reply_to: reply_to}
  end

  @doc """
  Adds a new `header` in the email.

  The name and value must be specified as strings.

  ## Examples

      iex> new |> put_headers("X-Magic-Number", "7")
      %ExPostmark.Email{bcc: [], cc: [], from: nil,
       headers: %{"X-Magic-Number" => "7"}, reply_to: nil,
       template_id: nil, template_model: nil, to: []}
  """
  @spec put_headers(t, String.t, String.t) :: t
  def put_headers(%__MODULE__{headers: headers} = email, name, value)
  when is_binary(name) and is_binary(value),
    do: Map.put(email, :headers, Map.put(headers, name, value))
  def put_headers(%__MODULE__{}, name, value) do
    raise ArgumentError, message:
    """
    put_headers/3 expects the header name and value to be strings.

    Instead it got:
      name:  `#{inspect name}`.
      value: `#{inspect value}`.
    """
  end

  @doc """
  Sets the `template_id` field.

  The template ID must be a positive integer that corresponds to the template ID defined in admin panel.

  ## Examples

      iex> new |> template_id(1)
      %ExPostmark.Email{bcc: [], cc: [], from: nil, headers: %{},
       reply_to: nil, template_id: 1,
       template_model: nil, to: []}
  """
  @spec template_id(t, pos_integer()) :: t
  def template_id(%__MODULE__{} = email, template_id)
  when is_binary(template_id),
    do: %{email | template_id: String.to_integer(template_id)}
  def template_id(%__MODULE__{} = email, template_id)
  when is_integer(template_id) and template_id > 0,
    do: %{email | template_id: template_id}
  def template_id(%__MODULE__{}, template_id) do
    raise ArgumentError, message:
    """
    template_id/2 expects the template ID to be a positive integer.

    Instead it got:
      template_id: `#{inspect template_id}`.
    """
  end

  @doc """
  Stores a new **template_model** key and value in the email.

  This store is meant to be for libraries/framework usage. The name should be
  specified as an atom, the value can be any term.

  ## Examples

      iex> new |> put_template_model(:team, "Avengers")
      %ExPostmark.Email{bcc: [], cc: [], from: nil, headers: %{},
       reply_to: nil, template_id: nil,
       template_model: %{team: "Avengers"}, to: []}
  """
  @spec put_template_model(t, atom, any) :: t
  def put_template_model(%__MODULE__{template_model: nil} = email, key, value)
  when is_atom(key) and is_binary(value),
    do: %{email | template_model: %{key => value}}
  def put_template_model(%__MODULE__{template_model: template_model} = email, key, value)
  when is_atom(key) and is_binary(value),
    do: %{email | template_model: Map.put(template_model, key, value)}
  def put_template_model(%__MODULE__{}, key, value) do
    raise ArgumentError, message:
    """
    put_template_model/3 expects the template model key to be an atom and a value to be a string.

    Instead it got:
      key:   `#{inspect key}`.
      value: `#{inspect value}`.
    """
  end
end
