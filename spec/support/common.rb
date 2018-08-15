def auth_header(token)
  { 'Authorization' => "Token token=#{token.value}" }
end
