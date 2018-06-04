json.note do
  json.id note.id
  json.title note.title
  json.user_id note.user_id
  json.order note.order
  json.fields note.fields do |field|
    json.id field.id
    json.name field.name
    json.value field.value
    json.title field.title
    json.input_type field.input_type
    json.order field.order
  end
end
