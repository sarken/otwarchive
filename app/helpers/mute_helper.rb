module MuteHelper
  def mute_link(user, mute: nil)
    if mute.nil?
      mute = user.mute_by_current_user
      muting_user = current_user
    else
      muting_user = mute.muter
    end

    if mute
      link_to(t("muted.unmute"), confirm_unmute_user_muted_user_path(muting_user, mute))
    else
      link_to(t("muted.mute"), confirm_mute_user_muted_users_path(muting_user, muted_id: user))
    end
  end

  def mute_css
    return if current_user.nil?

    Rails.cache.fetch(mute_css_key(current_user)) do
      mute_css_uncached(current_user)
    end
  end

  def mute_css_uncached(user)
    user.reload

    return if user.muted_users.empty?
 
    css_classes = user.muted_users.map { |muted_user| ".user-#{muted_user.id}" }.join(", ")

    "<style>#{css_classes} { display: none !important; visibility: hidden !important; }</style>".html_safe
  end

  def mute_javascript
    return if current_user.nil?

    Rails.cache.fetch(mute_javascript_key(current_user)) do
      mute_javascript_uncached(current_user)
    end
  end

  def mute_javascript_uncached(user)
    user.reload

    return if user.muted_users.empty?

    comment_selectors = user.muted_users.map { |muted_user| ".comment.user-#{muted_user.id}" }.join(", ")
    comment_placeholder = I18n.translate("muted.placeholder.comment")

    cocreation_selectors = user.muted_users.map { |muted_user| ".user-#{user.id}.user-#{muted_user.id}" }.join(", ")
    cocreation_placeholder = I18n.translate("muted.placeholder.cocreation")

    script = <<-SCRIPT
      <script>
        makeMutedItemsExpandable("#{comment_selectors}", "#{comment_placeholder}");
        makeMutedItemsExpandable("#{cocreation_selectors}", "#{cocreation_placeholder}");

        function makeMutedItemsExpandable(css_selectors, expander_text) {
          let items = document.querySelectorAll(css_selectors);

          items.forEach(function(item) {
            let wrapper = document.createElement("details");
            let expander = document.createElement("summary");
            let text_node = document.createTextNode(expander_text);

            item.classList.add("muted");
            expander.classList.add("message");

            while(item.firstChild)
              wrapper.appendChild(item.firstChild);

            item.appendChild(wrapper);
            wrapper.prepend(expander);
            expander.appendChild(text_node);
          });
        };
      </script>
    SCRIPT

    script.html_safe
  end

  def mute_css_key(user)
    "muted/#{user.id}/mute_css"
  end

  def mute_javascript_key(user)
    "muted/#{user.id}/mute_javascript"
  end

  def user_has_muted_users?
    !current_user.muted_users.empty? if current_user
  end
end
