defmodule Mutation.Mixfile do
  use Mix.Project

  def project do
    [
      app: :mutable,
      version: "1.0.3",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "An elixir library that temporarily generates side effects",
      package: [
        maintainers: ["melpon"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/melpon/mutable"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [{:ex_doc, "~> 0.18.3", only: :dev}]
  end
end
