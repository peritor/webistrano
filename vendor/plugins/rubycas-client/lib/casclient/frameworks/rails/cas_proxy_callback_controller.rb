require 'pstore'

# Rails controller that responds to proxy generating ticket callbacks from the CAS server and allows
# for retrieval of those PGTs.
class CasProxyCallbackController < ActionController::Base

  # Receives a proxy granting ticket from the CAS server and stores it in the database.
  # Note that this action should ALWAYS be called via https, otherwise you have a gaping security hole.
  # In fact, the JA-SIG implementation of the CAS server will refuse to send PGTs to non-https URLs.
  def receive_pgt
	#FIXME: these checks don't work because REMOTE_HOST doesn't work consistently under all web servers (for example it doesn't work at all under mongrel)
	#				... need to find a reliable way to check if the request came through from a reverse HTTPS proxy -- until then I'm disabling this check
    #render_error "PGTs can be received only via HTTPS or local connections." and return unless
    #  request.ssl? or request.env['REMOTE_HOST'] == "127.0.0.1"

    pgtIou = params['pgtIou']
    
    # CAS Protocol spec says that the argument should be called 'pgt', but the JA-SIG CAS server seems to use pgtId.
    # To accomodate this, we check for both parameters, although 'pgt' takes precedence over 'pgtId'.
    pgtId = params['pgt'] || params['pgtId']
    
    # We need to render a response with HTTP status code 200 when no pgtIou/pgtId is specified because CAS seems first
    # call the action without any parameters (maybe to check if the server responds correctly)
    render :text => "Okay, the server is up, but please specify a pgtIou and pgtId." and return unless pgtIou and pgtId
    
    # TODO: pstore contents should probably be encrypted...
    pstore = open_pstore
    
    pstore.transaction do
      pstore[pgtIou] = pgtId
    end
    
    render :text => "PGT received. Thank you!" and return
  end
  
  # Retreives a proxy granting ticket, sends it to output, and deletes the pgt from session storage.
  # Note that this action should ALWAYS be called via https, otherwise you have a gaping security hole --
  # in fact, the action will not work if the request is not made via SSL or is not local (we allow for local
  # non-SSL requests since this allows for the use of reverse HTTPS proxies like Pound).
  def retrieve_pgt
    #render_error "You can only retrieve PGTs via HTTPS or local connections." and return unless
    #  request.ssl? or request.env['REMOTE_HOST'] == "127.0.0.1"
    
    pgtIou = params['pgtIou']
    
    render_error "No pgtIou specified. Cannot retreive the pgtId." and return unless pgtIou
  
    pstore = open_pstore
  
    pgt = nil
    pstore.transaction do
      pgt = pstore[pgtIou]
    end
    
    if not pgt
      render_error "Invalid pgtIou specified. Perhaps this pgt has already been retrieved?" and return
    end
    
    render :text => pgt
    
    # TODO: need to periodically clean the storage, otherwise it will just keep growing
    pstore.transaction do
      pstore.delete pgtIou
    end
  end
  
  private
    def render_error(msg)
      # Note that the error messages are mostly just for debugging, since the CAS server never reads them.
      render :text => msg, :status => 500
    end
    
    def open_pstore
      PStore.new("#{RAILS_ROOT}/tmp/cas_pgt.pstore")
    end
end
