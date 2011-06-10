class RecordedEvent
  attr_reader :name, :data

  def initialize(name, data)
    @name = name.to_s
    @data = data
  end

  def inspect
    "<Event:#{name} #{inspect_data}>"
  end

  def ==(other)
    name == other.name && data == other.data
  end

  private

  def inspect_data
    data.inject([]) { |result, (key, value)|
      result << "#{key.inspect} => #{value.inspect.slice(0, 20)}"
    }.join(", ")
  end
end

class RecordingObserver
  attr_reader :events

  def initialize
    @events = []
  end

  def method_missing(name, data)
    @events << RecordedEvent.new(name, data)
  end
end

RSpec::Matchers.define :notify_observers do |event_name, data|
  match do |ignored_subject|
    @event = RecordedEvent.new(event_name, data)
    recorder.events.should include(@event)
  end

  failure_message do
    "Expected event:\n#{@event.inspect}\n\nGot events:\n#{recorder.events.map(&:inspect).join("\n")}"
  end

  def recorder
    Saucy::Configuration.observers.last
  end
end

RSpec.configure do |config|
  config.before do
    Saucy::Configuration.observers = [RecordingObserver.new]
  end
end
