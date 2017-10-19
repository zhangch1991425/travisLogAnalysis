require 'travis'
require 'csv'

@inputCSV="/home/zc/project/travisLogAnalysis/data/databaseData.csv"
@outputCSV="/home/zc/project/travisLogAnalysis/data/repositoryUseTravis.csv"

def travisBuildsForProject(repo)
  begin
    repository=Travis::Repository.find(repo);
    return repository.last_build_number.to_i
  rescue Exception=>e
    STDERR.puts "Exception at #{repo}"
    return false
  end
end

def useTravis
  File.open(@outputCSV,"w") do |file|
    tempRow=["username","reponame","last_build_number"]
    file.write(tempRow.to_csv)
    CSV.foreach(@inputCSV,headers: true) do |row|
      last_build_number=travisBuildsForProject("#{row[0]}/#{row[1]}")
      if last_build_number
        tempRow=["#{row[0]}","#{row[1]}","#{last_build_number}"]
        file.write(tempRow.to_csv)
      end
    end
  end
end
useTravis
