require "addressable/uri"

class ReminderDomain
  attr_reader :domain, :expiration, :whois_data

  def initialize(domain)
    uri = Addressable::URI.heuristic_parse(domain)
    host = uri.host
    host.start_with?('www.') ? host[4..-1] : host
    @domain = host
    @expiration = expiration
    @reminder = ReminderDomain.task_from_domain(@domain)
    @whois_data = nil
  end

  class << self
    def task_from_domain(domain)
      Lita::Handlers::Reminder.runner.reminders.select { |task| task.task == "domain expiration #{domain}"}.first
    end
  end
end
