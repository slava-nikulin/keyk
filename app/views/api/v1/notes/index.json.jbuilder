json.notes @notes do |note|
  json.id note.id
  json.title note.title
  json.user_id note.user_id
  json.order note.order
end
