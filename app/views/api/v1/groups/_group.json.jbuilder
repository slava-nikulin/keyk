json.group do
  json.id group.id
  json.title group.title
  GroupRelationship.user_roles.keys.each do |k|
    json.set! "#{k}s" do
      json.array! group.send("#{k}s") do |user|
        json.id user.id
        json.login user.account.login
      end
    end
  end
  json.notes group.notes do |note|
    json.id note.id
    json.title note.title
  end
end
