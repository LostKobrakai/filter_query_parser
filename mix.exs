defmodule FilterQueryParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :filter_query_parser,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Filter Query Parser",
      source_url: "https://github.com/LostKobrakai/filter_query_parser",
      homepage_url: "https://github.com/LostKobrakai/filter_query_parser"
    ]
  end

  defp description() do
    "Small library to handle parsing of github style filter queries."
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 0.5"},
      {:ex_doc, "~> 0.16", only: [:dev, :docs], runtime: false}
    ]
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Benjamin Milde"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/LostKobrakai/filter_query_parser"}
    ]
  end
end
