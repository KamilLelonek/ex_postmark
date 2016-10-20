defmodule ExPostmark.Adapters.Local.Storage do
  @moduledoc ~S"""
  In-Storage storage driver used by the
  [ExPostmark.Adapters.Local](ExPostmark.Adapters.Local.html) module.
  The emails in this mailbox are stored in Storage and won't persist once your
  application is stopped.
  """
  use GenServer

  @doc """
  Starts the server
  """
  def start_link(state \\ []),
    do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  @doc """
  Stops the server
  """
  def stop(),
    do: GenServer.stop(__MODULE__)

  @doc ~S"""
  Push a new email into the mailbox.
  In order to make it easy to fetch a single email, a `Message-ID` header is
  added to the email before being stored.
  ## Examples
      iex> email = new |> from("tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, [...]}
      iex> Storage.push(email)
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
  """
  def push(email),
    do: GenServer.call(__MODULE__, {:push, email})

  @doc ~S"""
  Pop the last email from the mailbox.
  ## Examples
      iex> email = new |> from("tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, [...]}
      iex> Storage.push(email)
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
      iex> Storage.all() |> Enum.count()
      1
      iex> Storage.pop()
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
      iex> Storage.all() |> Enun.count()
      0
  """
  def pop(),
    do: GenServer.call(__MODULE__, :pop)

  @doc ~S"""
  Get a specific email from the mailbox.
  ## Examples
      iex> email = new |> from("tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, [...]}
      iex> Storage.push(email)
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
      iex> Storage.get("A1B2C3")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
  """
  def get(id),
    do: GenServer.call(__MODULE__, {:get, id})

  @doc ~S"""
  List all the emails in the mailbox.
  ## Examples
      iex> email = new |> from("tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, [...]}
      iex> Storage.push(email)
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
      iex> Storage.all()
      [%ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}]
  """
  def all(),
    do: GenServer.call(__MODULE__, :all)

  @doc ~S"""
  Delete all the emails currently in the mailbox.
  ## Examples
      iex> email = new |> from("tony.stark@example.com")
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, [...]}
      iex> Storage.push(email)
      %ExPostmark.Email{from: {"", "tony.stark@example.com"}, headers: %{"Message-ID": "a1b2c3"}, [...]}
      iex> Storage.delete_all()
      :ok
      iex> Storage.list()
      []
  """
  def delete_all(),
    do: GenServer.call(__MODULE__, :delete_all)

  # Callbacks
  def init(_args),
    do: {:ok, []}

  def handle_call({:push, email}, _from, state) do
    email = ExPostmark.Email.put_headers(email, "Message-ID", random_id())

    {:reply, email, [email] ++ state}
  end

  def handle_call(:pop, _from, [h | t]),
    do: {:reply, h, t}

  def handle_call({:get, id}, _from, state) do
    email = Enum.find(state, nil, &id_matches?(&1, id))

    {:reply, email, state}
  end

  def handle_call(:all, _from, state),
    do: {:reply, state, state}

  def handle_call(:delete_all, _from, _state),
    do: {:reply, :ok, []}

  defp random_id() do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.encode16()
    |> String.downcase()
  end

  defp id_matches?(%ExPostmark.Email{headers: %{"Message-ID" => id}}, id),
    do: true

  defp id_matches?(_email, _id),
    do: false
end
