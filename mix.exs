defmodule Temperature.Mixfile do
  use Mix.Project

  def project do
    [app: :temperature,
     version: "0.0.1",
     elixir: "~> 1.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:microbrew],
     mod: {Temperature, []}
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      { :pavlov, only: :test },
      { :microbrew, git: "git://github.com/sproutapp/microbrew.ex.git" },
      { :exrm, "~> 0.14.16" }
    ]
  end
end
