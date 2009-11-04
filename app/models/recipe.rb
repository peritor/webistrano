class Recipe < ActiveRecord::Base
  has_and_belongs_to_many :stages
  
  validates_uniqueness_of :name
  validates_presence_of :name, :body
  validates_length_of :name, :maximum => 250

  attr_accessible :name, :body, :description
  
  named_scope :ordered, :order => "name ASC"
  
  version_fu rescue nil # hack to silence migration errors when the original table is not there
  
  def validate
    check_syntax
  end
 
  def check_syntax
   return if self.body.blank?

   result = ""
   Open4::popen4 "ruby -wc" do |pid, stdin, stdout, stderr|
     stdin.write body
     stdin.close
     output = stdout.read
     errors = stderr.read
     result = output.empty? ? errors : output
   end
   
   unless result == "Syntax OK"
     line = $1.to_i if result =~ /^-:(\d+):/
     errors.add(:body, "syntax error at line: #{line}") unless line.nil?
   end
  rescue => e
    RAILS_DEFAULT_LOGGER.error "Error while validating recipe syntax of recipe #{self.id}: #{e.inspect} - #{e.backtrace.join("\n")}"
  end
 
end
