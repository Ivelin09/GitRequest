defmodule App do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__) 
  end 

  def init(args) do
    {:ok, args}
  end 

  def example do
    GenServer.call(__MODULE__, {:state, 2});
  end

  def pull(username) do
      api  = GenServer.call(__MODULE__, {:state, username})

      user= (if api == nil do
        {:ok, apiRequest} = HTTPoison.get("https://api.github.com/users/#{username}")
        GenServer.cast(__MODULE__, {:push, apiRequest})
        apiRequest
      else
        api
      end)
      user
  end 

  def lookup(username) do 
    GenServer.call(__MODULE__, {:state, username}) 
  end 

  def check([], _key), do: nil
  def check([h|t], key) do
      IO.inspect(h)
   if Jason.decode!(h.body)["login"] == key do 
      IO.inspect(h)
      h
     else 
      check(t, key) 
     end
    
  end 


  def handle_call({:state, key}, _from, state) do
    kekw = check(state, key)
    IO.inspect(kekw)
    {:reply, check(state, key), state}
  end 

  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end 
  
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end

end 