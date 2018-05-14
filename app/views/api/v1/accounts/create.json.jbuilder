return {} if @account.blank?

json.account do
  json.login @account.login
  json.token @token
end
