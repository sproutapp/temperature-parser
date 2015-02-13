defmodule TemperatureParserTest do
  use Pavlov.Case
  import Pavlov.Syntax.Expect
  import Temperature.Parser

  describe "Temperature Parser" do
    describe ".parse" do
      let :parsed do
        import Temperature.Parser
        parse("temperature::25")
      end

      it "parses to Celsius" do
        expect(parsed.celsius)
          |> to_eq 25
      end

      it "parses to Fahrenheit" do
        expect(parsed.fahrenheit)
          |> to_eq 77
      end

      it "parses to Kelvin" do
        expect(parsed.kelvin)
          |> to_eq 298.15
      end

      context "When given a malformed input" do
        it "raises an ArgumentError" do
          expect fn -> parse("panic!!") end
            |> to_have_raised ArgumentError

          expect fn -> parse("temperature::25asdasd::123") end
            |> to_have_raised ArgumentError
        end
      end
    end
  end

end
