module Public::BaseHelper
  STAR_PATH = "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z".freeze

  def star_rating(rating = 5, label: nil)
    label ||= "#{rating} yıldız değerlendirme"
    empty_stars = 5 - rating

    content_tag(:div, class: "flex gap-1 mt-4", role: "img", "aria-label": label) do
      stars = []

      rating.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "currentColor", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: STAR_PATH)
        end
      end

      empty_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "none", stroke: "currentColor", "stroke-width": "1", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: STAR_PATH)
        end
      end

      safe_join(stars)
    end
  end

  def gallery_images
    [
      { src: "public/hero-desktop.jpeg", alt: "Antrenman salonu" },
      { src: "public/our-club.jpeg", alt: "Kulüp" },
      { src: "public/kleomarcus-philosophy.jpeg", alt: "Grup antrenmanı" },
      { src: "public/gallery-break-one.jpeg", alt: "Teknik çalışma" },
      { src: "public/gallery-break-two.jpeg", alt: "Kick boks dersi" },
      { src: "public/gallery11.jpeg", alt: "Müsabaka hazırlığı" },
      { src: "public/gallery1.jpeg", alt: "Ring içinde boks antrenmanı yapan sporcular" },
      { src: "public/gallery2.jpeg", alt: "Antrenör eşliğinde patlayıcı güç çalışması" },
      { src: "public/gallery3.jpeg", alt: "Kick boks kombine vuruş çalışması" },
      { src: "public/gallery4.jpeg", alt: "Grup halinde kondisyon ve dayanıklılık antrenmanı" },
      { src: "public/gallery5.jpeg", alt: "Partnerle ring içinde teknik sparring" },
      { src: "public/gallery6.jpeg", alt: "Antrenman sonrası takım fotoğrafı" },
      { src: "public/gallery7.jpeg", alt: "Hedef ve eldivenle pad çalışması yapan sporcu" },
      { src: "public/gallery8.jpeg", alt: "Genç sporcularla temel boks eğitimi" },
      { src: "public/gallery9.jpeg", alt: "Antrenman öncesi ısınma ve esneme hareketleri" },
      { src: "public/gallery10.jpeg", alt: "Kleomarcus Fight Club salonunda yoğun antrenman atmosferi" }
    ]
  end
end
