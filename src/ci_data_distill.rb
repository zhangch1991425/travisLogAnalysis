require 'travis'
require_relative 'git_data_distill'
 class CIRepo

   #初始化函数，输入一个有效的软件项目名称,以及其本地git仓库地址
   def initialize(ownerName,repositoryName,repoGitDirectory)
     @ownerName=ownerName
     @repositoryName=repositoryName
     @repoFullName=ownerName+'/'+repositoryName
     @repoGitDirectory=repoGitDirectory
     @parentDir=File.join('..','build_logs',"#{ownerName}@#{repositoryName}")
   end

   def use_travis?
    @repo=Travis::Repository.find(@repoFullName)
    @repo.load
    #该项目最后一次build的number
    lastBuildNumber=@repo.last_build.number
    build_traverse lastBuildNumber
     Travis.clear_cache
   end

   def build_traverse(lastBuildNumber)
     for i in 40..lastBuildNumber.to_i
      build_data(@repo.build(i))
     end
   end

   def build_data(build)
     #build的number
     buildNumber=build.number
     #build的状态,string类型
     buildState=build.state
     #build的开始时间
     buildStartTime=build.started_at
     #build的运行时间
     buildDuration=build.duration
     #build的停止时间
     buildEndTime=build.finished_at
     #build是不是pull request触发的
     buildIsPullRequest=build.pull_request

     #build对应的commit相关信息进行处理
     commit=build.commit
     buildCommitSHA=commit.sha
     commitCompareUrl=commit.compare_url
     p commitCompareUrl
     #找到本次build commit对应的父build 的commit
     parentBuildCommitSHAStart=commitCompareUrl=~/[a-f0-9]{7}/
     if parentBuildCommitSHAStart==nil || commitCompareUrl=~/commit/
       p '=============BE CAREFUL============='
       return
     end
     parentBuildCommitSHA=commitCompareUrl[parentBuildCommitSHAStart,12]
     #提取git上托管的信息
     begin
      git_data(parentBuildCommitSHA,buildCommitSHA)
     rescue
       p $!
=begin
       if parentBuildNumber>=1 && (temp=@repo.build(parentBuildNumber.to_s).commit.sha).include?(parentBuildCommitSHA)
         parentBuildNumber= parentBuildNumber-1
         p temp
       end
       searchParentCommitSHA=@repo.build(parentBuildNumber).commit.sha
       retry
=end
     end

     #遍历build包含的job的信息
     build.jobs.each do |job|
       job_data job
     end

   end

   def job_data(job)
     #返回job的number,string类型，格式"4668.1"
     jobNumber=job.number
     #job的开始时间
     jobStartTime=job.started_at
     #job的停止时间
     jobEndTime=job.finished_at
     #job的状态
     jobState=job.state
     #job运行的时间
     jobDuration=job.duration
     #job是否允许失败
     jobAllowFailure=job.allow_failure

     p jobNumber
   end

   def git_data(parentSHA,sha)
    gitDataDistill=GitDataDistill.new @repoGitDirectory
    result=gitDataDistill.compare_diff(parentSHA,sha).get_data
   end
 end
cirepo=CIRepo.new 'junit-team','junit5','D:\projects\junit5'
cirepo.use_travis?