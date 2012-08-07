require 'em-websocket'

EventMachine.run {
  # Chat is only useful with multiple people.
  @chatters = []

  # Start listening for websocket connections on port 8080
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |socket|
    # When the websocket is opened.
    socket.onopen {
      @chatters << socket
    }

    # When the websocket receives a message.
    socket.onmessage { |data|
      # Send the message to each chatter.
      @chatters.each do |c|
        c.send data
      end
    }

    # When the websocket is closed.
    socket.onclose {
      @chatters.delete socket
    }
  end
}
