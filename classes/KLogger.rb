require 'json'

class KLogger
  CONST_DEBUG = 1;
  CONST_INFO = 2;
  CONST_WARN = 3;
  CONST_ERROR = 4;
  CONST_FATAL = 5;
  CONST_OFF = 6;
  
  @@MesageQueue
  @@Priority = CONST_DEBUG
  
  def initialize(priority)
    if @@Priority == CONST_OFF
      return
    end
    @@MessageQueue = [];
    @@Priority = priority
  end
  
  def LogInfo(line)
    Log(line, CONST_INFO)
  end
  
  def LogDebug(line)
    Log(line, CONST_DEBUG)
  end
  
  def Log(line, priority)
    if @@Priority <= priority
      status = getTimeLine(priority)
      writeLine(status+ line)
    end
  end
  
  def writeLine(line)
    if @@Priority != CONST_OFF
      puts line
    end
  end
  
  def getTimeLine(priority)
    case priority
      when CONST_INFO
        return "[INFO] "
      when CONST_DEBUG
        return "[DEBUG] "
      else
        return "[LOG] "
    end
  end
  
end
