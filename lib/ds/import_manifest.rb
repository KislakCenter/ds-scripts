module DS
  class ImportManifest
    attr_reader :manifest_csv

    def initialize manifest_csv
      @manifest_csv = manifest_csv
    end

    def validate_columns
      headers = CSV.readlines(manifest_csv).first.map &:to_sym
      missing = DS::Constants::MANIFEST_HEADINGS - headers
      extra = headers - DS::Constants::MANIFEST_HEADINGS

      STDERR.puts "WARNING: Unexpected columns #{extra.join ', '}" unless extra.empty?

      return if missing.empty?

      raise DS::DSError, "Missing required column(s): #{missing.join ', '}", caller
    end

    def validate!
      validate_columns
    end
  end
end