require 'mysql2'
class MyDatabaseManage
  def mysql_initiallize
    @client = Mysql2::Client.new(:host => 'localhost', :username => 'root',:password=>'cumtzc04091751',:encoding => 'utf8mb4')
    results = @client.query('CREATE DATABASE IF NOT EXISTS Travis')
    results = @client.query('ALTER DATABASE Travis CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;')
    results = @client.query('USE Travis')
    results = @client.query('CREATE TABLE IF NOT EXISTS CIData0(
    buildNumber int,
    buildState  varchar(10),
    buildStartTime TIMESTAMP,
    buildEndTime TIMESTAMP,
    buildDuration int,
    buildIsPullRequest varchar(10),

    buildIsPush varchar(10),
    pullRequestNumber int,
    pullRequestTitle varchar(255),

    buildCommitSHA varchar(255),
    commitCompareUrl varchar(255),

    branch varchar(255),
    commitTime TIMESTAMP,
    commitMessage text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,

    jobNumber float,
    jobStartTime TIMESTAMP,
    jobEndTime TIMESTAMP,
    jobDuration int,
    jobState varchar(10),
    jobAllowFailure varchar(10),
    config text
    );
    ')
    results = @client.query('ALTER TABLE CIData0 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;')
  end

  def insert_into_mysql(h)
    statement = @client.prepare('INSERT INTO CIData0(buildNumber,buildState,buildStartTime, buildEndTime, buildDuration,
                                                     buildIsPullRequest,buildIsPush, pullRequestNumber, pullRequestTitle,
                                                     branch, commitTime, commitMessage,
                                                     buildCommitSHA, commitCompareUrl, jobNumber,
                                                     jobStartTime, jobEndTime, jobDuration, jobState,jobAllowFailure,config)
                                                     VALUES(?,?,?,?,?,
                                                            ?,?,?,?,
                                                            ?,?,?,
                                                            ?,?,?,
                                                            ?,?,?,?,?,?);')
    statement.execute(h[:buildNumber],h[:buildState],h[:buildStartTime],h[:buildEndTime],h[:buildDuration],
                      h[:buildIsPullRequest].to_s,h[:buildIsPush].to_s,h[:pullRequestNumber],h[:pullRequestTitle],
                      h[:branch],h[:commitTime],h[:commitMessage],
                      h[:buildCommitSHA],h[:commitCompareUrl],h[:jobNumber],
                      h[:jobStartTime],h[:jobEndTime],h[:jobDuration],h[:jobState],h[:jobAllowFailure].to_s,h[:config].to_s)
  end
end

