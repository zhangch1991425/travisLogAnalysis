require 'csv'
require 'fileutils'
require 'json'
require 'net/http'
require 'open-uri'
require 'date'
require 'time'

def creat_directory(user_name,repo_name)
  @parent_dir=File.join('build_logs',"#{user_name}","#{repo_name}")
  @error_file=File.join(@parent_dir,"errors")
  FileUtils::mkdir_p(@parent_dir)
  json_file=File.join(@parent_dir,'repo_data_travis.json')

  all_builds=[]
  begin
    repo_id=JSON.parse(open("https://api.travis-ci.org/repos/#{user_name}/#{repo_name}").read)
    #repo_id = JSON.parse(open("https://api.travis-ci.org/repos/#{user_name}/#{repo_name}").read)['id']
    #repo_id=JSON.parse(Net::HTTPS.new("https://api.travis-ci.org/repos/#{user_name}/#{repo_name}").get('/'))
    puts repo_id
  rescue
    error_message="error happens at https://api.travis-ci.org/repos/#{user_name}/#{repo_name}"
    puts error_message
    puts $!
    File.open(@error_file,'a'){|f| f.puts error_message}
  end
end


def select_item
  CSV.foreach("/home/zc/project/travisLogAnalysis/data/repo.csv"){|row|
    if row[2].to_i==1
      creat_directory(row[0],row[1])
    end
  }
end
select_item
