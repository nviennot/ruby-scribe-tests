require 'rubygems'
require 'bundler'
Bundler.require(:default, :test)

RSpec.configure do |config|
  config.mock_with :mocha
  config.color_enabled = true
end

def scribe(desc, *args, &block)
  if ENV['SCRIBED']
    instance_eval 'it desc, *args, &block' , *block.source_location
  else
    record_block = proc do
      log_file = "./logs/#{desc.gsub(/[ \/:]/, '_').gsub(/example_at_._spec_/, '')}"
      io = IO.popen([{'SCRIBED' => '1'},
                     "record", "-o", log_file, "rspec", "--format=p", "--tty", block.source_location.join(':')],
                     :err => [:child, :out])
      p = Process.wait
      if $? != 0
        IO.copy_stream(io, STDOUT)
        raise "Record failed"
      end
    end

    replay_block = proc do
      log_file = "./logs/#{desc.gsub(/[ \/:]/, '_').gsub(/example_at_._spec_/, '')}"
      io = IO.popen(["replay", "-b", "20", log_file, :err => [:child, :out]])

      deadlock_thread = Thread.new do
        sleep 1
        Process.kill(:USR2, io.pid)
      end

      begin
        p = Process.wait

        if $? != 0
          puts "-" * 80
          IO.copy_stream(io, STDOUT)
          raise "Replay failed"
        end
      ensure
        Thread.kill(deadlock_thread)
      end
    end

    instance_eval 'it "records #{desc}", *args, &record_block' , *block.source_location
    instance_eval 'it "replays #{desc}", *args, &replay_block' , *block.source_location
  end
end

unless ENV['SCRIBED']
  require 'rspec/core/formatters/base_text_formatter'
  class RSpec::Core::Formatters::BaseTextFormatter
    def dump_failures; end
    def dump_commands_to_rerun_failed_examples; end
  end
end
