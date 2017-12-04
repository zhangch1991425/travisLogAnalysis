require 'git'
class GitDataDistill
  def initialize(repoGitDirectory)
    @gitRepo=Git.open repoGitDirectory
  end

  def compare_diff(firstSHA,secondSHA)
    @diffResult=@gitRepo.diff(firstSHA,secondSHA)
    return self
  end

  def get_data
    gitHash=Hash.new(0)
    gitHash[:changeFileNumber]=@diffResult.size
    gitHash[:changeFileAddition]=@diffResult.insertions
    gitHash[:changeFileDeletion]=@diffResult.deletions
    @diffResult.stats[:files].each do |key,value|
      case file_type_judge(key)
        when :ymlFile
          gitHash[:ymlFileNumber]+=1
          gitHash[:ymlFileAddition]+=value[:insertions]
          gitHash[:ymlFileDeletion]+=value[:deletions]
          gitHash[:configFileNumber]+=1
          gitHash[:configFileAddition]+=value[:insertions]
          gitHash[:configFileDeletion]+=value[:deletions]
        when :configFile
          gitHash[:configFileNumber]+=1
          gitHash[:configFileAddition]+=value[:insertions]
          gitHash[:configFileDeletion]+=value[:deletions]
        when :textFile
          gitHash[:textFileNumber]+=1
          gitHash[:textFileAddition]+=value[:insertions]
          gitHash[:textFileDeletion]+=value[:deletions]
        when :codeFile
          gitHash[:codeFileNumber]+=1
          gitHash[:codeFileAddition]+=value[:insertions]
          gitHash[:codeFileDeletion]+=value[:deletions]
      end
    end
    return gitHash
  end

  def file_type_judge(filePath)
    #p filePath
    if filePath=~%r{(xml|gradle|yml)\}?$}
      return :ymlFile
    elsif filePath=~%r{(xml|xsd|gradle|properties)\}?$}
      return :configFile
    elsif filePath=~%r{(md|txt|adoc|html|gitignore)\}?$}
      return :textFile
    elsif filePath=~%r{(java|kt|groovy)\}?$}
      return :codeFile
    else
      p filePath
      return nil
    end
  end
end
g=GitDataDistill.new('D:\projects\junit5')
result=g.compare_diff('6f57d2511cb6','ccdbc6d9a3a0').get_data
p result
