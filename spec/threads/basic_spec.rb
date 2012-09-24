require 'spec_helper'

describe "ruby-scribe" do
  context "with threads" do
    scribe 'basic new/join' do
      threads = 3.times.map { Thread.new { } }
      threads.each { |t| t.join }
    end

    scribe 'sleep' do
      threads = 3.times.map do
        Thread.new do
          puts "#{Thread.current.object_id} it is now #{Time.now}"
          10.times { puts "random: #{Random.rand(1000)}" }
          timeout =  Random.rand(10)/10.to_f
          puts "Sleeping for #{timeout}"
          sleep timeout
          puts "#{Thread.current.object_id} it is now #{Time.now}"
        end
      end

      threads.each { |t| t.join }
    end
  end
end
