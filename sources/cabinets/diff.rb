#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'
require 'pry'

class Comparison < EveryPoliticianScraper::NulllessComparison
  # Standardise all names to be 'Tiangaye III' instead of 'Tiangaye 3' etc
  CSV::Converters[:roman] = lambda do |val, field|
    field.header != :itemlabel ? val : val.to_s.gsub(/Gouvernement /i, '').gsub('1', 'I').gsub('2', 'II').gsub('3', 'III').gsub('4', 'IV')
  end

  def external_csv_options
    { converters: %i[roman] }
  end

  def wikidata_csv_options
    { converters: %i[roman] }
  end
end

diff = Comparison.new('wikidata.csv', 'scraped.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
