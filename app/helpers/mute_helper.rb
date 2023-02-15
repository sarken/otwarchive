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

  def mute_comment_javascript
    return if current_user.nil?

    Rails.cache.fetch(mute_comment_javascript_key(current_user)) do
      mute_comment_javascript_uncached(current_user)
    end
  end

  def mute_comment_javascript_uncached(user)
    user.reload

    return if user.muted_users.empty?

    commenter_selectors = user.muted_users.map { |muted_user| ".comment.user-#{muted_user.id}" }.join(", ").to_s
    cocreation_selectors = user.muted_users.map { |muted_user| ".user-#{user.id}.user-#{muted_user.id}" }.join(", ").to_s

    script = <<-SCRIPT
      <script>
        const mutedCommenterClasses = "#{commenter_selectors}";
        const mutedComments = document.querySelectorAll(mutedCommenterClasses);

        const mutedCoCreatorClasses = "#{cocreation_selectors}";
        const mutedCoCreations = document.querySelectorAll(mutedCoCreatorClasses);

        mutedComments.forEach(function (comment) {
          let details_wrapper = document.createElement("details");
          let wrapper_summary = document.createElement("summary");
          let summary_text = document.createTextNode("This comment is from a user you've muted.");

          comment.classList.add("muted");
          wrapper_summary.classList.add("message");

          while(comment.firstChild)
            details_wrapper.appendChild(comment.firstChild);

          comment.appendChild(details_wrapper);
          details_wrapper.prepend(wrapper_summary);
          wrapper_summary.appendChild(summary_text);
        });

        mutedCoCreations.forEach(function (cocreation) {
          let details_wrapper = document.createElement("details");
          let wrapper_summary = document.createElement("summary");
          let summary_text = document.createTextNode("You co-created this with a user you've muted.");

          cocreation.classList.add("muted");
          wrapper_summary.classList.add("message");

          while(cocreation.firstChild)
            details_wrapper.appendChild(cocreation.firstChild);

          cocreation.appendChild(details_wrapper);
          details_wrapper.prepend(wrapper_summary);
          wrapper_summary.appendChild(summary_text);
        });
      </script>
    SCRIPT

    script.html_safe
  end

  def mute_css_key(user)
    "muted/#{user.id}/mute_css"
  end

  def mute_comment_javascript_key(user)
    "muted/#{user.id}/mute_comment_javascript"
  end

  def user_has_muted_users?
    !current_user.muted_users.empty? if current_user
  end
end
