require 'spec_helper'

describe "io" do
  context "open" do
    scribe "a few fds" do
      10.times.map { File.open('/etc/passwd') }
    end

    scribe "too many fds" do
      expect { 2000.times.map { File.open('/etc/passwd') }}.to raise_error
    end

    context "threaded", :pending => 'need to sync the GIL' do
      scribe "open should be synced" do
        threads = 3.times.map do
          Thread.new do
            puts 100.times.map { File.open('/etc/passwd').fileno }.join('')
          end
        end
        threads.each { |t| t.join }
      end
    end
  end

  context "read" do
    scribe "open, read, puts" do
      File.open('/etc/passwd').each { |l| puts l }
    end
  end
end
