require 'travis'
require 'mysql2'
def use_travis
  client_160server=Mysql2::Client.new(:host=>'10.131.252.160',
                            :username=>'root',
                            :password=>'123456',
                            :database=>'fdroid',
                            :encoding=>'utf8'
                                     )
  client_localhost=Mysql2::Client.new(:host=>'localhost',
                            :username=>'root',
                            :password=>'cumtzc04091751',
                            :database=>'zctest',
                            :encoding=>'utf8'
                                     )
=begin
  client_localhost.query("CREATE TABLE IF NOT EXISTS repository_use_travis(
                            user_name varchar,
                            name varchar,
                            flag int,
                            primary key(user_name,name)
                         );")
=end
  result=client_160server.query("Select name,user_name from github_repository where id<20")
  result.each do|item|
    print item['user_name'],"/",item['name']," "
    flag=0
    begin
      repository=Travis::Repository.find("#{item['user_name']}/#{item['name']}"),"\n"
      flag=1
    rescue
      repository=nil
    ensure
      puts repository
    end
  end
  #rails = Travis::Repository.find('rails/rails')
end
use_travis
