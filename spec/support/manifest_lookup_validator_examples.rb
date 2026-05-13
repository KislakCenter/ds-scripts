# frozen_string_literal: true

RSpec.shared_examples "a manifest lookup validator" do
  context "#valid?" do
    it "runs without error" do
      expect { subject.valid? source_path, lookup_value, lookup_value_location }.not_to raise_error
    end
  end

  context "#locate_record" do
    it "is implemented" do
      expect { subject.locate_record source_path, lookup_value, lookup_value_location }.not_to raise_error
    end
  end

end
