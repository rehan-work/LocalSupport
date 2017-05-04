class UsersController < ApplicationController

  def edit
    @user = User.find_by_id(user_params[:id])
  end

  # we should allow logged in users to update their pending_organisation_id
  # and only superadmins should be allowed to update organisation_id
  # makes me think of a attributes permissions matrix
  def update
    org = Organisation.friendly.find(user_params[:pending_organisation_id])
    user = User.find_by_id user_params[:id]
    UserOrganisationClaimer.new(self, user, user).call(org.id)
  end

  def update_message_for_admin_status
    org = Organisation.friendly.find(user_params[:pending_organisation_id])
    flash[:notice] = "You have requested admin status for #{org.name}"
    send_email_to_superadmin_about_request_for_admin_of org   # could be moved to an hook on the user model?
    redirect_to organisation_path(org)
  end

  def send_email_to_superadmin_about_request_for_admin_of org
    superadmin_emails = User.superadmins.pluck(:email)
    AdminMailer.new_user_waiting_for_approval(org.name, superadmin_emails).deliver_now
  end

  def user_params
    params
      .permit(
        :id, 
        :email, 
        :password, 
        :password_confirmation, 
        :remember_me, 
        :pending_organisation_id
      )
  end

end
