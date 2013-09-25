require 'lita'
require 'rufus/scheduler'
require 'reminder/task'
require 'reminder/runner'
require 'reminder/domain'
require 'chronic'
require 'thread'

module Lita
  module Handlers
    class Reminder < Handler 
      @@mutex = Mutex.new
      @@runner = ReminderRunner.new

      route(/^remind\s+(?<who>\S+)\s+(?<type>at|in|every|cron)\s+(?<time>.*)(\s+first\s+at\s+(?<first>.*))?\s+to\s+(?<task>.*?)(\s+repeat\s+(?<repeat>.*)\s+times\s+(?<repeat_interval>.*))?$/, :add,
            help: {"remind (me|here|username|room) (at|in|every|cron) TIME [first at TIME] to TASK [repeat 3|many times 10m]" => "Add a reminder"})
      route(/^reminder\s+done\s+(\d+)$/, :done, help: {"reminder ID done" => "Stop nagging"})
      route(/^reminder\s+delete\s+(\d+)$/, :delete, help: {"reminder ID delete" => "Delete reminder"})
      route(/^reminder\s+list$/, :list, help: {"reminder list" => "List reminders"})
      route(/^reminder\s+clear\s+all$/, :clear)

      # reminders for domain name expiration
      route(/^reminder\s+add\s+domain\s+(.*)$/, :add_domains, help: {"reminder add domain DOMAINS ..." => "Add domain expiration reminder"})
      route(/^reminder\s+delete\s+domain\s+(.*)$/, :delete_domains, help: {"reminder delete domain DOMAINS ..." => "Stop watching domain"})
      route(/^reminder\s+list\s+domains\s+(.*)$/, :list_domains, help: {"reminder list domains" => "List domain watch list"})

      route(/^server\s+time$/, :time)

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

      def time(response)
        response.reply Time.now.to_s
      end

      def add_domains(response) 
        @@mutex.synchronize do
          @@runner.add_domains(response)
        end
      end

      def delete_domains(response)
        @@mutex.synchronize do
          @@runner.delete_domains(response)
        end
      end

      def list_domains(response)
        @@mutex.synchronize do
          @@runner.list_domains(response)
        end
      end

      class << self
        def runner
          @@runner
        end
      end
    end

    Lita.register_handler(Reminder)
  end
end

# ugly hack
# TODO fix this better
module Lita
  class << self
    def run(config_path = nil)
      Config.load_user_config(config_path)
      robot = Robot.new
      redis_base = Redis.new(config.redis)
      redis_ns = Redis::Namespace.new(REDIS_NAMESPACE + ":handlers:reminder", redis: redis_base)
      Lita::Handlers::Reminder.runner.start(robot, redis_ns)
      robot.run
    end
  end
end
