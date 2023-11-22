# frozen_string_literal: true

module Recon
  class BaseTermSet

    attr_accessor :name
    attr_accessor :csv_path
    attr_accessor :key_column
    attr_accessor :structured_data_column
    attr_accessor :authorized_label_column
    attr_accessor :balanced_columns
    attr_accessor :subset_column
    attr_accessor :dictionary

    def initialize(
      name:, csv_path:, key_column:, authorized_label_column:,
      balanced_columns:, structured_data_column: nil, subset_column: nil
    )
      @name                    = name
      @csv_path                = csv_path
      @key_column              = key_column
      @structured_data_column  = structured_data_column
      @authorized_label_column = authorized_label_column
      @balanced_columns        = balanced_columns
      @subset_column           = subset_column
      @dictionary              = {}
    end

    def load_set path
      CSV.foreach path, 'r', headers: true do |row|
        key = build_key term: row[key_column], subset: row[subset_column]
        dictionary[key] = row.to_h
      end
    end

    def build_key term:, subset: nil
      "#{term}$$#{subset}"
    end

    def lookup as_recorded:, return_column:, subset: nil
      key = build_key term: as_recorded, subset: subset
      # require 'pry'; binding.pry
      dictionary.dig(key, return_column)
    end
  end
end