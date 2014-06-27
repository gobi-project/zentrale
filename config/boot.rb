# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['RACK_ENV'] ||= 'development'

require 'bundler' if File.exist?(ENV['BUNDLE_GEMFILE'])
Bundler.require :default, ENV['RACK_ENV'].to_sym
