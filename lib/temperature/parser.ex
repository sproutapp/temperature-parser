defmodule Temperature.Parser do

  defmodule Temperature do
    defstruct celsius: 25, fahrenheit: 77, kelvin: 298.15
  end

  def parse(string) do
    temp = value(string)

    %Temperature{
      celsius:    to_celsius(temp),
      fahrenheit: to_fahrenheit(temp),
      kelvin:     to_kelvin(temp)
    }
  end

  defp to_celsius(temp) do
    temp
  end

  defp to_fahrenheit(temp) do
    (temp * 1.8) + 32
  end

  defp to_kelvin(temp) do
    temp + 273.15
  end

  defp value(string) do
    [_, temp] = String.split(string, "::")
    {val, _} = Float.parse(temp)

    val
  end
end
