# frozen_string_literal: true

module DS
  module Source
    ##
    # Encapsulates methods for caching and opening source files.
    #
    # This class includes the DS::Source::SourceCache module, but does
    # not implement the +open_source+ method. Concrete subclasses of
    # {DS::Source::BaseSource} must implement +open_source+.
    #
    class BaseSource
      include DS::Source::SourceCache

      # Loads the specified source path.
      #
      # @param source_path [String] The path to the source file.
      # @return [Object] The parsed source file; e.g, Nokogiri::XML::Document or CSV::Table
      def load_source source_path
        find_or_open_source source_path
      end
    end
  end
end
