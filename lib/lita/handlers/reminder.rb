require 'lita'
require 'rufus/scheduler'
require 'reminder/task'
require 'reminder/runner'
require 'chronic'
require 'thread'

module Lita
  module Handlers
    class Reminder < Handler 
      @@mutex = Mutex.new
      @@runner = ReminderRunner.new

      route(/^remind\s+(?<who>\S+)\s+(?<type>at|in|every|cron)\s+(?<time>.*)(\s+first\s+at\s+(?<first>.*))?\s+to\s+(?<task>.*)(\s+repeat\s+(?<repeat>.*)\s+times\s+(?<repeat_interval>.*))?$/, :add,
            help: {"remind (me|here|username|room) (at|in|every|cron) TIME [first at TIME] to TASK [repeat 3|many times 10m]" => "Add a reminder"})
      route(/^reminder\s+done\s+(\d+)$/, :done, help: {"reminder ID done" => "Stop nagging"})
      route(/^reminder\s+delete\s+(\d+)$/, :delete, help: {"reminder ID delete" => "Delete reminder"})
      route(/^reminder\s+list$/, :list, help: {"reminder list" => "List reminders"})
      route(/^reminder\s+clear\s+all$/, :clear)

      attr_accessor :scheduler

      def initialize(robot)
        super(robot)
        @@mutex.synchronize do
          @@runner.start(robot, redis)
        end
      end
      
      def add(response)
        @@mutex.synchronize do
          @@runner.add(response)
        end
      end
      def done(response)
        @@mutex.synchronize do
          @@runner.done(response)
        end
      end
      def delete(response)
        @@mutex.synchronize do
          @@runner.delete(response)
        end
      end
      def list(response)
        @@mutex.synchronize do
          @@runner.list(response)
        end
      end
      def clear(response)
        @@mutex.synchronize do
          @@runner.clear
          response.reply "cleared all reminders"
        end
      end
    end

    Lita.register_handler(Reminder)
  end
end
