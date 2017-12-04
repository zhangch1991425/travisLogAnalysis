class LogTypeJudge
  def LogTypeJudge.type_judge(filePath)
    @logFile=File.read(filePath)
    if @logFile.scan(/(Reactor Summary|mvn test)/m).size >= 2

    elsif @logFile.scan(/gradle/m).size >= 2
      gradle_log_analyze
    else

    end
  end

  def gradle_log_analyze（）
    #5033报的错误
    case @logFile
      when %r<Error: Could not create the Java Virtual Machine>
        puts 'configure error'
when %r<>
    end
  end
end
LogTypeJudge.typeJudge('D:\junit-team@junit5\1_failed_fede50e0c40a803b87603312174f31282e6aeb06_73507737_failed.log')