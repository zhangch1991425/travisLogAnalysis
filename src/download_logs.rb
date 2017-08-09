require 'csv'
require 'fileutils'
require 'json'
require 'net/http'
require 'open-uri'
require 'date'
require 'time'
require 'travis'
def download_job(job,name)
  log_url="https://s3.amazonaws.com/archive.travis-ci.org/jobs/#{job}/log.txt"
  puts log_url
end
def job_logs(build,sha)
  jobs=build['job_ids']
  jobs.each do |job|
    name=File.join(@parent_dir,"#{build['number']}_#{build['id']}_#{sha}_#{job}.log")
    next if File.exists?(name) and File.size(name)>1

    download_job(job,name)
  end
end
def get_build(builds,build)
  started_at=Time.parse(build['started_at']).utc.to_s
  commit=builds['commits'].find{|x| x['id']==build['commit_id']}
  job_logs(build,commit['sha'])
end
def paginate_build(last_build,repo_id)
  all_builds=[]
  begin
    url="https://api.travis-ci.org/builds?after_number=#{last_build}&repository_id=#{repo_id}"
    #puts url
    resp=open(url,'Content-Type'=>'application/json','Accept'=>'application/vnd.travis-ci.2+json')
    builds=JSON.parse(resp.read)
    builds['builds'].each do |build|
      all_builds<<get_build(builds,build)
    end
  rescue
    p $!
  ensure
  end
end
def creat_directory(user_name,repo_name)
  @parent_dir=File.join('build_logs',"#{user_name}","#{repo_name}")
  @error_file=File.join(@parent_dir,"errors")
  FileUtils::mkdir_p(@parent_dir)
  json_file=File.join(@parent_dir,'repo_data_travis.json')

  all_builds=[]

  highest_build=Travis::Repository.find("#{user_name}/#{repo_name}").last_build_number.to_i
  begin
    repo_id=JSON.parse(open("https://api.travis-ci.org/repos/#{user_name}/#{repo_name}").read)['id']
    paginate_build(highest_build,repo_id)
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
