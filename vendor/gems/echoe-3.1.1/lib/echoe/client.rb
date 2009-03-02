# Fixes for Rubyforge 1.0.0 client.rb

class RubyForge::Client
  def boundary_data_for(boundary, parameters)
    parameters.sort_by {|k,v| k.to_s }.map { |k,v|
      parameter = "--#{boundary}\r\nContent-Disposition: form-data; name=\"" +
          WEBrick::HTTPUtils.escape_form(k.to_s) + "\""

      if v.respond_to?(:path)
        parameter += "; filename=\"#{File.basename(v.path)}\"\r\n"
        parameter += "Content-Transfer-Encoding: binary\r\n"
        parameter += "Content-Type: text/plain"
      end
      parameter += "\r\n\r\n"

      if v.respond_to?(:path)
        parameter += v.read
      elsif 
        parameter += v.to_s
      end

      parameter
    }.join("\r\n") + "\r\n--#{boundary}--\r\n"
  end  
end
