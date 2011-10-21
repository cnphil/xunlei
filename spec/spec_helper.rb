require "simplecov"
SimpleCov.start

Dir["./lib/xunlei/*.rb"].each { |file| require file }
