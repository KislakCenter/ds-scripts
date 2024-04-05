# frozen_string_literal: true

module Recon
  class ReconManager
    attr_reader :iterator
    attr_reader :extractor

    def initialize iterator:, extractor:
      @iterator  = iterator
      @extractor = extractor
    end

    def recon_places
      extract_recons(
        method_name: :extract_places,
        item_type: 'places',
        columns: %w[authorized_label structured_value]
      )
    end

    def recon_materials
      extract_recons(
        method_name: :extract_materials,
        item_type: 'materials',
        columns: %w[authorized_label structured_value]
      )
    end

    def recon_names
      extract_recons(
        method_name: %i[extract_authors extract_artists extract_scribes extract_former_owners],
        item_type: 'names',
        columns: %w[instance_of authorized_label structured_value]
      )
    end

    def recon_genres
      extract_recons(
        method_name: %i[extract_genres],
        item_type: 'genres',
        columns: %w[authorized_label structured_value]
      )
    end

    def recon_subjects
      extract_recons(
        method_name: %i[extract_subjects],
        item_type: 'subjects',
        columns: %w[authorized_label structured_value]
      )
    end

    def recon_named_subjects
      extract_recons(
        method_name: %i[extract_named_subjects],
        item_type: 'named-subjects',
        columns: %w[authorized_label structured_value]
      )
    end

    def recon_titles
      extract_recons(
        method_name: %i[extract_titles],
        item_type: 'titles',
        columns: %w[authorized_label]
      )
    end

    def recon_languages
      extract_recons(
        method_name: %i[extract_languages],
        item_type: 'languages',
        columns: %w[authorized_label structured_value]
      )
    end

    def extract_recons method_name:, item_type:, columns: []
      items = Set.new
      iterator.each do |record|
        [method_name].flatten.each do |name|
          items += extractor.send(name.to_sym, record)
        end
      end
      recons = build_recons(
        terms: items,
        recon_type: item_type,
        columns: columns
      )
      recons.sort
    end

    def build_recons terms:, recon_type:, columns: []
      terms.map { |term|
        as_recorded = term.as_recorded
        row = term.to_a
        row += columns.map { |col|
          Recon.lookup(recon_type, value: as_recorded, column: col).to_s.gsub '|', ';'
        }
        row
      }
    end
  end
end
