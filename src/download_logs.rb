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
  log=Net::HTTP.get_response(URI.parse(log_url)).body
  File.open(name,'w'){|f| f.puts log}
  log=''
end
def job_logs(build,sha)
  jobs=build['job_ids']
  #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  #puts build
  #puts "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
  #puts jobs
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

      build_data = {
        :build_id => build['id'],
        :commit => commit['sha'],
        :pull_req => build['pull_request_number'],
        :branch => commit['branch'],
        # [doc] The build status (such as passed, failed, ...) as returned from the Travis CI API.
        :status => build['state'],

        # [doc] The full build duration as returned from the Travis CI API.
        :duration => build['duration'],
        :started_at => started_at, # in UTC

        # [doc] The unique Travis IDs of the jobs, in a string separated by `#`.
        :jobs => build['job_ids'],

        #:jobduration => build.jobs.map { |x| "#{x.id}##{x.duration}" }
        :event_type => build['event_type']
    }

    return build_data
end
def paginate_build(last_build,repo_id)
  all_builds=[]
  begin
    url="https://api.travis-ci.org/builds?after_number=#{last_build}&repository_id=#{repo_id}"
    #puts url
    #puts "============================================================="
    resp=open(url,'Content-Type'=>'application/json','Accept'=>'application/vnd.travis-ci.2+json')
    builds=JSON.parse(resp.read)
    builds['builds'].each do |build|
      #puts build
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
    (highest_build-2..highest_build).reverse_each do |last_build|
      all_builds<<paginate_build(last_build,repo_id)
    end   
  rescue
    error_message="error happens at find https://api.travis-ci.org/repos/#{user_name}/#{repo_name}"
    puts error_message
    File.open(@error_file,'w'){|f| f.puts error_message}
  end
end


def select_item
  CSV.foreach("/home/zc/project/travisLogAnalysis/data/repo.csv") do |row|
    next if row[0].nil?||row[1].nil? 
    creat_directory(row[0],row[1]) if row[2].to_i==1
  end
end
select_item
