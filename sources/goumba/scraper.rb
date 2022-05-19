#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    # decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath('//h3[contains(., "inistre") or contains(.,"Secrétaire")]//following-sibling::ul[1]//li')
    end

    def member_items
      super.reject { |mem| mem.name.to_s.empty? }
    end
  end

  class Member
    field :name do
      position_and_name.last.gsub(/\(.*?\)/, '').tidy
    end

    field :position do
      position_and_name.first.tidy
    end

    def position_and_name
      noko.text.split(':', 2)
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
