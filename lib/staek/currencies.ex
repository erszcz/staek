defmodule Staek.Currencies do
  @currencies File.read!("priv/currencies.csv")
              |> String.split("\n", trim: true)
              |> Enum.filter(&(not String.starts_with?(&1, "#")))
              |> Enum.into(%{}, fn line ->
                [symbol, name] = String.split(line, ",")
                {String.to_atom(symbol), name}
              end)

  @currency_symbols Map.keys(@currencies)

  def name(symbol), do: Map.fetch!(@currencies, symbol)

  defmacro literal_symbols, do: @currency_symbols
end
