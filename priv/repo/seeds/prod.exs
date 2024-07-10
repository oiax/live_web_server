Logger.configure(level: :warning)

filenames = ~w(
  virtual_hosts
)

Enum.map(filenames, fn filename ->
  IO.puts(filename)
  Code.eval_file("#{__DIR__}/prod/#{filename}.exs")
end)
