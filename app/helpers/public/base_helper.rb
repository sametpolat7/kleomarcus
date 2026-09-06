module Public::BaseHelper
  def club
    Rails.configuration.x.club
  end

  def canonical_url
    "#{club.url}#{request.path}"
  end

  def club_phone_href
    "tel:#{club.phone_e164}"
  end

  def club_whatsapp_url
    "https://wa.me/#{club.phone_e164.delete_prefix("+")}"
  end

  def club_mail_href
    "mailto:#{club.email}"
  end

  def club_full_address
    address = club.address
    "#{address[:street]}, #{address[:postal_code]} #{address[:locality]}/#{address[:region]}"
  end

  def club_discipline_names
    club.disciplines.map { |discipline| discipline[:name] }
  end

  def club_combat_names
    club_disciplines_in("combat").map { |discipline| discipline[:name] }
  end

  def club_support_names
    club_disciplines_in("fitness").map { |discipline| discipline[:name] }
  end

  def club_disciplines_in(group)
    club.disciplines.select { |discipline| discipline[:group] == group }
  end

  def featured_club_disciplines
    club.disciplines.select { |discipline| discipline[:image] }
  end

  def discipline_name_list(names)
    spans = names.map { |name| tag.span(name, class: "text-primary font-display") }
    return spans.first if spans.one?

    safe_join([ safe_join(spans[0..-2], ", "), spans.last ], " ve ")
  end

  def club_discipline_list
    discipline_name_list(club_discipline_names)
  end

  def club_combat_list
    discipline_name_list(club_combat_names)
  end

  def club_support_list
    discipline_name_list(club_support_names)
  end

  def club_weekend_hours
    windows = Lesson.opening_hours.slice("saturday", "sunday").values.uniq
    return unless windows.one?

    windows.first.join("-")
  end

  def club_offering_sentence
    combat = club_combat_names.to_sentence(last_word_connector: " ve ")
    support = club_support_names.to_sentence(last_word_connector: " ve ")

    "#{combat} branşlarında eğitim veriyor, #{support} idman setlerini bu branşların teknik, taktik, güç ve dayanıklılık gelişimine entegre ediyoruz"
  end

  def club_identity_sentence
    "#{club.name}, #{club.founded_in}'dan beri Çanakkale'de faaliyet gösteren çok amaçlı bir dövüş sporları kulübüdür."
  end

  def default_seo_description
    "#{club_identity_sentence} #{club_offering_sentence.upcase_first}. Deneyimli antrenörler eşliğinde her yaş ve seviyeye uygun bireysel ve grup dersleri."
  end

  def seo_description
    @seo_description || default_seo_description
  end

  def set_seo_meta(title: nil, description: nil, og_title: nil, og_description: nil, og_image: nil, og_type: "website")
    full_title = title ? "#{title} | #{club.name}" : club.name
    content_for :title, full_title

    @seo_description = description || default_seo_description
    content_for :description, @seo_description

    content_for :og_title, og_title || full_title
    content_for :og_description, og_description || description || default_seo_description
    content_for :og_image, og_image ? image_url(og_image) : image_url("public/hero-desktop.jpeg")
    content_for :og_type, og_type

    content_for :canonical, canonical_url

    nil
  end

  def club_schema_keywords
    (club_combat_names.map { |name| "çanakkale #{name.downcase}" } +
      [ "çanakkale dövüş kulübü", "dövüş sporları çanakkale", "çocuk dövüş sporları çanakkale", "güç ve kondisyon antrenmanı" ]).join(", ")
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

  def discipline_offer_catalog(name, disciplines)
    {
      "@type": "OfferCatalog",
      "name": name,
      "itemListElement": disciplines.map do |discipline|
        {
          "@type": "Offer",
          "itemOffered": {
            "@type": "Service",
            "name": discipline[:name],
            "serviceType": discipline[:name],
            "description": discipline[:summary]
          }
        }
      end
    }
  end

  def club_offer_catalog
    {
      "@type": "OfferCatalog",
      "name": "#{club.name} Antrenman Programı",
      "itemListElement": [
        discipline_offer_catalog("Dövüş Branşları", club_disciplines_in("combat")),
        discipline_offer_catalog("Güç ve Kondisyon Antrenmanları", club_disciplines_in("fitness"))
      ]
    }
  end

  def club_department_schema
    plus = club.plus
    return if plus.blank?

    {
      "@type": "SportsClub",
      "@id": "#{club.url}/#kleomarcus-plus",
      "name": plus[:name],
      "parentOrganization": { "@id": "#{club.url}/#organization" },
      "address": {
        "@type": "PostalAddress",
        "streetAddress": plus[:street],
        "addressLocality": plus[:locality],
        "addressRegion": plus[:region],
        "addressCountry": plus[:country]
      },
      "telephone": club.phone_e164,
      "sameAs": [ plus[:instagram] ].compact_blank
    }
  end

  def organization_schema
    schema = {
      "@context": "https://schema.org",
      "@type": "SportsClub",
      "@id": "#{club.url}/#organization",
      "name": club.name,
      "alternateName": club.alternate_names,
      "description": default_seo_description,
      "slogan": club.slogan,
      "keywords": club_schema_keywords,
      "sport": club_combat_names,
      "knowsAbout": club_combat_names,
      "hasOfferCatalog": club_offer_catalog,
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

    department = club_department_schema
    schema = schema.merge("department": department) if department

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
