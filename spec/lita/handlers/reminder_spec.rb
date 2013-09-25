require "spec_helper"

describe Lita::Handlers::Reminder, lita_handler: true do
  it { routes("remind me at 2013-01-01 10:30 to заплатить за сервер").to(:add) }
  it { routes("reminder delete 1").to(:delete) }
  it { routes("reminder done 1").to(:done) }
  it { routes("remind me at 10:00 to do work repeat 2 times 1m").to(:add) }
end
