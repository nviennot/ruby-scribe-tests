require 'spec_helper'

describe "io" do
  scribe "too many fds" do
    expect { 2000.times.map { File.open('/etc/passwd') }}.to raise_error
  end

  context "threaded", :pending => 'need to sync the GIL' do
    scribe "open should be synced" do
      threads = 3.times.map do
        Thread.new do
          100.times.map { File.open('/etc/passwd').fileno }.join('')
        end
      end
      threads.each { |t| t.join }
    end
  end
end
