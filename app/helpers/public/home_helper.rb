module Public::HomeHelper
  def testimonials_data
    [
      {
        name: "Ceyda Güven",
        initials: "C.G.",
        title: "Wushu Türkiye Şampiyonu",
        quote: "Kleomarcus'a ilk adımımı attığımda Mazlum Hocam beni öyle sıcak karşıladı ki kendimi anında ailemin bir parçası gibi hissettim. Türkiye Şampiyonluğu ve Uluslararası Balkan Oyunları'ndaki ikinciliğimin temeli burada yaptığım sıkı antrenmanlar ve eğitmenlerimin özverili desteğiyle oluştu.",
        rating: 5
      },
      {
        name: "Samet Polat",
        initials: "S.P.",
        title: "Lisanslı Sporcu",
        quote: "Kleomarcus sadece bir spor salonu değil; bunu içeri girdiğiniz andan itibaren hissedeceksiniz. İçeride samimi bir ortam var. 'Antrenmanımı yaptım, bitti.' değil — burada geçirdiğiniz her dakikadan keyif alıyor ve daha fazla çalışmak istiyorsunuz.",
        rating: 5
      },
      {
        name: "Ezgi Akyüz",
        initials: "E.A.",
        title: "Sporcu",
        quote: "Burası benim için bir ilham kaynağı. Her dersten sonra kendimi daha güçlü ve kararlı hissediyorum. Kleomarcus'u seviyorum.",
        rating: 5
      },
      {
        name: "Salih Doruk Demir",
        initials: "S.D.",
        title: "Wushu Uluslararası Balkan Şampiyonu",
        quote: "Kleomarcus'ta geçirdiğim zaman, sadece fiziksel olarak değil, aynı zamanda zihinsel olarak da gelişmeme yardımcı oldu. Burada kazandığım teknik birikim ve zihinsel dayanıklılık müsabakalarda en büyük avantajım oldu. Bu kulüp benim ikinci ailem.",
        rating: 5
      },
      {
        name: "Azra Kocakuşak",
        initials: "A.K.",
        title: "Wushu Türkiye Şampiyonu",
        quote: "Hocalarım bana teknik becerinin ötesinde azim ve kararlılık aşıladı. Türkiye Şampiyonluğu'nu kazandığımda yaptığım çalışmaların ve hocalarımın desteğinin karşılığını aldım.",
        rating: 5
      },
      {
        name: "Öykü Yufka",
        initials: "Ö.Y.",
        title: "Sporcu",
        quote: "Her antrenman bir öncekinden daha fazla geliştiğimi hissediyorum. Eğitmenim bireysel tempoma saygı gösterirken beni sürekli bir adım ileriye taşıyor. Kleomarcus'a gelmek günümün en verimli ve keyifli anı.",
        rating: 5
      },
      {
        name: "Eymen Çevik",
        initials: "E.Ç.",
        title: "Lisanslı Sporcu",
        quote: "Burada hocalarım ve abilerimle birlikte çalışmak benim için büyük bir şans. Antrenmanlar geliştirici ve eğlenceli, ve her gün kendimi daha iyi hissediyorum.",
        rating: 5
      },
      {
        name: "Ecemsu Çıngı",
        initials: "E.Ç.",
        title: "Lisanslı Sporcu",
        quote: "Daha önce spor salonlarını sıkıcı bulurdum ancak Kleomarcus tamamen farklı bir deneyim sunuyor. Antrenmanlar hem eğitici hem de son derece eğlenceli; üstelik burada edindiğim dostluklar hayatıma büyük değer kattı.",
        rating: 5
      },
      {
        name: "Aziz & Onur Koca",
        initials: "A&O",
        title: "Baba-Oğul Sporcular",
        quote: "Oğlumla kendimizi geliştireceğimiz bir spor salonu arıyorduk ve Kleomarcus bunun için mükemmel bir ortam sağladı. Burada birlikte keyifle antrenman yapıp kaliteli zaman geçirmeyi seviyoruz.",
        rating: 5
      }
    ]
  end

  def star_rating(rating = 5, label: nil)
    label ||= "#{rating} yıldız değerlendirme"

    full_stars = rating.floor
    half_star = (rating % 1) >= 0.5
    empty_stars = 5 - full_stars - (half_star ? 1 : 0)
    gradient_id = "half-star-gradient" if half_star

    content_tag(:div, class: "flex gap-1 mt-4", role: "img", "aria-label": label) do
      stars = []

      # Full stars
      full_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "currentColor", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
        end
      end

      # Half star
      if half_star
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.defs do
            tag.linearGradient(id: gradient_id) do
              safe_join([
                tag.stop(offset: "50%", "stop-color": "currentColor"),
                tag.stop(offset: "50%", "stop-color": "transparent")
              ])
            end
          end +
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z", fill: "url(##{gradient_id})", stroke: "currentColor", "stroke-width": "1")
        end
      end

      # Empty stars
      empty_stars.times do
        stars << content_tag(:svg, class: "w-5 h-5 text-primary", fill: "none", stroke: "currentColor", "stroke-width": "1", viewBox: "0 0 20 20", "aria-hidden": "true") do
          tag.path(d: "M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z")
        end
      end

      safe_join(stars)
    end
  end
end
