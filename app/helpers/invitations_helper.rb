module InvitationsHelper

  def creator_link(invitation)
    if invitation.creator.is_a?(User)
      link_to(invitation.creator.login, invitation.creator)
    elsif invitation.creator.is_a?(Admin)
      invitation.creator.login
    else
      "queue"
    end
  end

  def invitee_link(invitation)
    if invitation&.invitee.is_a?(User)
      path = if policy(User).can_manage_users?
               admin_user_path(invitation.invitee)
             else
               invitation.invitee
             end
      link_to(invitation.invitee.login, path)
    elsif policy(User).can_manage_users? && invitation.invitee_type == "User" && invitation.invitee_id.present?
      t("invitations_helper.deleted_invitee", id: invitation.invitee_id)
    end
  end
end
