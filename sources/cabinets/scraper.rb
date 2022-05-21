#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class CabinetList < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  def members
    noko.css('.navbox-list .nowrap').map { |cab| fragment(cab => Cabinet) }.reject { |cab| cab.itemLabel == '...' }.map(&:to_h)
  end

  class Cabinet < Scraped::HTML
    field :item do
      noko.css('a/@wikidata').map(&:text).map(&:tidy).first
    end

    field :itemLabel do
      noko.css('a').map(&:text).map(&:tidy).first || noko.xpath('text()').text.tidy
    end

    field :began do
      WikipediaDate::French.new(dates.first.to_s.tidy).to_s
    end

    field :ended do
      WikipediaDate::French.new(dates.last.to_s.tidy).to_s
    end

    private

    def dates
      noko.css('small').text.gsub(/depuis le (.*)\)/, '\1-)').scan(/\((.*?)[-–](.*?)\)/).flatten
    end
  end
end

url = 'https://fr.wikipedia.org/wiki/Mod%C3%A8le:Palette_Gouvernement_en_R%C3%A9publique_centrafricaine'
puts EveryPoliticianScraper::ScraperData.new(url, klass: CabinetList).csv
