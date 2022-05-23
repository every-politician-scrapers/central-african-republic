#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'

csv = CSV.table('/tmp/CREATEM')

puts "orig,transformed"

csv.each do |row|
  puts [row[:name], row[:name].split(/ (?=[[:upper:]][[:lower:]])/, 2).reverse.join(' ')].flatten.to_csv
end
