require 'travis'
require 'mysql2'
require 'csv'

def use_travis
  file=File.open("/home/zc/project/travisLogAnalysis/data/repo.csv",'w')
  client_160server=Mysql2::Client.new(:host=>'10.131.252.160',
                            :username=>'root',
                            :password=>'123456',
                            :database=>'fdroid',
                            :encoding=>'utf8'
                                     )

  result=client_160server.query("Select name,user_name from github_repository where id<20")
  result.each do|item|
    flag=0
    begin
      repository=Travis::Repository.find("#{item['user_name']}/#{item['name']}"),"\n"
      flag=1
    rescue
    ensure
      #row<<item['user_name']
      #row<<item['name']
      #row<<flag
      row=["#{item['user_name']}","#{item['name']}","#{flag}"]
      file.write(row.to_csv)  
    end
  end
  file.close
end
use_travis
