class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def all
    auth = request.env["omniauth.auth"]
    provider, uid, name, email, avatar_url = auth.provider, auth.uid, auth.info.name, auth.info.email, auth.info.image

    user = User.find_by_email(email)
    authentication = Authentication.find_by_provider_and_uid(provider, uid)

    if user.nil?
      user = User.new(:email => email, :name => name)
      user.authentications.build(:provider => provider, :uid => uid)
      user.skip_confirmation!

      if user.save
        #user.create_avatar(:remote_image_url => avatar_url) rescue nil  # Dont fail if we're unable to save avatar
        flash.notice = t('controllers.omniauth_callbacks.sign_up.success')
        custom_sign_in_and_redirect(user)
      else
        session["devise.user_attributes"] = user.attributes
        redirect_to new_user_registration_url
      end
    else
      # TODO: Verify that the authentication record belongs to this user only

      user.authentications.create(:provider => provider, :uid => uid) if !authentication # Regular signed up user, allow him this omniauth signup also
      flash.notice = t('controllers.omniauth_callbacks.sign_in.success')
      sign_in_and_redirect user
    end
  end

  alias_method :twitter, :all
  alias_method :facebook, :all
  alias_method :google_oauth2, :all
  alias_method :github, :all

  private
  def custom_sign_in_and_redirect(resource)
    scope = Devise::Mapping.find_scope!(resource)
    sign_in(scope, resource, {})
    redirect_to edit_user_path(current_user)
  end
end