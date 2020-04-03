defmodule Webserver.MixProject do
  use Mix.Project

  def project do
    [
      app: :webserver,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy, :logger, :yaml_elixir],
      mod: {Webserver.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  def deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:yaml_elixir, "~> 2.4"},
      {:jason, "~> 1.2"},
      {:postgrex, "~> 0.15.3"},
      {:httpoison, "~> 1.6"}
    ]
  end
end
