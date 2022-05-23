require 'csv'

module DS
  module CSVUtil
    module ClassMethods
      def zip_columns csv_file, *columns
        data = []
        CSV.foreach csv_file, headers: true do |row|
          row_map = columns.map { |c| row[c].to_s.split '|' }

          first = row_map.shift
          until first.empty?
            r = []
            r << first.shift
            row_map.each do |col|
              r << (col.shift || '')
            end
            data << r
          end
        end
        data.sort! { |a,b| a.first <=> b.first }
        data.uniq
      end
    end
    self.extend ClassMethods
  end
end