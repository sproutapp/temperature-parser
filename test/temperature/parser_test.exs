defmodule TemperatureParserTest do
  use Pavlov.Case
  import Pavlov.Syntax.Expect

  describe "Temperature Parser" do
    describe ".parse" do
      let :sample do
        "temperature::25"
      end

      let :parsed do
        Temperature.Parser.parse(sample)
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

      context "Complex inputs" do
        let :sample do
          "temperature::25asdasd::123"
        end

        let :parsed do
          Temperature.Parser.parse(sample)
        end

        it "parses weird inputs" do
          expect(parsed.celsius)
            |> to_eq 25
        end
      end
    end
  end

end
