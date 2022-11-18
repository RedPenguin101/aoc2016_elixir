defmodule Complex do
  def add({a, ai},{b, bi}) do
    {a + b, ai + bi}
  end

  def mult({a, ai}, {b, bi}) do
    {a*b - ai*bi, a*bi + b*ai}
  end

  def smult({a, ai}, b) do
    {a*b, ai*b}
  end

  def abs({a, ai}) do
    Kernel.abs(a) + Kernel.abs(ai)
  end
end
