require 'travis'
require 'mysql2'
client=Mysql2::Client.new(:host=>'10.131.252.160',
                          :username=>'root',
                          :password=>'123456',
                          :database=>'fdroid',
                          :encoding=>'utf8'
                         )
result=client.query("Select name,user_name from github_repository where id<20")
result.each do|item|
  print item['user_name'],"/",item['name']," "
  print Travis::Repository.find("#{item['user_name']}/#{item['name']}").last_build_number.to_i,"\n"
end
rails = Travis::Repository.find('rails/rails')

