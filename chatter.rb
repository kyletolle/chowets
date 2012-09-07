require 'Base64'

class Chatter
  attr_accessor :socket, :name, :id

  def initialize(socket)
    raise ArgumentError if socket.nil?
    self.socket = socket

    self.id = generate_id
  end

  private
    def generate_id
      now = Time.now.to_i
      id_string = (now * rand(now)).to_s
      Base64.encode64(id_string).strip
    end

    #def generate_name(number)
    #  number = rand(Time.now) if number.nil?
    #  self.name = "Chatter#{number}"
    #end
end

