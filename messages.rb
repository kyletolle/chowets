# A list of messages
class Messages
  # Count of all the messages seen so far, different from the size.
  attr_accessor :count

  def initialize
    @messages = []
    self.count = @messages.size
  end

  # Retrieving the contents of a message.
  def [](val)
    @messages[val]
  end

  # Assigning the contents of a message.
  def []=(val, content)
    @messages[val] = content
  end

  # Pushing a message.
  def <<(val)
    @messages << val
  end

  def size
    @messages.size
  end

  # Iterator for messages.
  def each(&block)
    # Pass a block onto the messages array
    if block_given?
      @messages.each(&block)
    else
      @messages.each
    end
  end

  def to_s
    @messages.to_s
  end
end

