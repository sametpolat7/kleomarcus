class Admin::UsersController < Admin::BaseController
  before_action :require_admin
  before_action :set_user, only: %i[edit update destroy]

  def index
    @pagy, @users = pagy(User.order(:username))
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_users_path, notice: "Kullanıcı oluşturuldu."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit; end

  def update
    attributes = user_params

    if @user.update(attributes)
      revoke_other_sessions_for(@user) if attributes[:password].present?
      redirect_to admin_users_path, notice: "Kullanıcı güncellendi."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: "Kendi hesabınızı silemezsiniz.", status: :see_other
    else
      @user.destroy
      redirect_to admin_users_path, notice: "Kullanıcı silindi.", status: :see_other
    end
  end

  private

  def require_admin
    return if Current.user.admin?

    redirect_to admin_root_path, alert: "Bu bölüme yalnızca yöneticiler erişebilir."
  end

  def set_user
    @user = User.find(params[:id])
  end

  def revoke_other_sessions_for(user)
    user.sessions.where.not(id: Current.session.id).destroy_all
  end

  def user_params
    params.expect(user: [ :username, :email_address, :role, :password, :password_confirmation ])
          .tap { |attributes| attributes.delete(:role) unless assignable_role_change?(attributes[:role]) }
  end

  def assignable_role_change?(submitted)
    User::ASSIGNABLE_ROLES.include?(submitted) &&
      (@user.nil? || User::ASSIGNABLE_ROLES.include?(@user.role))
  end
end
