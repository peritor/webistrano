module CASClient
  module Frameworks
    module Merb
      module Filter
        attr_reader :client

        def cas_filter
          @client ||= CASClient::Client.new(config)

          service_ticket = read_ticket(self)

          cas_login_url = client.add_service_to_login_url(read_service_url(self))

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
            session[client.username_session_key]
            # Re-use the previous ticket if the user already has a local CAS session (i.e. if they were already
            # previously authenticated for this service). This is to prevent redirection to the CAS server on every
            # request.
            # This behaviour can be disabled (so that every request is routed through the CAS server) by setting
            # the :authenticate_on_every_request config option to false. 
            log.debug "Existing local CAS session detected for #{session[client.username_session_key].inspect}. "+
              "Previous ticket #{last_service_ticket.ticket.inspect} will be re-used."
              service_ticket = last_service_ticket
          end

          if service_ticket
            client.validate_service_ticket(service_ticket) unless service_ticket.has_been_validated?
            validation_response = service_ticket.response

            if service_ticket.is_valid?
              log.info("Ticket #{service_ticket.inspect} for service #{service_ticket.service.inspect} " + 
                "belonging to user #{validation_response.user.inspect} is VALID.")

              session[client.username_session_key] = validation_response.user
              session[client.extra_attributes_session_key] = validation_response.extra_attributes

              # Store the ticket in the session to avoid re-validating the same service
              # ticket with the CAS server.
              session[:cas_last_valid_ticket] = service_ticket
              return true
            else  
              log.warn("Ticket #{service_ticket.ticket.inspect} failed validation -- " + 
                "#{validation_response.failure_code}: #{validation_response.failure_message}")
              redirect cas_login_url
              throw :halt
            end
          else
            log.warn("No ticket -- redirecting to #{cas_login_url}")
            redirect cas_login_url
            throw :halt
          end
        end

        private
        # Copied from Rails adapter
        def read_ticket(controller)
          ticket = controller.params[:ticket]

          return nil unless ticket

          log.debug("Request contains ticket #{ticket.inspect}.")

          if ticket =~ /^PT-/
            ProxyTicket.new(ticket, read_service_url(controller), controller.params[:renew])
          else
            ServiceTicket.new(ticket, read_service_url(controller), controller.params[:renew])
          end
        end

        # Also copied from Rails adapter
        def read_service_url(controller)
          if config[:service_url]
            log.debug("Using explicitly set service url: #{config[:service_url]}")
            return config[:service_url]
          end

          params = controller.params.dup
          params.delete(:ticket)
          service_url = request.protocol + '://' + request.host / controller.url(params.to_hash.symbolize_keys!)
          log.debug("Guessed service url: #{service_url.inspect}")
          return service_url
        end

        def log
          ::Merb.logger
        end

        def config
          ::Merb::Plugins.config[:"rubycas-client"]
        end
      end
    end
  end
end
