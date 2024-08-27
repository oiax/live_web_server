Logger.configure(level: :warning)

filenames = ~w(
  virtual_hosts_and_servers
)

Enum.map(filenames, fn filename ->
  IO.puts(filename)
  Code.eval_file("#{__DIR__}/dev/#{filename}.exs")
end)
