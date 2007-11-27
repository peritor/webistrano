module TzTimeHelpers
  module ActiveRecordMethods
    # Adds the given list of attributes to a class inheritable array #tz_time_attributes.
    # All the attributes will have their timezones fixed in a before_save callback, and 
    # will have a getter method created that converts UTC times from the database into a local
    # TzTime.  The getter method is important because TzTime values are saved to the database
    # as UTC.  The getter lets you access the local time without changing your application.
    def tz_time_attributes(*attributes)
      class_inheritable_array :tz_time_attributes, :instance_writer => false
      self.tz_time_attributes = attributes
      class_eval do
        attributes.each do |attribute|
          define_method attribute do
            time = read_attribute(attribute)
            if (time.acts_like?(:time) || time.acts_like?(:date)) && time.utc?
              write_attribute(attribute, TzTime.at(Time.at(TzTime.zone.utc_to_local(time))))
            else
              time
            end
          end
        end
        
        protected
          def fix_timezone
            tz_time_attributes.each do |attribute|
              time  = read_attribute(attribute)
              fixed = (time.acts_like?(:time) || time.acts_like?(:date)) ? TzTime.at(time) : nil
              write_attribute(attribute, fixed)
            end
          end
      end
      before_validation :fix_timezone
    end
  end
end