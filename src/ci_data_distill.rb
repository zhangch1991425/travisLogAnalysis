require 'travis'
#require_relative 'git_data_distill'
require_relative 'database_manage'
 class CIRepo

   #初始化函数，输入一个有效的软件项目名称,以及其本地git仓库地址
   def initialize(ownerName,repositoryName,repoGitDirectory)
     @ownerName=ownerName
     @repositoryName=repositoryName
     @repoFullName=ownerName+'/'+repositoryName
     @repoGitDirectory=repoGitDirectory
     @h=Hash.new;
     @myDatabaseManage=MyDatabaseManage.new
     @myDatabaseManage.mysql_initiallize
     #@parentDir=File.join('..','build_logs',"#{ownerName}@#{repositoryName}")
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
     for i in 1..lastBuildNumber.to_i
      build_data(@repo.build(i))
     end
   end

   def build_data(build)
     #build的number
     @h[:buildNumber]=build.number
     #build的状态,string类型
     @h[:buildState]=build.state
     #build的开始时间
     @h[:buildStartTime]=build.started_at
     #build的运行时间
     @h[:buildDuration]=build.duration
     #build的停止时间
     @h[:buildEndTime]=build.finished_at
     #build是不是pull request触发的
     @h[:buildIsPullRequest]=build.pull_request
     @h[:buildIsPush]=build.push?
     @h[:pullRequestNumber]=build.pull_request_number
     @h[:pullRequestTitle]=build.pull_request_title

=begin
     p "job_ids #{build.job_ids} #{build.job_ids.class}"
     p "jobs #{build.jobs} #{build.jobs.class}"
     p "commit_id #{build.commit_id} #{build.commit_id.class}"
     p "job_ids #{build.job_ids} #{build.job_ids.class}"
     p "pull_request_number  #{build.pull_request_number} #{build.pull_request_number.class}"
     p "pull_request_title  #{build.pull_request_title} #{build.pull_request_title.class}"
     p "repository  #{build.repository} #{build.repository.class}"
     p "repository_id  #{build.repository_id} #{build.repository_id.class}"
     p "branch_info  #{build.branch_info} #{build.branch_info.class}"
     p "inspect_info  #{build.inspect_info} #{build.inspect_info.class}"
     p "push?  #{build.push?} #{build.push?.class}"
     p "pusher_channels  #{build.pusher_channels} #{build.pusher_channels.class}"
=end
     #build对应的commit相关信息进行处理
     commit=build.commit
     @h[:buildCommitSHA]=commit.sha
     commitCompareUrl=commit.compare_url
     @h[:commitCompareUrl]=commit.compare_url
     @h[:branch]=commit.branch
     @h[:commitTime]=commit.committed_at
     @h[:commitMessage]=commit.message
=begin
     p "author_email #{commit.author_email} #{commit.author_email.class}"
     p "author_name #{commit.author_name} #{commit.author_name.class}"
     p "branch #{commit.branch} #{commit.branch.class}"
     p "committed_at #{commit.committed_at} #{commit.committed_at.class}"
     p "committer_email #{commit.committer_email} #{commit.committer_email.class}"
     p "committer_name #{commit.committer_name} #{commit.committer_name.class}"
     p "message #{commit.message} #{commit.message.class}"
     p "sha #{commit.sha} #{commit.sha.class}"
     p "inspect_info #{commit.inspect_info} #{commit.inspect_info.class}"
     p "subject #{commit.subject} #{commit.subject.class}"
=end
=begin
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

       if parentBuildNumber>=1 && (temp=@repo.build(parentBuildNumber.to_s).commit.sha).include?(parentBuildCommitSHA)
         parentBuildNumber= parentBuildNumber-1
         p temp
       end
       searchParentCommitSHA=@repo.build(parentBuildNumber).commit.sha
       retry


     end
=end
     #遍历build包含的job的信息
     build.jobs.each do |job|
       job_data job
     end

   end

   def job_data(job)
     #返回job的number,string类型，格式"4668.1"
     @h[:jobNumber]=job.number
     p "#{@h[:jobNumber]}"
     #job的开始时间
     @h[:jobStartTime]=job.started_at
     #job的停止时间
     @h[:jobEndTime]=job.finished_at
     #job的状态
     @h[:jobState]=job.state
     #job运行的时间
     @h[:jobDuration]=job.duration
     #job是否允许失败
     jobAllowFailure=job.allow_failure
     @h[:jobAllowFailure]=job.allow_failure
     @h[:config]=job.config
=begin
     p "annotations #{job.annotations} #{job.annotations.class}"
     p "build #{job.build} #{job.build.class}"
     p "build_id #{job.build_id} #{job.build_id.class}"
     p "commit #{job.commit} #{job.commit.class}"
     p "commit_id #{job.commit_id} #{job.commit_id.class}"
     p "config #{job.config} #{job.config.class}"
     p "log_id #{job.log_id} #{job.log_id.class}"
     p "queue #{job.queue} #{job.queue.class}"
     p "repository #{job.repository} #{job.repository.class}"
     p "repository_id #{job.repository_id} #{job.repository_id.class}"
     p "tags #{job.tags} #{job.tags.class}"
=end
     @myDatabaseManage.insert_into_mysql(@h)
   end

   def git_data(parentSHA,sha)
    gitDataDistill=GitDataDistill.new @repoGitDirectory
    result=gitDataDistill.compare_diff(parentSHA,sha).get_data
   end
 end
cirepo=CIRepo.new 'junit-team','junit5','/home/zc/project/junit5'
cirepo.use_travis?