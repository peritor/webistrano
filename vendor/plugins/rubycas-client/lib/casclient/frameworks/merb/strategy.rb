# The 'cas' strategy attempts to login users based on the CAS protocol 
# http://www.ja-sig.org/products/cas/overview/background/index.html
# 
# install the rubycas-client gem
# http://rubyforge.org/projects/rubycas-client/
#
require 'casclient'
class Merb::Authentication
  module Strategies
    class CAS < Merb::Authentication::Strategy

      include CASClient

      def run!
        @client ||= Client.new(config)

        service_ticket = read_ticket

        cas_login_url = @client.add_service_to_login_url(service_url)

        last_service_ticket = session[:cas_last_valid_ticket]
        if (service_ticket && last_service_ticket && 
            last_service_ticket.ticket == service_ticket.ticket && 
            last_service_ticket.service == service_ticket.service)

          # warn() rather than info() because we really shouldn't be re-validating the same ticket. 
          # The only time when this is acceptable is if the user manually does a refresh and the ticket
          # happens to be in the URL.
          log.warn("Reusing previously validated ticket since the new ticket and service are the same.")
          service_ticket = last_service_ticket
        elsif last_service_ticket &&
          !config[:authenticate_on_every_request] && 
          session[@client.username_session_key]
          # Re-use the previous ticket if the user already has a local CAS session (i.e. if they were already
          # previously authenticated for this service). This is to prevent redirection to the CAS server on every
          # request.
          # This behaviour can be disabled (so that every request is routed through the CAS server) by setting
          # the :authenticate_on_every_request config option to false. 
          log.debug "Existing local CAS session detected for #{session[@client.username_session_key].inspect}. "+
                  "Previous ticket #{last_service_ticket.ticket.inspect} will be re-used."
                  service_ticket = last_service_ticket
        end

        if service_ticket
          @client.validate_service_ticket(service_ticket) unless service_ticket.has_been_validated?
          validation_response = service_ticket.response

          if service_ticket.is_valid?
            log.info("Ticket #{service_ticket.inspect} for service #{service_ticket.service.inspect} " + 
                    "belonging to user #{validation_response.user.inspect} is VALID.")

            session[@client.username_session_key] = validation_response.user
            session[@client.extra_attributes_session_key] = validation_response.extra_attributes

            # Store the ticket in the session to avoid re-validating the same service
            # ticket with the CAS server.
            session[:cas_last_valid_ticket] = service_ticket
            return true
          else  
            log.warn("Ticket #{service_ticket.ticket.inspect} failed validation -- " + 
                    "#{validation_response.failure_code}: #{validation_response.failure_message}")
            redirect!(cas_login_url)
            return false
          end
        else
          log.warn("No ticket -- redirecting to #{cas_login_url}")
          redirect!(cas_login_url)
          return false
        end
      end

      def read_ticket
        ticket = request.params[:ticket]

        return nil unless ticket

        log.debug("Request contains ticket #{ticket.inspect}.")

        if ticket =~ /^PT-/
          ProxyTicket.new(ticket, service_url, request.params[:renew])
        else
          ServiceTicket.new(ticket, service_url, request.params[:renew])
        end
      end

      def service_url
        if config[:service_url]
          log.debug("Using explicitly set service url: #{config[:service_url]}")
          return config[:service_url]
        end

        params = request.params.dup
        params.delete(:ticket)
        service_url = "#{request.protocol}://#{request.host}" + request.path
        log.debug("Guessed service url: #{service_url.inspect}")
        return service_url
      end

      def config
        ::Merb::Plugins.config[:"rubycas-client"]
      end

      def log
        ::Merb.logger
      end

    end # CAS
  end # Strategies
end

