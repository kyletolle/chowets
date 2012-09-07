require 'htmlentities'
require 'em-websocket'
require 'json'
require './messages'
require './chatter'

EventMachine.run {
  # Chat is only useful with multiple people.
  @chatters = {}
  # Keep a list of messages
  @messages = Messages.new

  # The number of recent messages we're interested in.
  NUM_RECENT_MESSAGES = 10

  def on_chat(chatter, text)
    # Keep this in the list of recent messages, the index is adjusted since
    # we're only keeping a small number of messages around.
    escaped_text = HTMLEntities.new.encode(text)
    message = "#{chatter.name}: #{escaped_text}"
    @messages[@messages.count % NUM_RECENT_MESSAGES] = message
    @messages.count += 1

    # Send the message to each chatter.
    @chatters.each do |key, val|
      create_json message
      val.socket.send create_json(message)
    end
  end

  def on_name(chatter, username)
    chatter.name = username
  end

  #TODO
  def process_message(data)
    message = JSON.parse(data)
    id = message['id']
    action = message['action']

    chatter = @chatters[id]
    if action == 'set_username'
      on_name(chatter, message['username'])
    else
      on_chat(chatter, message['text'])
    end
  end

  def create_json(data)
    { text: data}.to_json
  end

  # Start listening for websocket connections
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 3939) do |socket|
    # When the websocket is opened.
    socket.onopen {
      # Create a chatter
      chatter = Chatter.new(socket)

      # Keep track of this chatter.
      @chatters[chatter.id] = chatter

      id_msg = {
        action: :set_id,
        id: chatter.id
      }
      chatter.socket.send id_msg.to_json
      #TODO: Need to send a message to the user so they have their ID.

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
        chatter.socket.send create_json(recent_msg)
      end
    }

    # When the websocket receives a message.
    socket.onmessage { |data|
      process_message data
    }

    # When the websocket is closed.
    socket.onclose {
      @chatters.delete socket
    }
  end
}
