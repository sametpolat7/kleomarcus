class Admin::UsersController < Admin::BaseController
  # TODO: Role-based authorization needed here. Admin::BaseController only checks
  # panel_access? (admin OR staff), so a staff user can currently create, promote,
  # and delete any user — including admins. Restrict user management to admins once
  # the panel-wide authorization layer lands.
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
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "Kullanıcı güncellendi."
    else
      render :edit, status: :unprocessable_entity
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

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.expect(user: [ :username, :email_address, :role, :password, :password_confirmation ])
  end
end
