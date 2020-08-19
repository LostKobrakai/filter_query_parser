defmodule FilterQueryParser do
  @moduledoc """
  Small library to handle parsing of github style filter queries.

  ## Examples

      iex> FilterQueryParser.parse("campaign:Lagerverkauf trainer:Josè")
      {:ok, [{"campaign", "Lagerverkauf"}, {"trainer", "Josè"}]}

  """
  import NimbleParsec

  @doc "See module docs for `FilterQueryParser`"
  def parse(query) do
    with {:ok, matches, "", %{}, _, _} <- query |> String.trim() |> parse_query() do
      {:ok, matches |> Enum.map(&List.to_tuple/1)}
    end
  end

  # Prepend equal sign for only integer filters
  defp prepend_equal(_, args, context, _, _), do: {args ++ [:=], context}

  # Build a date struct from the parsed date string values
  defp build_date([year, month, day]) do
    case Date.new(year, month, day) do
      {:ok, date} -> date
      _ -> "invalid-date"
    end
  end

  # field is a lowercase ascii name with more than 2 characters (e.g. is:…)
  field = ascii_string([?a..?z], min: 2)

  # Quoted string value
  # Started with double quotes and terminated by non-escaped ones
  quoted_string =
    ignore(ascii_char([?"]))
    |> repeat(
      lookahead_not(ascii_char([?"]))
      |> choice([
        ~S(\") |> string() |> replace(?"),
        utf8_char([])
      ])
    )
    |> ignore(ascii_char([?"]))
    |> reduce({List, :to_string, []})

  # String value without quotes
  # Terminated by a space character
  string = utf8_string([{:not, String.to_charlist(" ") |> List.first()}], min: 1)

  # Match a string date in YYYY-MM-DD format
  date =
    integer(4)
    |> ignore(string("-"))
    |> integer(2)
    |> ignore(string("-"))
    |> integer(2)
    |> reduce(:build_date)

  # Operators for integer values
  operator =
    choice([
      string("=") |> replace(:==),
      string("==") |> replace(:==),
      string(">=") |> replace(:>=),
      string("<=") |> replace(:<=),
      string(">") |> replace(:>),
      string("<") |> replace(:<)
    ])

  string_starting_with_number =
    optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> optional(string("0"))
    |> integer(min: 1)
    |> utf8_string([], min: 1)
    |> reduce({Enum, :join, [""]})

  # Match integer value and optional operator
  # Default to adding := as operator
  integer =
    choice([
      operator |> integer(min: 1),
      integer(min: 1) |> post_traverse(:prepend_equal)
    ])

  # Parse a query
  defparsec :parse_query,
            field
            |> ignore(ascii_char([?:]))
            |> choice([date, string_starting_with_number, integer, quoted_string, string])
            |> ignore(optional(string(" ")))
            |> wrap()
            |> repeat()
end
