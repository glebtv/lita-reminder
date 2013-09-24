class ReminderTask
  attr_accessor :index, :user, :room, :time, :job, :naggy, :nag_job, :slienced_at
  def initialize(index, attrs)
    attrs.each do |attr|
      send("#{attr.to_s}=".to_sym, attrs[attr]) unless attrs[attr].nil?
    end
  end

  def start_job(scheduler)
    @job = 
  end

  def dump
    hash = {}
    attrs.each do |attr|
      hash[attr] = send(attr) unless send(attr).nil?
    end
    MultiJson.dump(hash)
  end

  class << self
    def from_message(message, source)
      if message[1] == 'me'
        
      end
      @username = 
    end
    def attrs
      [:user, :room, :time, :naggy, :slienced_at]
    end
    def load(string)
      addrs = MultiJson.load(string)
      ReminderTask.new attrs
    end
  end
end
