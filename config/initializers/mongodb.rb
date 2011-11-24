case Rails.env
when "development"
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017, { :logger => Rails.logger })
  MongoMapper.database = 'jeocrowd4s_development'
  # MongoMapper.database.authenticate('admin', 'sekret')
when "test"
  
when "production"
  MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com/app1810029', 10034, { :logger => Rails.logger })
  MongoMapper.database = 'jeocrowd4s_production'
  MongoMapper.database.authenticate('heroku', '448e011347c9ae6e757c88cfcc7ce670')
end