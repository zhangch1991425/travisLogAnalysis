require 'travis'
require 'csv'

@input_CSV="/home/zc/project/travisLogAnalysis/data/repositoryUseTravis.csv"

def getRepositoryLog(repo)
  @parent_dir=File.join('build_logs',repo.gsub(/\//,'@'))
  #return if File.exist?(@parent_dir)
  FileUtils.mkdir_p(@parent_dir) unless File.exist?(@parent_dir)
  begin
    repository=Travis::Repository.find(repo)
  rescue
    sleep 5
    retry
  end

  repository.each_build do |build|
    build.jobs.each do |job|
      name=File.join(@parent_dir, "#{job.number}.log")
      next if File.exist?(name)&&File.size(name)!=0
      puts job.log.body
      File.open(name,'w') do |file|
        flag=0
        begin
          file.write(job.log.body)
        rescue
          sleep 5
          flag=flag+1
          retry if flag<5
        end
      end
    end
  end
end

def eachRepository
  #getRepositoryLog("junit-team/junit5")
  getRepositoryLog "zhangch1991425/defectpatternanalysis"
end
eachRepository