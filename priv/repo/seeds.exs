case Mix.env() do
  :dev -> Code.eval_file("#{__DIR__}/seeds/dev.exs")
  :prod -> Code.eval_file("#{__DIR__}/seeds/prod.exs")
end
