require 'travis'
require 'csv'

@inputCSV="/home/zc/project/travisLogAnalysis/data/databaseData.csv"
@outputCSV="/home/zc/project/travisLogAnalysis/data/repositoryUseTravis.csv"

def travisBuildsForProject(repo)
  count=0
  begin
    repository=Travis::Repository.find(repo);
    return repository.last_build_number.to_i
  rescue Exception=>e
    sleep 15
    count=count+1
    retry if count<6
    STDERR.puts "Exception at #{repo}  Exception:#{e}"
    return false
  end
end

def CSVExist
  CSV.foreach(@inputCSV,headers: true) do |rowIn|
    flag=0
    CSV.foreach(@outputCSV,headers: true) do |rowOut|
      if rowOut[0]==rowIn[0] and rowOut[1]==rowIn[1]
        puts "In:#{rowIn[0]}/#{rowIn[1]} Out:#{rowOut[0]}/#{rowOut[1]}"
        flag=1
        break
      end
    end
    if flag==0
      file=File.open(@outputCSV,'a')
      last_build_number=travisBuildsForProject("#{rowIn[0]}/#{rowIn[1]}")
      if last_build_number
        tempRow=["#{row[0]}","#{row[1]}","#{last_build_number}"]
        file.write(tempRow.to_csv)
      end
      file.close
    end
  end
end
def CSVNotExist
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
def outputFileExist?
  if File.exist?(@outputCSV)
    CSVExist
  else
    CSVNotExist
  end
end
outputFileExist?
