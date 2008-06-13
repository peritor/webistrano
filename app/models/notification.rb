class Notification < ActionMailer::Base
  
  @@webistrano_sender_address = 'Webistrano'
  
  def self.webistrano_sender_address=(val)
    @@webistrano_sender_address = val
  end

  def deployment(deployment, email)
    @subject    = "Deployment of #{deployment.stage.project.name}/#{deployment.stage.name} finished: #{deployment.status}"
    @body       = {:deployment => deployment}
    @recipients = email
    @from       = @@webistrano_sender_address
    @sent_on    = Time.now
    @headers    = {}
  end
end
