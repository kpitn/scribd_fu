module ScribdFuHelper
  # Available parameters for the JS API
  # http://www.scribd.com/publisher/api/api?method_name=Javascript+API
  AVAILABLE_JS_PARAMS = [ :height, :width, :page, :my_user_id, :search_query,
                          :jsapi_version, :disable_related_docs, :mode, :auto_size ]

  AVAILABLE_JS_EVENTS = [ :iPaperReady, :pageChanged, :viewModeChanged, :zoomChanged ]
  #iPaperReady     = Signals when it's safe to begin using the api object methods. Fired when iPaper has finished successfully loading the first page of the current document.
  #pageChanged     = Fired whenever a user has moved to a new page. Use api.getPage() to get the new page.
  #viewModeChanged = Fired when iPaper has changed view modes. Use api.getViewMode() to get the current view mode.
  #zoomChanged     = Fired when the zoom level has changed. Use api.getZoom() to get the current zoom level.

  # Displays the scribd object for the attachment on the given +object+. If
  # +alt_text_or_attribute+ is given, then it will be used as the alternate text
  # for an Attachment_fu model, or as the attribute name for a Paperclip
  # model. If you want to specify alternate text for a Paperclip model, use the
  # last parameter, +alt_text_if_paperclip+.
  #
  # If you are using Paperclip, you _must_ specify +alt_text_or_attribute+ as
  # the attribute on which the scribd object exists.
  #
  # For example, using Attachment_fu:
  #  <%= display_scribd document %>
  #  <%= display_scribd document, 'You need Flash to view this document' %>
  #
  # Using Paperclip:
  #  <%= display_scribd user, :biography %>
  #  <%= display_scribd user, :biography, 'You need Flash for biographies." %>
  #
  # Using Options :
  # :params or :events
  # See on the top of this document to this available parameters or events.

  def display_scribd(object, alt_text_or_attribute = '', options={},alt_text_if_paperclip = nil)
    # Resolve the right scribd ID, access key, and alt text.
    if object.respond_to?("scribd_id")
      scribd_id = object.scribd_id
      scribd_ak = object.scribd_access_key

      alt_text = alt_text_or_attribute
    else
      scribd_id = object.send "#{alt_text_or_attribute}_scribd_id"
      scribd_ak = object.send "#{alt_text_or_attribute}_scribd_access_key"

      alt_text = alt_text_if_paperclip
    end

    begin
      # Collect a set of addParam statements to set up JS parameters for the scribd document
      # (only if they are valid).
      param_includes = options[:params].collect do |param, value|
        "scribd_doc_#{scribd_id}.addParam('#{param}', '#{value}');" if AVAILABLE_JS_PARAMS.include?(param)
      end.compact.join("\n")
    rescue
      # Where is 'options' coming from???
    end

    begin
      # Collect a set of addEventListener statements to set up JS events for the scribd document
      # (only if they are valid).
      event_includes = options[:events].collect do |event, value|
        "scribd_doc_#{scribd_id}.addEventListener('#{event}', #{value});" if AVAILABLE_JS_EVENTS.include?(event)
      end.compact.join("\n")
    rescue
      # Where is 'options' coming from???
    end

    # <script type="text/javascript" src="http://www.scribd.com/javascripts/view.js"></script>
    if !scribd_id.blank?
    <<-END
      <div id="embedded_flash_#{scribd_id}" class="embedd_flash">#{alt_text}</div>
      <script type="text/javascript">
        var scribd_doc_#{scribd_id} = scribd.Document.getDoc(#{scribd_id}, '#{scribd_ak}');
        #{param_includes}
        #{event_includes}
        scribd_doc_#{scribd_id}.write("embedded_flash_#{scribd_id}");
      </script>
    END
    else
      ""
    end
  end
end