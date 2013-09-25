require 'lita'
require 'rufus/scheduler'
require 'reminder/task'
require 'chronic'

module Lita
  module Handlers
    class Reminder < Handler 
      route(/^remind\s+(?<who>\S+)\s+(?<type>at|in|every|cron)\s+(?<time>.*)(\s+first\s+at\s+(?<first>.*))?\s+to\s+(?<task>.*)(\s+repeat\s+(?<repeat>.*)\s+times\s+(?<repeat_interval>.*))?$/, :add,
            help: {"remind (me|here|username|room) (at|in|every|cron) TIME [first at TIME] to TASK repeat [3|many times 10m]" => "Add a reminder"})
      route(/^reminder\s+done\s+(\d+)$/, :done, help: {"reminder ID done" => "Stop nagging"})
      route(/^reminder\s+delete\s+(\d+)$/, :delete, help: {"reminder ID delete" => "Delete reminder"})
      route(/^reminder\s+list$/, :list, help: {"reminder list" => "List reminders"})

      def initialize(robot)
        super(robot)
        @reminder_count = redis.llen("reminders")
        @reminders = {}
        redis.lrange('reminders', 0, -1).each_with_index do |task, index|
          @reminders << ReminderTask.load(index, task)
        end
        @scheduler = Rufus::Scheduler.start_new
        @reminders.each do |task|
          task.start_job(self)
        end
      end

      def add(response)
        task = ReminderTask.from_message(response.match_data, message.source)
        redis.lpush("reminders", task.dump)
        task.start_job(self)
        @reminders << task
        response.reply("Task added")
      end

      def done(response)
        @reminders[response.match_data[1]].stop_nag
      end
      
      def delete(response)
        kill(response.match_data[1])
      end

      def list(response)
        response.reply(@reminders.reject{|r| r.nil? }.map(&:to_s).join("\n"))
      end

      def kill(index)
        @redis.lset("reminders", index, nil)
        @reminders[index].die
        @reminders[index] = nil
      end
    end

    Lita.register_handler(Reminder)
  end
end
