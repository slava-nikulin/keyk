return {} if @account.blank?

json.account do
  json.login @account.login
  json.confirm_type @confirm_type
end
