defmodule FilterQueryParserTest do
  use ExUnit.Case
  doctest FilterQueryParser

  describe "single filter" do
    test "text value" do
      assert FilterQueryParser.parse("campaign:Lagerverkauf") ==
               {:ok, [{"campaign", "Lagerverkauf"}]}
    end

    test "utf-8 text value" do
      assert FilterQueryParser.parse("campaign:Josè") == {:ok, [{"campaign", "Josè"}]}
    end

    test "quoted text value" do
      assert FilterQueryParser.parse(~s(campaign:"My campaign")) ==
               {:ok, [{"campaign", "My campaign"}]}
    end

    test "text starting with a number" do
      assert FilterQueryParser.parse(~s(name:02/2018)) == {:ok, [{"name", "02/2018"}]}
    end

    test "number" do
      assert FilterQueryParser.parse("slots:3") == {:ok, [{"slots", :=, 3}]}
      assert FilterQueryParser.parse("slots:>=3") == {:ok, [{"slots", :>=, 3}]}
      assert FilterQueryParser.parse("slots:<=3") == {:ok, [{"slots", :<=, 3}]}
    end

    test "date" do
      assert FilterQueryParser.parse("start:2018-03-28") == {:ok, [{"start", ~D[2018-03-28]}]}
      assert FilterQueryParser.parse("start:2018-02-29") == {:ok, [{"start", "invalid-date"}]}
    end
  end

  describe "multiple filters" do
    test "multiple text filters" do
      assert FilterQueryParser.parse("campaign:Lagerverkauf trainer:Josè") ==
               {:ok, [{"campaign", "Lagerverkauf"}, {"trainer", "Josè"}]}
    end

    test "quotes text" do
      assert FilterQueryParser.parse(~s(campaign:"My campaign" trainer:"Benjamin Milde")) ==
               {:ok, [{"campaign", "My campaign"}, {"trainer", "Benjamin Milde"}]}
    end

    test "differnet types" do
      assert FilterQueryParser.parse(~s(campaign:"My campaign" start:2018-03-28)) ==
               {:ok, [{"campaign", "My campaign"}, {"start", ~D[2018-03-28]}]}
    end
  end
end
