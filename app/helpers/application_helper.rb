module ApplicationHelper
  # SEO Meta Tags Helper
  # Simplifies setting page SEO metadata with sensible defaults
  #
  # @example In a view:
  #   <%= set_seo_meta(
  #     title: "Antrenörlerimiz",
  #     description: "Profesyonel antrenör kadromuz...",
  #     keywords: "antrenörler, boks eğitmeni",
  #     og_image: "trainers.jpg"
  #   ) %>
  #
  def set_seo_meta(title: nil, description: nil, keywords: nil, og_title: nil, og_description: nil, og_image: nil, og_type: "website")
    site_name = "Kleomarcus Spor Akademi"
    default_description = "Çanakkale'de Boks, Kick Boks, Muay Thai, Wushu, MMA ve CrossFit eğitimleri."
    default_keywords = "kleomarcus, boks, kick boks, muay thai, wushu, mma, crossfit, Çanakkale dövüş kulübü, Çanakkale spor salonu"

    # Title
    full_title = title ? "#{title} | #{site_name}" : site_name
    content_for :title, full_title

    # Meta Description & Keywords
    content_for :description, description || default_description
    content_for :keywords, keywords || default_keywords

    # Open Graph
    content_for :og_title, og_title || full_title
    content_for :og_description, og_description || description || default_description
    content_for :og_image, og_image ? image_url(og_image) : image_url("public/hero-desktop.jpeg")
    content_for :og_type, og_type

    # Canonical URL
    content_for :canonical, request.original_url

    nil
  end

  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "SportsClub",
      "name": "Kleomarcus Spor Akademi",
      "url": request.base_url,
      "telephone": "+90-547-023-08-99",
      "email": "info@kleomarcus.com",
      "address": {
        "@type": "PostalAddress",
        "addressLocality": "Merkez",
        "addressRegion": "Çanakkale",
        "addressCountry": "TR"
      },
      "geo": {
        "@type": "GeoCoordinates",
        "latitude": "40.16089",
        "longitude": "26.41582"
      },
      "priceRange": "₺₺",
      "sameAs": [
        "https://instagram.com/kleomarcus",
        "https://www.facebook.com/kleomarcusss/"
      ]
    }
  end

  def structured_data_tag(schema)
    content_tag :script, type: "application/ld+json" do
      json_escape(schema.to_json).html_safe
    end
  end
end
