require 'mysql2'

client = Mysql2::Client.new(:host => 'localhost', :username => 'root',:password=>'1234')
results = client.query('CREATE DATABASE IF NOT EXISTs Travis')


