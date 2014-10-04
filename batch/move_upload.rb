User.where.not(token: nil).each do |user|
  puts user.provider
  puts user.name
  puts user.token
end
