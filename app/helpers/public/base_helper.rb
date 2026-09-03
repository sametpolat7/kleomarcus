module Public::BaseHelper
  def club
    Rails.configuration.x.club
  end

  def canonical_url
    "#{club.url}#{request.path}"
  end

  def club_discipline_names
    club.disciplines.map { |discipline| discipline[:name] }
  end

  def club_disciplines_in(group)
    club.disciplines.select { |discipline| discipline[:group] == group }
  end

  def featured_club_disciplines
    club.disciplines.select { |discipline| discipline[:image] }
  end

  def club_discipline_list
    spans = club_discipline_names.map { |name| tag.span(name, class: "text-primary font-display") }
    return spans.first if spans.one?

    safe_join([ safe_join(spans[0..-2], ", "), spans.last ], " ve ")
  end

  def club_weekend_hours
    windows = Lesson.opening_hours.slice("saturday", "sunday").values.uniq
    return unless windows.one?

    windows.first.join("-")
  end

  def default_seo_description
    "#{club.name} — #{club.founded_in}'dan beri Çanakkale'de #{club_discipline_names.to_sentence(last_word_connector: " ve ")} eğitimleri. Deneyimli antrenörler eşliğinde her yaş ve seviyeye uygun bireysel ve grup dersleri."
  end

  def seo_description
    @seo_description || default_seo_description
  end

  def default_seo_keywords
    "kleomarcus, kleomarcus spor akademi, çanakkale boks, çanakkale kick boks, çanakkale muay thai, çanakkale wushu, çanakkale mma, çanakkale crossfit, çanakkale hyrox, çanakkale bodybuilding, dövüş sporları çanakkale, dövüş kulübü, spor salonu çanakkale, bireysel antrenman, grup dersleri, çocuk boks, yetişkin dövüş eğitimi"
  end

  def set_seo_meta(title: nil, description: nil, keywords: nil, og_title: nil, og_description: nil, og_image: nil, og_type: "website")
    full_title = title ? "#{title} | #{club.name}" : club.name
    content_for :title, full_title

    @seo_description = description || default_seo_description
    content_for :description, @seo_description
    content_for :keywords, keywords || default_seo_keywords

    content_for :og_title, og_title || full_title
    content_for :og_description, og_description || description || default_seo_description
    content_for :og_image, og_image ? image_url(og_image) : image_url("public/hero-desktop.jpeg")
    content_for :og_type, og_type

    content_for :canonical, canonical_url

    nil
  end

  def opening_hours_specification
    Lesson.opening_hours.group_by { |_day, hours| hours }.map do |(opens, closes), entries|
      {
        "@type": "OpeningHoursSpecification",
        "dayOfWeek": entries.map { |day, _hours| day.capitalize },
        "opens": opens,
        "closes": closes
      }
    end
  end

  def organization_schema
    schema = {
      "@context": "https://schema.org",
      "@type": "SportsClub",
      "@id": "#{club.url}/#organization",
      "name": club.name,
      "url": club.url,
      "telephone": club.phone_e164,
      "email": club.email,
      "founder": {
        "@type": "Person",
        "name": club.founder
      },
      "foundingDate": club.founded_in.to_s,
      "address": {
        "@type": "PostalAddress",
        "streetAddress": club.address[:street],
        "addressLocality": club.address[:locality],
        "addressRegion": club.address[:region],
        "postalCode": club.address[:postal_code],
        "addressCountry": club.address[:country]
      },
      "geo": {
        "@type": "GeoCoordinates",
        "latitude": club.geo[:latitude],
        "longitude": club.geo[:longitude]
      },
      "hasMap": club.maps_url,
      "areaServed": club.area_served,
      "priceRange": club.price_range,
      "sameAs": club.social
    }

    hours = opening_hours_specification
    hours.any? ? schema.merge("openingHoursSpecification": hours) : schema
  end

  def press_schema(items)
    items.map do |item|
      {
        "@type": "NewsArticle",
        "headline": item.headline,
        "datePublished": item.published_on.iso8601,
        "url": item.url,
        "publisher": {
          "@type": "NewsMediaOrganization",
          "name": item.publisher
        }
      }
    end
  end

  def search_console_verification_tags
    tokens = { "google-site-verification" => club.google_site_verification, "msvalidate.01" => club.bing_site_verification }

    safe_join(tokens.filter_map { |name, token| tag.meta(name: name, content: token) if token.present? })
  end

  def structured_data_tag(schema)
    content_tag :script, type: "application/ld+json", nonce: content_security_policy_nonce do
      json_escape(schema.to_json).html_safe
    end
  end
end
