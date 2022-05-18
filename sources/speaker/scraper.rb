#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Dates'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[dates name party].freeze
    end

    def name_node
      name_cell.css('a').first
    end

    def empty?
      (tds.count != 3) || (tds[1].text == tds[2].text)
    end

    def raw_combo_dates
      raw_combo_date.gsub(/depuis le (.*)/, '\1 au Incumbent').scan(/(\d.*?) (?:à|au) (.*)/).flatten
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
