class Admin::BulkMessagesController < Admin::AdminControllerBase

  def new
    @bulk_message = BulkMessage.new()
  end

  def create
    @bulk_message = BulkMessage.new(params[:bulk_message])

    if @bulk_message.valid? then
      @file, @rows, @invalid_rows, @unknown, @bulk_message = upload_file_helper(@bulk_message)

      if @invalid_rows == 10 then
        # Bad input file
        flash[:error]  = "Unable to find a field with hex IDs in the first 10 lines of this file. Is it a CSV file?"
        render :action => 'new'
        return
      else
        flash[:info] = "
        <table>
          <tr><td>Uploaded file:</td><td>#{@file.original_filename}</td></tr>
          <tr><td>Rows found (including header):</td><td>#{@rows}</td></tr>
          <tr><td>Rows without hex id:</td><td>#{@invalid_rows}</td></tr>
          <tr><td>Unique users found:</td><td>#{@bulk_message.bulk_message_recipients.size}</td></tr>
          <tr><td>Unknown users:</td><td>#{@unknown.size}</td></tr>
        </table>"
      end
      @bulk_message.save()

      flash[:notice] = "Message prepared"
      #redirect_to admin_bulk_messages_send_url
      redirect_to admin_bulk_messages_url
      return
    else
      render :action => 'new'
      return
    end
  end

  def index
    @bulk_messages = BulkMessage.order('created_at desc').all
  end

  def edit
    @bulk_message = BulkMessage.find(params[:id])
  end

  def update
    @bulk_message = BulkMessage.find(params[:id])

    if @bulk_message.valid? then

      if not params[:bulk_message]['recipients_file'].nil? then
        @file, @rows, @invalid_rows, @unknown, @bulk_message = upload_file_helper(@bulk_message)

        if @invalid_rows == 10 then
          # Bad input file
          flash[:error]  = "Unable to find a field with hex IDs in the first 10 lines of this file. Is it a CSV file?"
          render :action => 'new'
          return
        else
          flash[:info] = "
        <table>
          <tr><td>Uploaded file:</td><td>#{@file.original_filename}</td></tr>
          <tr><td>Rows found (including header):</td><td>#{@rows}</td></tr>
          <tr><td>Rows without hex id:</td><td>#{@invalid_rows}</td></tr>
          <tr><td>Unique users found:</td><td>#{@bulk_message.bulk_message_recipients.size}</td></tr>
          <tr><td>Unknown users:</td><td>#{@unknown.size}</td></tr>
        </table>"
        end
      end

      @bulk_message.update_attributes(params[:bulk_message])

      flash[:notice] = "Message prepared"
      #redirect_to admin_bulk_messages_send_url
      redirect_to admin_bulk_messages_url
      return
    else
      render :action => 'new'
      return
    end

  end

  def show
    @bulk_message = BulkMessage.find(params[:id])
  end

  def recipients
    @bulk_message = BulkMessage.find(params[:id])
  end

  def test_message
    @bulk_message = BulkMessage.find(params[:id])

    begin
      UserMailer.bulk_message(@bulk_message,current_user).deliver
      current_user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) test: sent to #{current_user.email}")
    rescue Exception => e
      current_user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) test: could not be sent to #{current_user.email}: #{e.inspect()}")
    end

    @bulk_message.tested = true
    @bulk_message.tested_at = Time.now()
    @bulk_message.save!

    flash[:notice] = "Message tested: sent to your e-mail address. Please check the user log for delivery errors."
    redirect_to admin_bulk_messages_url
  end

  def send_message
    @bulk_message = BulkMessage.find(params[:id])
    if @bulk_message.recipients.size == 0 then
      flash[:error] = "Please add some recipients before sending this message."
      redirect_to admin_bulk_messages_url
      return
    end
    if @bulk_message.sent then
      flash[:error] = "Message was already sent, not re-sent."
      redirect_to admin_bulk_messages_url
      return
    end
    if not @bulk_message.tested then
      flash[:error] = "Message was not tested yet. Please click the 'test' link before you send."
      redirect_to admin_bulk_messages_url
      return
    end

    @bulk_message.recipients.each do |user|
      if user.suspended_at.nil? and (user.deactivated_at.nil? or user.can_reactivate_self) then
        begin
          UserMailer.bulk_message(@bulk_message,user).deliver
          user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) sent to #{user.email}")
        rescue Exception => e
          user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) could not be sent to #{user.email}: #{e.inspect()}")
        end
      else
        if !user.suspended_at.nil? then
          user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) was not sent to #{user.email}: user is suspended")
        elsif !user.deactivated_at.nil? and not user.can_reactivate_self then
          user.log("Bulk message with id #{@bulk_message.id} (#{@bulk_message.subject}) was not sent to #{user.email}: user is deactivated and may not reactivate themself")
        end
      end
    end

    @bulk_message.sent = true
    @bulk_message.sent_at = Time.now()
    @bulk_message.save!

    flash[:notice] = "Message sent. Please check the user log for delivery errors."
    redirect_to admin_bulk_messages_url
  end

private

  def upload_file_helper(bulk_message)
    @file = params[:bulk_message]['recipients_file']

    @bulk_message = bulk_message

    @invalid_rows = 0
    @rows = 0
    @hex_id_column = nil
    @parsed_file=CSV::Reader.parse(@file.read)
    @unknown = Array.new()
    @parsed_file.each  do |row|
      break if @invalid_rows == 10
      if not @hex_id_column.nil? then
        user = User.find_by_hex(row[@hex_id_column])
        if not user.nil? then
          if @bulk_message.bulk_message_recipients.where('user_id = ?',user.id).empty? then
            @bulk_message.bulk_message_recipients << BulkMessageRecipient.new(:user_id => user.id)
          end
        else
          # Hmm, user not found
          @unknown.push(row)
        end
      else
        @item_position = 0
        row.each do |item|
          if item =~ /^..[0-9a-f]{6}$/i then
            @hex_id_column = @item_position
            @bulk_message.bulk_message_recipients = []
            user = User.find_by_hex(row[@hex_id_column])
            if not user.nil? then
              @bulk_message.bulk_message_recipients << BulkMessageRecipient.new(:user_id => user.id)
            end
          end
          @item_position += 1
        end
        @invalid_rows += 1 if @hex_id_column.nil?
      end
      @rows += 1
    end
    return @file, @rows, @invalid_rows, @unknown, @bulk_message
  end

end

