# frozen_string_literal: true

RSpec.shared_examples "a source cache implementation" do
  context "#open_source" do
    it "implement the method" do
      expect { subject.open_source source_path }.not_to raise_error
    end
  end

end
