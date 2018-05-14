json.template do
  json.id @template.id
  json.title @template.title
  json.user_id @template.user_id
  json.config do
    json.fields @template.config['fields'] do |field|
      json.name field['name']
      json.title field['title']
      json.input_type field['input_type']
      json.order field['order']
    end
  end
end
