require 'time'

class ReminderTask
  attr_accessor :index, :job, :repeat_job, :repeat_count
  def initialize(index, attrs)
    @index = index
    attrs.each_pair do |attr, val|
      send("#{attr.to_s}=".to_sym, val) unless val.nil?
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
        scheduler.at Chronic.parse(@time, now: Time.parse(@c_at)) do
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

  def target
    if user_id.nil? && user_name.nil?
      user = nil
    else
      user = Lita::User.create(user_id, name: user_name)
    end
    Lita::Source.new(user, room)
  end

  def run
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
    @handler.robot.send_message(target, message)
    if repeat != 'many'
      if repeat_count > repeat
        stop_repeat
      end
    end
  end

  def stop_repeat
    @repeat_job.unschedule
    @repeat_job = nil
    unless @periodic
      kill
    end
  end

  def kill
    @handler.kill(index)
  end

  def die
    @job.unschedule unless @job.nil?
    @repeat_job.unschedule unless @repeat_job.nil?
  end

  def message
    "Reminder #{index}: #{task}"
  end

  def to_s
    "reminder next run: #{@job.next_time.to_s} u:#{user_id} #{user_name} r:#{room} #{type} #{time} #{first} #{task} #{repeat} #{repeat_interval}"
  end

  def dump
    hash = {}
    ReminderTask.attrs.each do |attr|
      hash[attr] = send(attr) unless send(attr).nil?
    end
    MultiJson.dump(hash)
  end

  class << self
    def from_message(index, message, source)
      attrs = {}
      if message['who'] == 'me'
        attrs['user_id'] = source.user.id
        attrs['user_name'] = source.user.name
      elsif message['who'] == 'here'
        attrs['room'] = source.room
      else
        re = /^(user\s+id\s+(?<user_id>.*))?^(user\s+name\s+(?<user_id>.*))?(room \s+(?<room>.*))?$/
        m = re.match(message['who'])
        attrs = attrs.merge(m)
      end
      attrs['type'] = message['type']
      attrs['time'] = message['time']
      attrs['repeat'] = message['repeat']
      attrs['repeat_interval'] = message['repeat_interval'] || '10m'
      attrs['task'] = message['task']
      attrs['c_at'] = Time.now.to_s

      ReminderTask.new index, attrs
    end
    def attrs
      [:c_at, :user_id, :user_name, :room, :type, :time, :first, :task, :repeat, :repeat_interval]
    end
    def load(index, string)
      if string.nil? || string == ''
        nil
      else
        attrs = MultiJson.load(string)
        ReminderTask.new index, attrs
      end
    end
  end
  attr_accessor *ReminderTask.attrs
end
