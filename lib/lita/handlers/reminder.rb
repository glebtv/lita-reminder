require 'lita'
require 'rufus/scheduler'
require 'reminder/task'


module Lita
  module Handlers
    class Reminder < Handler 
      route(/^remind\s+(?<who>\S+) (?<type>at|in|every|cron) (?<time>.*) (first at (?<first>.*))? to (?<task>.*)$/, :add,
            help: {"remind (me|here|username|room) (at|in|every|cron) TIME [first at TIME] to TASK [3 times|hard]" => "Add a reminder"})
      route(/^reminder (\d+) done$/, :done, help: {"reminder ID done" => "Stop nagging"})
      route(/^reminder (\d+) delete$/, :delete, help: {"reminder ID delete" => "Delete reminder"})

      def initialize(robot)
        super(robot)
        @reminder_count = redis.llen("reminders")
        @reminders = redis.lrange('reminders', 0, -1)# .map {|v| ReminderTask.load(v) }
        @scheduler = Rufus::Scheduler.start_new
        p @reminders
      end

      def add(response)
        task = ReminderTask.from_message(response.match_data, message.source)
        redis.lpush("reminders", task.dump)
        task.start_job(@scheduler)
        @reminders << task
        response.reply("Task added")
      end
    end

    Lita.register_handler(Reminder)
  end
end
