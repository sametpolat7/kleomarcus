module Admin::Feedbacks::PostersHelper
  QR_INK = "263238".freeze
  XML_PROLOG = /\A<\?xml[^>]*\?>/

  def feedback_qr_code(url)
    svg = RQRCode::QRCode.new(url, level: :m).as_svg(
      color: QR_INK,
      shape_rendering: "crispEdges",
      module_size: 10,
      standalone: true,
      use_path: true,
      viewbox: true,
      svg_attributes: { class: "block w-full h-full", role: "img", "aria-label": "Geri bildirim formunun QR kodu" }
    )

    svg.sub(XML_PROLOG, "").html_safe
  end

  def poster_display_url(url)
    uri = URI(url)
    "#{uri.host}#{uri.path}"
  end
end
