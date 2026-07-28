class ErrorsController < ActionController::Base
  PAGES = {
    400 => {
      title: "Geçersiz İstek",
      message: "Gönderilen istek anlaşılamadı. Adresi kontrol edip tekrar deneyebilirsiniz."
    },
    403 => {
      title: "Bu Sayfaya Erişemezsiniz",
      message: "Bu sayfayı görüntüleme yetkiniz bulunmuyor. Yetkiniz olduğunu düşünüyorsanız bizimle iletişime geçin."
    },
    404 => {
      title: "Sayfa Bulunamadı",
      message: "Aradığınız sayfa taşınmış, adı değişmiş ya da hiç var olmamış olabilir."
    },
    405 => {
      title: "Bu İşlem Desteklenmiyor",
      message: "İstek, bu adres için geçerli olmayan bir yöntemle gönderildi."
    },
    406 => {
      title: "İçerik Görüntülenemiyor",
      message: "Bu sayfa, tarayıcınızın beklediği biçimde sunulamıyor. Güncel bir tarayıcıyla tekrar deneyin."
    },
    409 => {
      title: "Kayıt Bu Arada Değişti",
      message: "Siz bu sayfada çalışırken kayıt başka biri tarafından güncellendi. Sayfayı yenileyip tekrar deneyin."
    },
    422 => {
      title: "Form Gönderilemedi",
      message: "Güvenlik doğrulaması zaman aşımına uğradı. Sayfayı yenileyip formu tekrar gönderin."
    },
    500 => {
      title: "Beklenmeyen Bir Hata Oluştu",
      message: "Sorun bizde, sizde değil. Hata kaydedildi; kısa süre içinde tekrar deneyebilirsiniz."
    }
  }.freeze

  CLIENT_FALLBACK = {
    title: "İstek Karşılanamadı",
    message: "İsteğiniz işlenemedi. Adresi kontrol edip tekrar deneyebilirsiniz."
  }.freeze

  SERVER_FALLBACK = PAGES.fetch(500)

  layout "error"
  skip_forgery_protection
  before_action :prevent_caching
  helper_method :status_code, :status_title, :status_message, :error_reference

  def show
    if head_request?
      head status_code
    elsif request.format.json?
      render json: { status: status_code, error: status_title }, status: status_code
    elsif turbo_frame_request?
      render :frame, formats: :html, content_type: "text/html", layout: false, status: status_code
    else
      render :show, formats: :html, content_type: "text/html", status: status_code
    end
  end

  private

  def page
    @page ||= PAGES.fetch(status_code) { status_code >= 500 ? SERVER_FALLBACK : CLIENT_FALLBACK }
  end

  def status_title
    page[:title]
  end

  def status_message
    page[:message]
  end

  def status_code
    @status_code ||= begin
      raw = request.path_parameters[:code] || request.path_info.delete_prefix("/")
      code = raw.to_i

      code.between?(400, 599) ? code : 500
    end
  end

  def head_request?
    request.get_header("action_dispatch.original_request_method") == "HEAD"
  end

  def error_reference
    request.request_id
  end

  def prevent_caching
    response.headers["Cache-Control"] = "no-store"
  end
end
