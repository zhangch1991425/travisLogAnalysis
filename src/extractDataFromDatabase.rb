require 'mysql2'
require 'csv'

def extractDataFromDatabase
  client_server=Mysql2::Client.new(:host=>'10.141.221.73',
                            :username=>'root',
                            :password=>'root',
                            :database=>'github',
                            :encoding=>'utf8'
                                     )

  result=client_server.query("Select name,user_name,stars from java_github_repository_1 where stars>=3000")
  File.open("/home/zc/project/travisLogAnalysis/data/databaseData.csv",'w') do |file|
    row=["username","reponame","stars"]
    file.write(row.to_csv)	 
    result.each do|item|
      row=["#{item['user_name']}","#{item['name']}","#{item['stars']}"]
      file.write(row.to_csv)  
    end
  end
end
extractDataFromDatabase
