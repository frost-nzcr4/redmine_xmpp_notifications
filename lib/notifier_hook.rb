class NotifierHook < Redmine::Hook::Listener
  
#TODO: it is plans to rename hooks in upstream
  def controller_issues_new_after_save(context={})
    issue = context[:issue]
    deliver "new", issue
  end
  
  def controller_issues_edit_after_save(context={})
    issue = context[:issue]
    journal = context[:journal]
    deliver "edit", issue, journal
  end
  
  
  private
  
  
  # Compose localized message.
  #
  # @param type [String] A type of hook.
  # @param issue [Issue] An issue in context of hook.
  # @param journal [Journal, nil] A journal in context of hook.
  # @return [String] A loclaized message.
  def compose_message(type, issue, journal)
    redmine_url = "#{Setting[:protocol]}://#{Setting[:host_name]}"
    text = ""
    
    if type == "new"
      text = l(:xmpp_issue_created) + " ##{issue.id}\n\n"
      text += l(:field_author) + ": #{issue.author.name}\n"
    elsif type == "edit"
      text = l(:xmpp_issue_updated) + " ##{issue.id}\n\n"
      text += l(:xmpp_update_author) + ": #{journal.user.name}\n"
    end
    
    text += l(:field_subject) + ": #{issue.subject}\n"
    text += l(:field_url) + ": #{redmine_url}/issues/#{issue.id}\n"
    text += l(:field_project) + ": #{issue.project}\n"
    text += l(:field_tracker) + ": #{issue.tracker.name}\n"
    text += l(:field_priority) + ": #{issue.priority.name}\n"
    if issue.assigned_to
      text += l(:field_assigned_to) + ": #{issue.assigned_to.name}\n"
    end
    if issue.start_date
      text += l(:field_start_date) + ": #{issue.start_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.due_date
      text += l(:field_due_date) + ": #{issue.due_date.strftime("%d.%m.%Y")}\n"
    end
    if issue.estimated_hours
      text += l(:field_estimated_hours) + ": #{issue.estimated_hours} " + l(:field_hours) + "\n"
    end
    if issue.done_ratio
      text += l(:field_done_ratio) + ": #{issue.done_ratio}%\n"
    end
    if issue.status
      text += l(:field_status) + ": #{issue.status.name}\n"
    end
    
    if type == "new"
      text += "\n\n#{issue.description}"
    elsif type == "edit"
      text += "\n\n#{journal.notes}"
    end
    text
  end
  
  # Deliver the message to users.
  #
  # @param type [String] A type of hook.
  # @param issue [Issue] An issue in context of hook.
  # @param journal [Journal, nil] A journal in context of hook.
  def deliver(type, issue, journal = nil)
    config = Setting.plugin_redmine_xmpp_notifications
    begin
      client = Jabber::Simple.new config["jid"], config["jidpassword"]
      
      notified = User.active
      
      jids = notified.collect(&:xmpp_jid).flatten.compact
      Rails.logger.info "Sending XMPP notification to: #{jids.join(', ')}"
      
      notified.each do |user|
        if user.xmpp_jid.nil? || user.xmpp_jid == "" || !user.notify_about?(issue)
          next
        end
        set_language_if_valid(user.language)
        message = compose_message type, issue, journal
        client.deliver user.xmpp_jid, message
      end
    rescue Jabber::JabberError, SocketError => e
      Rails.logger.error "#{e.class} (#{e.message})"
    ensure
      sleep 2  # Wait before disconnect otherwise last message could be lost.
      client.disconnect unless client.nil?
    end
  end
  
end
