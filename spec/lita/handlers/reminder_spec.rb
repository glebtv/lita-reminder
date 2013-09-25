require "spec_helper"

describe Lita::Handlers::Reminder, lita_handler: true do
  after :each do
    send_message("reminder clear all")
  end

  it { routes("remind me at 2013-01-01 10:30 to заплатить за сервер").to(:add) }
  it { routes("reminder delete 1").to(:delete) }
  it { routes("reminder done 1").to(:done) }
  it { routes("remind me at 10:00 to do work repeat 2 times 1m").to(:add) }
  it "adds tasks" do
    send_message("remind me at 2024-01-01 10:30 to заплатить за сервер")

    index = replies.last.match(/Task (\d+) added/)[1]
    expect(replies.last).to eq("Task #{index} added, next run at 2024-01-01 10:30:00")
  end

  it "sets user" do
    carl = Lita::User.create(123, name: "Carl")
    send_message("remind me at 2024-01-01 10:30 to заплатить за сервер", as: carl)

    index = replies.last.match(/Task (\d+) added/)[1]
    expect(replies.last).to eq("Task #{index} added, next run at 2024-01-01 10:30:00")
  end

  it "deletes tasks" do
    send_message("remind me at 2035-01-01 10:30 to заплатить за сервер")
    index = replies.last.match(/Task (\d+) added/)[1]
    expect(replies.last).to eq("Task #{index} added, next run at 2035-01-01 10:30:00")
    sleep 0.1
    send_message("reminder delete #{index}")
    expect(replies.last).to eq("Task #{index} deleted")
  end

  it "reminds" do
    send_message("remind me in 1s to заплатить за сервер")
    index = replies.last.match(/Task (\d+) added/)[1]
    expect(replies.last).to eq("Task #{index} added, next run at #{(Time.now + 1).strftime('%Y-%m-%d %H:%M:%S')}")
    sleep 2
    expect(replies.last).to eq("Reminder #{index}: заплатить за сервер")
  end
end
