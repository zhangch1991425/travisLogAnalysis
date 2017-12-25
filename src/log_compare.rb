require 'mysql2'
def gradle_log_analyze(filePath,jobNumber)
  file=File.new filePath
  file.each_line do |line|
    case
      when ci_related(line)
        p '=============ci related error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when compile_error(line)
        p '=============compile error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when configure_error(line)
        p '=============configure error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when static_check_error(line)
        p '=============static check error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when failed_test(line)
        p '=============failed test=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when git_error(line)
        p '=============git error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
      when download_error(line)
        p '=============download error=============='
        p filePath
        p line
        @h[jobNumber]=1
      #break
    end
  end
  file.close
end

def ci_related(line)
  if line=~%r<No output has been received in the last>#3108 过去10分钟没有接到新的日志输出
    true
  end
end

def compile_error(line)
  if line=~%r<Compilation failed>#210 编译错误
    true
  end
end

def configure_error(line)
  if line=~%r<[Nn]o .*file.*found>#build1 使用了默认的脚本进行构建，导致缺少缺少相应文件
    true unless line=~%r<Using default configuration>
  elsif line=~%r<gradlew: command not found>#build5 应该是缺少gradlew相应的文件
    true
  elsif line=~%r<Build file.*build.gradle>#383 build.gradle对应的错误
    true
  elsif line=~%r<A problem occurred configuring>#619 无法解析所有依赖
    true
  elsif line=~%r<The command.*pip.*failed and exited>#697 pip命令运行引起的错误
    true
  elsif line=~%r<Unsupported major.minor version>#977 gradle对应的错误，插件版本不對
    true
  elsif line=~%r<Could not resolve all dependencies for configuration>#1052應該是配置文件有錯誤,这条规则可能很不合理
    true
  elsif line=~ %r<Could not find property.*gradle>#1486 找不到该属性Could not find property 'includeTags' on org.junit.gen5.gradle.JUnit5Extension_Decorated@7e01d838.
    true
  elsif line=~%r<Received status code 500 from server>#2078 应该是下载问题
    true
  elsif line=~%r<Error: Could not create the Java Virtual Machine>#
    true
  end
end

def static_check_error(line)
  if line=~%r<:.*spotless.*FAILED>#77spotless检测出的错误
    true
  elsif line=~%r<Checkstyle rule violations were found>#1000checkstyle檢查出的錯誤
    true
  end
end

def failed_test(line)
  if line=~%r<There were failing tests>#194测试用例失败
    true
  elsif line=~%r<^:.*[tT]est.*(failed|FAILED)>#959测试用例失败
    true
    #elsif line=~%r<[^0] tests failed>#3213测试用例失败
    #  true
  end
end

def git_error(line)
  if line=~%r<Could not find remote branch> #293 找不到git上的分支
    true
  elsif line=~%r<reference is not a tree>#1860 git报的一个错误
    true
  end
end

def download_error(line)
  if line=~%r<Connection has been shutdown>#761 下载导致的错误
    true
  elsif line=~%r<Exception.*Server returned HTTP response code>#254 下载错误
  end
end
@h=Hash.new(0)
@client = Mysql2::Client.new(:host => 'localhost', :username => 'root',:password=>'cumtzc04091751',:encoding => 'utf8mb4')
@client.query('USE Travis')
@results=@client.query("SELECT jobNumber,jobState FROM CIData0 WHERE jobState='failed' OR jobState='errored'")
@results.each do |row|
  if row["jobNumber"]<4900
    @h[row["jobNumber"]]=0
    gradle_log_analyze '/home/zc/project/travisLogAnalysis/build_logs/junit-team@junit5/'+row["jobNumber"].to_s.gsub(/\./,'@')+'.log',row["jobNumber"]
  end
end
@h.each do |key,value|
  puts "#{key}    #{value}"
end

