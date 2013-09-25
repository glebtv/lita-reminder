class ReminderTask
  attr_accessor :index, :job, :repeat_job, :repeat_count
  def initialize(index, attrs)
    attrs.each do |attr|
      send("#{attr.to_s}=".to_sym, attrs[attr]) unless attrs[attr].nil?
    end
  end

  def start_job(handler)
    @handler = handler
    scheduler = @handler.scheduler

    @periodic = false
    @job = 
      if type == 'in'
        scheduler.in @time do
          run()
        end
      elsif type == 'at'
        scheduler.at Chronic.parse(@time, now: @c_at) do
          run()
        end
      elsif type == 'cron'
        @periodic = true
        scheduler.cron @time do
          run()
        end
      elsif type == 'every'
        @periodic = true
        scheduler.every @time, first_at: @first do
          run()
        end
      end
  end

  def run
    puts "notifying - time has come"
    target = Lita::Source.new(user, room)
    @handler.robot.send_message(target, message)
    if repeat
      @repeat_job = @handler.scheduler.every repeat_interval do
        repeat()
      end
    elsif !@periodic
      kill
    end
  end

  def repeat
    puts "nagging"
    target = Lita::Source.new(user, room)
    @handler.robot.send_message(target, message)
    if repeat != 'many'
      if repeat_count > repeat
        stop_repeat
      end
    end
  end

  def stop_repeat
    @repeat_job.unschedule
    unless @periodic
      kill
    end
  end

  def kill
    @handler.kill(index)
  end

  def die
    @job.unschedule
    @repeat_job.unschedule
  end

  def message
    "Reminder #{index}: #{task}"
  end

  def to_s
    "reminder next run: #{@job.next_time.to_s} u:#{user} r:#{room} #{type} #{time} #{first} #{task} #{repeat} #{repeat_interval}"
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
      p message
      attrs = {}
      if message['who'] == 'me'
        attrs['user'] = source.user
      elsif message['who'] == 'here'
        attrs['room'] = source['room']
      end
      attrs['type'] = message['type']
      attrs['time'] = message['time']
      attrs['repeat'] = message['repeat']
      attrs['repeat_interval'] = message['repeat_interval'] || '10m'
      attrs['task'] = message['task']
      attrs['c_at'] = Time.now

      ReminderTask.new attrs
    end
    def attrs
      [:c_at, :user, :room, :type, :time, :first, :task, :repeat, :repeat_interval]
    end
    def load(string)
      if string.nil? || string == ''
        nil
      else
        addrs = MultiJson.load(string)
        ReminderTask.new attrs
      end
    end
  end
  attr_accessor *ReminderTask.attrs
end
