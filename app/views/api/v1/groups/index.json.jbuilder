json.groups @groups do |group|
  json.id group.id
  json.title group.title
  json.users group.users do |user|
    json.id user.id
    # json.name user.name
  end
  json.notes group.notes do |note|
    json.id note.id
    # json.name user.name
  end
end
