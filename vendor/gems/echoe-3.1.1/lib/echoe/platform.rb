
### Platform check regexes

module Platform
  def self.windows?
    @windows ||= RUBY_PLATFORM =~ /djgpp|(cyg|ms|bcc)win|mingw/
    !@windows.nil?
  end

  def self.gcc?
    @gcc ||= RUBY_PLATFORM =~ /mingw/
    !@gcc.nil?
  end

  def self.msvc?
    @msvc ||= RUBY_PLATFORM =~ /mswin/
    !@msvc.nil?
  end
  
  def self.java?
    @java ||= RUBY_PLATFORM =~ /java/
    !@java.nil?
  end
  
  def self.suffix
    @suffix ||= Gem.default_exec_format[2..-1]
  end
  
  def self.rake
    windows? ? "rake#{suffix}.bat" : "rake#{suffix}"
  end
  
  def self.make
    msvc? ? 'nmake' : 'make'
  end
end
