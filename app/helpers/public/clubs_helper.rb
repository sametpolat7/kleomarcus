module Public::ClubsHelper
  def trainers_data
    [
      {
        name: "Mazlum Orak",
        title: "Baş Antrenör",
        image: "public/our-club.jpeg",
        branches: [ "Boks", "Kick Boks", "Muay Thai", "Wushu", "MMA", "CrossFit" ],
        bio: "Mazlum Orak, 15 yılı aşkın profesyonel dövüş sporları kariyerinin ardından eğitmenliğe adım atmış, alanında öncü isimlerden biridir. Ulusal ve uluslararası müsabakalarda elde ettiği başarılarla birlikte, dövüş sanatlarının tüm inceliklerini sporcularına aktarmaktadır.\n\nBoks, Kick Boks, Muay Thai, Wushu, MMA ve CrossFit alanlarında uzmanlaşmış olan Mazlum Hoca, yüzlerce sporcuyu ulusal şampiyonluklara ve uluslararası başarılara taşımıştır. Teknik bilgisi kadar motivasyon ve liderlik yetenekleriyle de öne çıkan Mazlum Hoca, her seviyeden sporcu için ilham kaynağıdır.\n\nÖğrenci odaklı yaklaşımı ve bireysel gelişim planlarıyla her sporcunun potansiyelini maksimuma çıkarmayı hedefler. Sadece fiziksel kuvvet değil, zihinsel dayanıklılık ve stratejik düşünme becerilerini de geliştiren eğitim metoduyla sporcularını ring içinde ve dışında güçlendirir."
      },
      {
        name: "Emir Yılmaz",
        title: "Antrenör",
        image: "public/our-club.jpeg",
        branches: [ "MMA", "Kick Boks", "Muay Thai" ],
        bio: "Emir Yılmaz, Türkiye Milli Takımı'nda geçirdiği başarılı yılların ardından eğitmenlik kariyerine başlamıştır, özellikle MMA, Kick Boks ve Muay Thai dallarında uzmanlığını kanıtlamıştır.\n\nMilli takım deneyiminden gelen disiplin anlayışı ve profesyonel yarışma tecrübesi, onun eğitim felsefesinin temelini oluşturur. Emir Hoca, özellikle kadın sporcuların gelişiminde uzmanlaşmış olup, güvenli ve motive edici bir ortamda teknik ve taktiksel gelişimi hedefler.\n\nDövüş sanatlarının sadece fiziksel bir aktivite değil, aynı zamanda özgüven geliştirme ve mental dayanıklılık kazandırma aracı olduğuna inanır. Her yaş ve seviyeden sporcuya özel program hazırlayarak, bireysel hedeflere ulaşmada rehberlik eder. Sabırlı, destekleyici ve sonuç odaklı yaklaşımıyla sporcularının hem ring içinde hem de günlük hayatta daha güçlü olmalarını sağlar."
      },
      {
        name: "Muhammed Yay",
        title: "Antrenör",
        image: "public/kleomarcus-philosophy.jpeg",
        branches: [ "Wushu", "Boks", "Kick Boks" ],
        bio: "Muhammed Yay, geleneksel Çin dövüş sanatı Wushu'dan başlayarak Boks ve Kick Boks gibi modern dövüş disiplinlerinde de ustalaşmış, çok yönlü bir antrenördür.\n\nWushu'nun estetik ve akışkanlığını, boksun gücü ve stratejisiyle, kick boksun dinamizmiyle birleştirerek benzersiz bir eğitim metodolojisi geliştirmiştir. Teknik mükemmeliyetçiliğiyle tanınan Muhammed Hoca, her hareketin anatomik ve biyomekanik temellerine vurgu yaparak sporcularına derinlemesine anlayış kazandırır.\n\nÖzellikle genç sporcuların temel becerilerini geliştirmede uzman olan Muhammed Hoca, doğru teknik altyapısı oluşturmanın gelecekteki başarının anahtarı olduğuna inanır. Sabırlı öğretim tarzı ve detay odaklı yaklaşımı ile her sporcunun kendi hızında, ama sürekli ilerleyerek gelişmesini sağlar. Geleneksel değerleri modern antrenman bilimi ile harmanlayan eğitim felsefesi, sporcularına sadece dövüşçü kimliği değil, disiplin ve öz-kontrol kazandırır."
      },
      {
        name: "Salih Demir",
        title: "Antrenör",
        image: "public/gallery-break-one.jpeg",
        branches: [ "Boks", "Kick Boks" ],
        bio: "Salih Demir, spor bilimleri eğitimi ve profesyonel dövüş deneyimini birleştirerek, sporcu performansını bilimsel metodlarla en üst seviyeye çıkaran bir antrenördür. Boks ve Kick Boks alanlarında derin uzmanlığa sahiptir.\n\nKondisyon, güç antrenmanı ve atletik performans konularında uzmanlaşmış olan Salih Hoca, her sporcunun fiziksel kapasitesini analiz ederek kişiye özel antrenman programları tasarlar. Modern spor biliminin sunduğu tüm araçları kullanarak, sporcularının sadece teknik değil, fiziksel olarak da zirveye ulaşmasını hedefler.\n\nBesin ve beslenme planlaması, toparlanma stratejileri ve sakatlık önleme protokollerini antrenman sürecine entegre ederek bütünsel bir yaklaşım sergiler. Yoğun antrenman programlarının yanı sıra, sporcularının zihinsel dayanıklılığını artırmaya yönelik motivasyon teknikleri kullanır. Ölçülebilir sonuçlara odaklanan, disiplinli ve hedefe yönelik çalışma tarzıyla sporcularını sürekli gelişime teşvik eder."
      }
    ]
  end

  def schedule_days
    %w[Pazartesi Salı Çarşamba Perşembe Cuma Cumartesi Pazar]
  end

  def schedule_hours
    [
      { start: "10:00", end: "11:00" },
      { start: "11:00", end: "12:00" },
      { start: "12:00", end: "13:00" },
      { start: "13:00", end: "14:00" },
      { start: "14:00", end: "15:00" },
      { start: "15:00", end: "16:00" },
      { start: "16:00", end: "17:00" },
      { start: "17:00", end: "18:00" },
      { start: "18:15", end: "19:15" },
      { start: "19:15", end: "20:15" },
      { start: "20:15", end: "21:15" },
      { start: "21:15", end: "22:15" }
    ]
  end

  def format_time_range(hour)
    "#{hour[:start]}-#{hour[:end]}"
  end

  def schedule_data
    weekday_schedule = {
      "10:00" => { name: "Özel Ders", type: "private" },
      "11:00" => { name: "Özel Ders", type: "private" },
      "12:00" => { name: "Özel Ders", type: "private" },
      "13:00" => { name: "Özel Ders", type: "private" },
      "14:00" => { name: "Özel Ders", type: "private" },
      "15:00" => { name: "Özel Ders", type: "private" },
      "16:00" => { name: "Özel Ders", type: "private" },
      "17:00" => { name: "Özel Ders", type: "private" },
      "18:15" => { name: "Minikler", type: "group" },
      "19:15" => { name: "Gençler", type: "group" },
      "20:15" => { name: "Yetişkinler", type: "group" },
      "21:15" => { name: "Yetişkinler 2", type: "group" }
    }

    {
      "Pazartesi" => weekday_schedule,
      "Salı" => weekday_schedule,
      "Çarşamba" => weekday_schedule,
      "Perşembe" => weekday_schedule,
      "Cuma" => weekday_schedule,
      "Cumartesi" => {
        "10:00" => { name: "Özel Ders", type: "private" },
        "11:00" => { name: "Özel Ders", type: "private" },
        "12:00" => { name: "Özel Ders", type: "private" },
        "13:00" => { name: "Özel Ders", type: "private" },
        "14:00" => { name: "Özel Ders", type: "private" },
        "15:00" => { name: "Özel Ders", type: "private" },
        "16:00" => { name: "Özel Ders", type: "private" },
        "17:00" => { name: "Özel Ders", type: "private" }
      },
      "Pazar" => {
        "10:00" => { name: "Özel Ders", type: "private" },
        "11:00" => { name: "Özel Ders", type: "private" },
        "12:00" => { name: "Özel Ders", type: "private" },
        "13:00" => { name: "Özel Ders", type: "private" },
        "14:00" => { name: "Özel Ders", type: "private" },
        "15:00" => { name: "Özel Ders", type: "private" },
        "16:00" => { name: "Özel Ders", type: "private" },
        "17:00" => { name: "Özel Ders", type: "private" }
      }
    }
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
