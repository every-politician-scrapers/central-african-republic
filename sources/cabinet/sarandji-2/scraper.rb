#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    # decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath('//h3[contains(., "inistre") or contains(.,"Secrétaire")]//following-sibling::ol[1]//li')
    end

    def member_items
      super.reject { |mem| mem.name.to_s.empty? }
    end
  end

  class Member
    field :name do
      Name.new(full: fullname, prefixes: %w[Général de Brigade division Lieutenant Colonel Docteur Dr. M. Mme]).short
    end

    field :position do
      position_and_name.first.gsub(/^\d+\./, '').tidy
    end

    field :gender do
      return 'female' if fullname.start_with?('Mme')
      return 'male' if fullname.start_with?('M.')
    end

    private

    def position_and_name
      noko.text.split(':', 2)
    end

    def fullname
      position_and_name.last.gsub(/\(.*?\)/, '').tidy.gsub(/[,;.]$/, '')
        .gsub(/^M\.(\S)/, 'M. \1')
        .gsub('Lieutenant-colonel', 'Lieutenant Colonel')
        .gsub('le Général d’Armée', '')
        .gsub(/, puis Sylvie.*/, '') # I've confirmed that the replacement is already there
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
