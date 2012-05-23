require "simplecov"
SimpleCov.start do
  add_filter 'spec'
end

Dir["./lib/xunlei/**/*.rb"].each { |file| require file }
