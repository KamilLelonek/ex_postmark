defmodule ExPostmark.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :ex_postmark,
      version:         "1.0.0",
      elixir:          "~> 1.3",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description:     description(),
      package:         package(),
      deps:            deps(Mix.env),
      elixirc_paths:   elixirc_paths(Mix.env),
    ]
  end

  def application() do
    [
      applications: apps(),
    ]
  end

  defp apps() do
    [
      :logger,
      :poison,
      :hackney,
    ]
  end

  defp deps(:dev) do
    [
      {:ex_doc, ">= 0.0.0"},
    ] ++ deps(:all)
  end

  defp deps(_) do
    [
      {:poison, "~> 3.0"},
      {:hackney, "~> 1.6"},
    ]
  end

  defp description do
    """
    Postmark email adapter for Elixir
    """
  end

  defp elixirc_paths(:test), do: elixirc_paths(:dev) ++ ["test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp package do
    [
      files:       ["lib", "config", "mix.exs", "test", "README.md"],
      maintainers: ["Kamil Lelonek"],
      licenses:    ["MIT"],
      links:       %{ "GitHub" => "https://github.com/KamilLelonek/ex_postmark" },
    ]
  end
end
