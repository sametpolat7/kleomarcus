module Admin::BaseHelper
  include Pagy::Frontend

  MODAL_FRAME = "admin_modal_frame".freeze

  ROLE_BADGE_VARIANTS = {
    "admin" => :primary,
    "staff" => :secondary,
    "athlete" => :neutral
  }.freeze

  MODAL_CLOSE_ICON = <<~SVG.html_safe.freeze
    <svg class="w-4 h-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true">
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
    </svg>
  SVG

  EMAIL_OFF_OPEN = "<!--email_off-->".html_safe.freeze
  EMAIL_OFF_CLOSE = "<!--/email_off-->".html_safe.freeze

  def badge(text, variant: :neutral)
    tag.span text, class: "badge badge-#{variant}"
  end

  def role_label(user)
    badge(User.enum_label(:role, user.role), variant: ROLE_BADGE_VARIANTS[user.role])
  end

  def modal_trigger(label, path, variant: :primary, **opts)
    classes = [ "btn", "btn-sm", "btn-#{variant}", opts.delete(:class) ].compact.join(" ")
    data = (opts[:data] || {}).merge(turbo_frame: MODAL_FRAME)
    link_to label, path, opts.merge(class: classes, data: data)
  end

  def format_date(value, format: "%d %B %Y")
    return "—" if value.blank?

    I18n.l(value.to_date, format: format)
  end

  def email_off(content = nil, &block)
    safe_join([ EMAIL_OFF_OPEN, block ? capture(&block) : content, EMAIL_OFF_CLOSE ])
  end

  def admin_page_header(title, subtitle: nil, &block)
    actions = capture(&block) if block

    tag.header(class: "flex flex-wrap items-start justify-between gap-4 mb-6") do
      concat(tag.div do
        concat tag.h1(title, class: "text-2xl font-display font-bold text-base-content")
        concat tag.p(subtitle, class: "mt-1 text-sm text-base-content/60") if subtitle.present?
      end)
      concat tag.div(actions, class: "flex items-center gap-2") if actions.present?
    end
  end

  def admin_modal_header(title, cancel_path:, subtitle: nil)
    tag.div(class: "flex items-start justify-between gap-4 px-6 py-4 border-b border-base-300") do
      concat(tag.div do
        concat tag.h2(title, class: "text-base font-semibold text-base-content")
        concat tag.p(email_off(subtitle), class: "mt-0.5 text-xs text-base-content/60") if subtitle.present?
      end)
      concat link_to(MODAL_CLOSE_ICON, cancel_path, class: "btn btn-ghost btn-sm btn-square -mr-2", data: { action: "click->modal#close" }, aria: { label: "Kapat" })
    end
  end
end
