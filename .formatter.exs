locals_without_parens = [
  sequence: 2,
  villain: 1
]

[
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens],
  import_deps: [:absinthe, :ecto, :ecto_sql, :phoenix, :plug, :phoenix_html, :distillery],
  inputs: ["/lib/**/*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
