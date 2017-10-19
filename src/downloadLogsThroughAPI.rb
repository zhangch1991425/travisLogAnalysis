
require 'travis'
require 'csv'

@input_CSV="/home/zc/project/travisLogAnalysis/data/repositoryUseTravis.csv"

def getRepositoryLog(repo)
  @parent_dir=File.join('build_logs',repo.gsub(/\//,'@'))
  FileUtils.mkdir_p(@parent_dir) unless File.exist?(@parent_dir)
  repository=Travis::Repository.find(repo) 
  repository.each_build do |build|
    puts "#{build.number}:#{build.state}"
    build.jobs.each do |job|
      puts "#{job.id}  #{job.number} took #{job.duration} seconds"
    end
  end
  puts repository.last_build.jobs.first.log.body
end

def eachRepository
  CSV.foreach(@input_CSV,headers:true) do |row|
      getRepositoryLog("#{row[0]}/#{row[1]}") if row[2].to_i != 0
  end
end
eachRepository
