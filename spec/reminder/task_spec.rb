require "spec_helper"

describe ReminderTask do
  it 'parses message' do
    carl = Lita::User.create(123, name: "Carl")
    task = ReminderTask.from_message(1, {
      'who' => 'me',
      'type' => 'in',
      'time' => '10m',
      'repeat' => ''
    }, Lita::Source.new(user: carl, room: 'room'))
    task.user_name.should eq carl.name
    task.user_id.should eq carl.id
    task.time.should eq (Time.now + 600).to_s
    task.index.should eq 1
  end
end
