# frozen_string_literal: true

RSpec.shared_examples "an source cache implementation" do
  context "#open_source" do
    it "responds to the method" do
      expect(subject).to respond_to :open_source
    end
  end

end
