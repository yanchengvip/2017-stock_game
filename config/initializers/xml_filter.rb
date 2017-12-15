class ActiveRecord::Base
  class_attribute :xml_options
  attr_accessor :xml_options

  def assign_options(options = {})
    self.xml_options = options
    self
  end

  def as_json_with_options(options = {})
    self.xml_options ||= self.class.xml_options
    options = options.merge(self.xml_options).except(:encoder) if self.xml_options && options.slice(:only, :except, :include, :methods, :object).blank?
    as_json_without_options(options)
  end
  alias_method_chain :as_json, :options
end
