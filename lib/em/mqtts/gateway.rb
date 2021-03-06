require 'optparse'

class EventMachine::MQTTS::Gateway
  attr_accessor :mqtts_address
  attr_accessor :mqtts_port
  attr_accessor :broker_address
  attr_accessor :broker_port
  attr_accessor :logger

  def initialize(args=[])
    # Set defaults
    self.mqtts_address = "0.0.0.0"
    self.mqtts_port = EventMachine::MQTTS::DEFAULT_PORT
    self.broker_address = "127.0.0.1"
    self.broker_port = MQTT::DEFAULT_PORT
    self.logger = Logger.new(STDOUT)
    self.logger.level = Logger::INFO
    parse(args) unless args.empty?
  end

  def parse(args)
    OptionParser.new("", 28, '  ') do |opts|
      opts.banner = "Usage: #{File.basename $0} [options]"

      opts.separator ""
      opts.separator "Options:"

      opts.on("-D", "--debug", "turn on debug logging") do
        self.logger.level = Logger::DEBUG
      end

      opts.on("-a", "--address [HOST]", "bind to HOST address (default: #{mqtts_address})") do |address|
        self.mqtts_address = address
      end

      opts.on("-p", "--port [PORT]", "UDP port number to run on (default: #{mqtts_port})") do |port|
        self.mqtts_port = port
      end

      opts.on("-A", "--broker-address [HOST]", "MQTT broker address to connect to (default: #{broker_address})") do |address|
        self.broker_address = address
      end

      opts.on("-P", "--broker-port [PORT]", "MQTT broker port to connect to (default: #{broker_port})") do |port|
        self.broker_port = port
      end

      opts.on_tail("-h", "--help", "show this message") do
        puts opts
        exit
      end

      opts.on_tail("--version", "show version") do
        puts EventMachine::MQTTS::VERSION
        exit
      end

      opts.parse!(args)
    end
  end

  def run
    EventMachine.run do
      # hit Control + C to stop
      Signal.trap("INT")  { EventMachine.stop }
      Signal.trap("TERM") { EventMachine.stop }

      logger.info("Starting MQTT-S gateway on UDP #{mqtts_address}:#{mqtts_port}")
      logger.info("Broker address #{broker_address}:#{broker_port}")
      EventMachine.open_datagram_socket(
        mqtts_address,
        mqtts_port,
        EventMachine::MQTTS::GatewayHandler,
        :logger => logger,
        :broker_address => broker_address,
        :broker_port => broker_port
      )
    end
  end

end
