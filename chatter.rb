class Chatter
  attr_accessor :socket, :name

  def initialize(hash = {})
    raise ArgumentError if hash[:socket].nil?
    self.socket = hash[:socket]
    self.name = generate_name hash[:number]
  end

  private
    def generate_name(number)
      number = rand(Time.now) if number.nil?
      self.name = "Chatter#{number}"
    end
end

