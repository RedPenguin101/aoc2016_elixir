defmodule Parsing do
  import String

  def parse_file(filename, row_parser \\ &Function.identity/1) do
    File.read!(filename)
    |> trim
    |> split("\n")
    |> Enum.map(row_parser)
  end

  def row_parse_comma_sep(string) do
    string
    |> trim
    |> split(", ")
  end

  def row_parse_integers(string) do
    string
    |> trim
    |> split
    |> Enum.map(&to_integer/1)
  end
end
