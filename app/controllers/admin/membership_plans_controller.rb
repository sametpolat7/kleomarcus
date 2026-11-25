class Admin::MembershipPlansController < Admin::BaseController
  before_action :require_admin
  before_action :set_membership_plan, only: %i[edit update]

  def index
    @membership_plans = MembershipPlan.ordered
  end

  def edit; end

  def update
    if @membership_plan.update(membership_plan_params)
      redirect_to admin_membership_plans_path, notice: "Paket fiyatı güncellendi."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_membership_plan
    @membership_plan = MembershipPlan.find(params[:id])
  end

  def membership_plan_params
    params.expect(membership_plan: [ :monthly_price ])
  end
end
