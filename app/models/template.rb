# Model describes note's template, that is used as sceleton to create security notes
class Template < ApplicationRecord
  belongs_to :user

  validates_presence_of :title, :config
  validates_uniqueness_of :title

  # Public: creates note and fills fields values from "values" hash
  def create_note(title:, user: self.user, values: {})
    values = values.with_indifferent_access
    config = self.config.with_indifferent_access

    Note.create!(
      title: title,
      user: user,
      template: self,
      fields_attributes: config[:fields].map do |c|
        { value: values[c[:name]], title: c[:title], input_type: c[:input_type], order: c[:order], name: c[:name] }
      end,
    )
  end
end
