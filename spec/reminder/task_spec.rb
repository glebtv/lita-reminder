require "spec_helper"

describe ReminderTask do
  it 'parses message' do
    task = ReminderTask.from_message({
      'who' => 'me',
      'type' => 'in',
      'time' => '10m',
      'repeat' => ''
    }, Lita::Source.new('user', 'room'))
    task.user.should eq 'user'
    task.time.should eq '10m'
  end
end
