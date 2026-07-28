module Public::BaseHelper
  def set_seo_meta(title: nil, description: nil, keywords: nil, og_title: nil, og_description: nil, og_image: nil, og_type: "website")
    site_name = "Kleomarcus Spor Akademi"
    default_description = "Çanakkale'nin köklü dövüş sporları akademisi. Boks, Kick Boks, Muay Thai, Wushu, MMA, CrossFit, Hyrox ve Bodybuilding eğitimleri. Deneyimli antrenörler eşliğinde her yaş ve seviyeye uygun bireysel ve grup dersleri."
    default_keywords = "kleomarcus, kleomarcus spor akademi, çanakkale boks, çanakkale kick boks, çanakkale muay thai, çanakkale wushu, çanakkale mma, çanakkale crossfit, çanakkale hyrox, çanakkale bodybuilding, dövüş sporları çanakkale, dövüş kulübü, spor salonu çanakkale, bireysel antrenman, grup dersleri, çocuk boks, yetişkin dövüş eğitimi"

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
        "https://www.instagram.com/kleomarcus",
        "https://www.facebook.com/kleomarcusss/"
      ]
    }
  end

  def structured_data_tag(schema)
    content_tag :script, type: "application/ld+json", nonce: content_security_policy_nonce do
      json_escape(schema.to_json).html_safe
    end
  end
end
