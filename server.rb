require 'em-websocket'
require './messages'

EventMachine.run {
  # Chat is only useful with multiple people.
  @chatters = []
  # Keep a list of messages
  @messages = Messages.new

  # The number of recent messages we're interested in.
  NUM_RECENT_MESSAGES = 10

  # Start listening for websocket connections
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 3939) do |socket|
    # When the websocket is opened.
    socket.onopen {
      # Keep track of this chatter.
      @chatters << socket

      ## Spit out the last few messages.
      # Range of recent messages we want to see.
      recent_messages_range =
        (@messages.count-NUM_RECENT_MESSAGES..@messages.count-1)

      # For each of the messages we're interested in.
      recent_messages_range.each do |msg_index|
        # We mod the index since we only keep a small list of messages, but
        # keeping a count separate from the size helps us list out messages in
        # the order they were actually received.
        recent_msg = @messages[msg_index % NUM_RECENT_MESSAGES]

        # If the message is nil, just skip it.
        next if recent_msg.nil?

        # Otherwise send the message to the chatter.
        socket.send recent_msg
      end
    }

    # When the websocket receives a message.
    socket.onmessage { |data|
      # Keep this in the list of recent messages, the index is adjusted since
      # we're only keeping a small number of messages around.
      @messages[@messages.count % NUM_RECENT_MESSAGES] = data
      @messages.count += 1

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
