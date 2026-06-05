# Idempotent seed data for trainers, lessons, and testimonials.
# Safe to run multiple times — uses find_or_create_by on stable keys.

trainers_data = [
  {
    name: "Mazlum Orak",
    title: "Baş Antrenör",
    image: "mazlum-orak.jpeg",
    disciplines: [ "Boks", "Kick Boks", "Muay Thai", "Wushu", "MMA", "CrossFit" ],
    bio: <<~BIO.strip
      Mazlum Orak, Çanakkale Onsekiz Mart Üniversitesi Beden Eğitimi ve Spor Öğretmenliği Bölümü'nden mezun olmuş ve spor kariyeri boyunca birçok farklı branşta aktif olarak yer almıştır. Spor hayatına 2006 yılında başlamış, 2014 yılında mücadele sporlarında milli sporcu unvanı kazanmıştır.

      Ulusal ve uluslararası organizasyonlarda Türkiye'yi farklı branşlarda temsil eden Orak, elde ettiği başarılarla ülkesini üst düzeyde temsil etmiş ve İstiklal Marşı'mızı okutma onuruna erişmiştir.

      2019 yılında Kleomarcus Spor Akademisi'ni kurarak sporcu yetiştirme ve milli sporcular kazandırma hedefiyle çalışmalarına kurumsal bir yapı kazandırmıştır. 2023 yılında Milli Takım Antrenörü olarak görevlendirilmiş ve antrenörlük kariyerini ileri seviyeye taşımıştır.

      Sporu yalnızca fiziksel bir aktivite olarak değil, sürdürülebilir bir yaşam tarzı olarak ele alan Mazlum Orak, bu yaklaşımı sporcularına kazandırmayı amaçlamaktadır. 2026 yılında Kleomarcus Plus bünyesinde Fitness, CrossFit ve Hyrox alanlarında faaliyet göstermeye başlayarak antrenman kapsamını genişletmiştir.

      Antrenörlük yaklaşımında disiplin, süreklilik ve performans odaklı gelişimi esas alan Orak, sporcuların hem fiziksel hem de mental olarak üst seviyeye ulaşmalarını hedeflemektedir.
    BIO
  },
  {
    name: "Emir Efraim Demir",
    title: "Antrenör",
    image: "emir-efraim-demir.jpeg",
    disciplines: [ "MMA", "Boks", "Kick Boks", "Muay Thai" ],
    bio: <<~BIO.strip
      Emir Efraim Demir, dövüş sporları alanında uzmanlaşmış bir antrenör ve milli sporcudur. Spor kariyeri boyunca Türkiye'yi ulusal ve uluslararası organizasyonlarda temsil ederek önemli dereceler elde etmiştir.

      Türkiye şampiyonluğu ve Balkan düzeyindeki başarılarıyla öne çıkan Demir, disiplin, azim ve kararlılığı kariyerinin temel prensipleri olarak benimsemiştir. Milli takım sporcusu olarak edindiği tecrübeler, teknik gelişiminin yanı sıra sporcu psikolojisi konusunda da yetkinlik kazanmasını sağlamıştır.

      Aktif sporculuk kariyerini antrenörlük ile birlikte sürdüren Demir, bilgi ve deneyimlerini farklı seviyelerdeki sporculara aktarmaktadır. Antrenman yaklaşımında fiziksel gelişimin yanı sıra disiplin, özgüven ve mental dayanıklılığı ön planda tutmaktadır.

      Sporun dönüştürücü gücüne inanan Emir Efraim Demir, sporcuların çok yönlü gelişimini destekleyen ve sürdürülebilir başarıyı hedefleyen bir eğitim anlayışı benimsemektedir.
    BIO
  },
  {
    name: "Ceyda Güven",
    title: "Antrenör",
    image: "ceyda-guven.jpeg",
    disciplines: [ "Wushu", "Boks", "Kick Boks", "Fitness" ],
    bio: <<~BIO.strip
      Ceyda, 10 yılı aşkın süredir aktif olarak sporun içinde yer almakta olup iki farklı branşta milli sporcu olarak ülkesini temsil etmiştir. Avrupa ve Balkan derecelerine sahiptir. Spor hayatına erken yaşlarda başlayarak disiplin, mücadele ve süreklilik ilkelerini benimsemiştir.

      Çanakkale Onsekiz Mart Üniversitesi Antrenörlük Bölümü'nde fitness alanında uzmanlaşmakta; kickboks, temel dövüş teknikleri, kondisyon geliştirme ve müsabaka hazırlığı konularında çalışmalar yürütmektedir. Antrenman yaklaşımında teknik gelişimin yanı sıra dayanıklılık, hız ve mental performansın birlikte geliştirilmesini hedeflemektedir.

      Her sporcunun bireysel farklılıklarını esas alarak kişiye özel antrenman programları hazırlamakta ve potansiyelin en üst seviyeye çıkarılmasına odaklanmaktadır. Disiplinli çalışma, doğru teknik ve istikrarlı gelişim ile hedeflere ulaşılabileceği anlayışını benimsemektedir.

      Ceyda, dövüş sporlarını yalnızca fiziksel gelişim değil; aynı zamanda karakter, özgüven ve kontrol kazandıran bir yaşam disiplini olarak ele almakta, sporcularının çok yönlü gelişimini desteklemeyi amaçlamaktadır.
    BIO
  },
  {
    name: "Muhammed Cemal Yay",
    title: "Antrenör",
    image: "muhammed-yay.jpeg",
    disciplines: [ "Boks", "Kick Boks", "Wushu" ],
    bio: <<~BIO.strip
      Muhammed Cemal Yay, Wushu (Sanda) branşında aktif sporculuk ve antrenörlük faaliyetlerini sürdüren bir spor eğitmenidir. 65 kg kategorisinde mücadele eden Muhammed, ulusal ve uluslararası organizasyonlarda elde ettiği derecelerle öne çıkmaktadır.

      Spor kariyeri boyunca Balkan Wushu Şampiyonası ikinciliği ve Türkiye Wushu Şampiyonası üçüncülüğü gibi önemli başarılar elde etmiş; ayrıca takım şampiyonluğu yaşamıştır. Bu süreçte hem bireysel performansını geliştirmiş hem de yüksek seviye müsabaka deneyimi kazanmıştır.

      Aktif sporculuğunun yanı sıra antrenörlük alanında da görev alan Muhammed, başlangıç ve orta seviyedeki sporcuların gelişimine katkı sağlamaktadır. Teknik eğitim, kondisyon geliştirme ve performans odaklı antrenman planlaması konularında çalışmalar yürütmektedir.

      Antrenman yaklaşımında disiplin, süreklilik ve bireysel gelişimi esas alan Muhammed Cemal Yay; sporcularına teknik becerilerin yanı sıra dayanıklılık, koordinasyon ve mücadele bilinci kazandırmayı hedeflemektedir. Sporcu motivasyonu ve gelişim takibini ön planda tutarak, sürdürülebilir başarıya odaklanan bir eğitim anlayışı benimsemektedir.

      Kendi gelişimini de sürekli olarak sürdüren Muhammed, antrenörlük alanındaki eğitim ve sertifikasyon süreçlerine aktif şekilde devam etmektedir.
    BIO
  },
  {
    name: "Semanur Karaman",
    title: "Antrenör",
    image: "semanur-karaman.jpeg",
    disciplines: [ "Taekwondo", "Wushu", "Kick Boks" ],
    bio: <<~BIO.strip
      Semanur Karaman, spor hayatına 8 yaşında başlamış ve erken yaşlardan itibaren sporu yaşamının temel bir parçası haline getirmiştir. İlk olarak 4 yıl boyunca taekwondo ile ilgilenmiş; bu süreçte disiplin, sabır ve mücadele bilinci kazanmıştır. Ardından okul sporları kapsamında 2 yıl atletizmle ilgilenmiş, hem bireysel gelişimini sürdürmüş hem de ilini temsil etmiştir. Daha sonra wushu ve kickboks branşlarına yönelerek dövüş sporlarındaki deneyimini genişletmiştir.

      Sporun yalnızca fiziksel değil, aynı zamanda zihinsel ve karakter gelişimine katkı sağladığına inanan Karaman, bu doğrultuda Spor Bilimleri alanında akademik eğitim almıştır. Eğitim süreci boyunca farklı branşlarda gelişimini sürdürürken, antrenörlük alanında da aktif olarak görev almaktadır. Sporculara hem fiziksel hem de motivasyonel destek sağlayarak gelişimlerine katkıda bulunmaktadır.

      Semanur Karaman'ın temel hedefi, edindiği bilgi ve deneyimleri aktararak sporu daha geniş kitlelere sevdirmek ve sağlıklı yaşam bilincini yaygınlaştırmaktır.
    BIO
  },
  {
    name: "Göktürk Yiğit Terzi",
    title: "Antrenör",
    image: "gokturk-yigit.jpeg",
    disciplines: [ "Taekwondo", "Kick Boks", "Boks" ],
    bio: <<~BIO.strip
      Göktürk Yiğit Terzi, taekwondo branşında elde ettiği Avrupa ikinciliği derecesiyle öne çıkan milli bir sporcudur. Türkiye Taekwondo Milli Takımı bünyesinde kazandığı deneyimlerin ardından antrenörlük kariyerine yönelmiştir.

      Taekwondo temelli teknik altyapısını kick boks ve boks branşlarıyla destekleyerek çok yönlü bir dövüş yaklaşımı geliştirmiştir. Sahip olduğu yarışma tecrübesi sayesinde sporcularına teknik bilginin yanı sıra strateji, zamanlama ve ring becerileri kazandırmayı hedeflemektedir.

      Antrenörlük yaklaşımında disiplin, süreklilik ve bireysel gelişimi ön planda tutan Terzi, farklı seviyelerdeki sporculara yönelik yapılandırılmış antrenman programları uygulamaktadır. Sporun fiziksel gelişimin yanı sıra mental dayanıklılık ve özgüven kazandırdığına inanmakta; sporcularının hem sportif hem de kişisel gelişimlerini desteklemeyi amaçlamaktadır.
    BIO
  },
  {
    name: "Berra Sarı",
    title: "Antrenör",
    image: "berra-sari.jpeg",
    disciplines: [ "Karate", "Kick Boks", "Fitness" ],
    bio: <<~BIO.strip
      Berra Sarı, 2006 yılında Bandırma'da doğmuş ve spor hayatına 13 yaşında karate ile başlamıştır. Dövüş sporlarına olan ilgisini kısa sürede geliştirerek kick boks ve wushu branşlarında çalışmalarını sürdürmüş, ayrıca judo ile de ilgilenerek farklı savunma disiplinlerinde deneyim kazanmıştır. Yaklaşık üç buçuk yıllık aktif spor kariyeri boyunca disiplinli çalışmasıyla iki ilçe birinciliği elde etmiştir. Dövüş sporlarının yanı sıra fitness alanında da kendini geliştirmiştir. Spor Bilimleri alanında eğitimine devam ederek teorik ve pratik bilgisini güçlendirmektedir. Farklı branşlarda gelişimi desteklemek amacıyla pilates, cimnastik ve dans alanlarında da eğitim almış; bu alanlardaki çalışmalarını sürdürmektedir.

      Antrenörlük alanında kendini geliştirmeye odaklanan Berra, güçlü iletişim becerileriyle özellikle çocuklar ve genç sporcularla etkili bir eğitim süreci yürütmeyi hedeflemektedir. Wushu, kickboks, pilates ve fitness branşlarında ders vererek sporcuların fiziksel gelişimlerinin yanı sıra özgüven kazanmalarına katkı sağlamaktadır. Sporu; disiplin, süreklilik ve kişisel gelişimin temel unsuru olarak gören Berra Sarı, edindiği bilgi ve deneyimleri aktararak bireylerin gelişimine katkıda bulunmayı amaçlamaktadır.
    BIO
  },
  {
    name: "Çağkan Öztürk",
    title: "Antrenör",
    image: "cagkan-ozturk.jpeg",
    disciplines: [ "Yüzme" ],
    bio: <<~BIO.strip
      Çağkan Öztürk, Fenerbahçe Üniversitesi Antrenörlük Bölümü'nden Yüzme Uzmanlığı alanında mezun olmuş, 3. kademe yüzme antrenörü unvanına sahip bir spor eğitmenidir. Enerjisi yüksek ve iletişimi güçlü bir antrenör olarak sporcularının hem teknik gelişimini hem de özgüvenini artırmayı hedeflemekte; suda geçirilen her anın verimli olmasını temel önceliği olarak benimsemektedir.

      Kariyeri boyunca farklı kurum ve kulüplerde geniş bir deneyim yelpazesi oluşturmuştur. Çanakkale Seramik Yüzme Okulları'nda başlangıç ve orta seviye sporculara yüzme teknikleri eğitimi vermiş; Fenerbahçe Yüzme Okulu'nda staj yaparak farklı yaş gruplarıyla çalışma ve performans takibi konusunda yetkinlik kazanmıştır. Let's Club Spor Tesisi'nde birebir ve grup dersleri aracılığıyla teknik gelişim, hata düzeltme ve su güvenliği üzerine çalışmalar yürütmüştür. Çanakkale Belediye Spor Kulübü'nde ise sporcuların antrenman programlarının hazırlanması, uygulanması ve yarışlara hazırlık süreçlerinde aktif rol üstlenmiştir. Bu deneyimler, farklı seviyelerdeki sporcularla etkili biçimde çalışma konusundaki yaklaşımını şekillendirmiştir.

      Antrenörlük anlayışında bireysel gelişimi, teknik doğruluğu ve spora olan bağlılığı ön planda tutan Çağkan Öztürk, sporcularının su içinde özgüven ve performans açısından en üst seviyeye ulaşmalarını desteklemeyi amaçlamaktadır.
    BIO
  }
]

trainer_image_root = Rails.root.join("app/assets/images/public")

trainers_data.flat_map { |t| t[:disciplines] }.uniq.each do |name|
  Discipline.find_or_create_by!(name: name)
end

trainers_data.each_with_index do |attrs, index|
  trainer = Trainer.find_or_initialize_by(name: attrs[:name])
  trainer.title = attrs[:title]
  trainer.bio = attrs[:bio]
  trainer.position ||= index + 1
  trainer.save!

  trainer.disciplines = Discipline.where(name: attrs[:disciplines])

  next if trainer.photo.attached?

  image_path = trainer_image_root.join(attrs[:image])
  next unless image_path.exist?

  trainer.photo.attach(
    io: File.open(image_path),
    filename: attrs[:image],
    content_type: "image/jpeg"
  )
end

testimonials_data = [
  {
    author_name: "Ceyda Güven",
    title: "Wushu Türkiye Şampiyonu",
    content: "Kleomarcus'a ilk adımımı attığımda Mazlum Hocam beni öyle sıcak karşıladı ki kendimi anında ailemin bir parçası gibi hissettim. Türkiye Şampiyonluğu ve Uluslararası Balkan Oyunları'ndaki ikinciliğimin temeli burada yaptığım sıkı antrenmanlar ve eğitmenlerimin özverili desteğiyle oluştu."
  },
  {
    author_name: "Samet Polat",
    title: "Lisanslı Sporcu",
    content: "Kleomarcus sadece bir spor salonu değil; bunu içeri girdiğiniz andan itibaren hissedeceksiniz. İçeride samimi bir ortam var. 'Antrenmanımı yaptım, bitti.' değil — burada geçirdiğiniz her dakikadan keyif alıyor ve daha fazla çalışmak istiyorsunuz."
  },
  {
    author_name: "Ezgi Akyüz",
    title: "Sporcu",
    content: "Burası benim için bir ilham kaynağı. Her dersten sonra kendimi daha güçlü ve kararlı hissediyorum. Kleomarcus'u seviyorum."
  },
  {
    author_name: "Salih Doruk Demir",
    title: "Wushu Uluslararası Balkan Şampiyonu",
    content: "Kleomarcus'ta geçirdiğim zaman, sadece fiziksel olarak değil, aynı zamanda zihinsel olarak da gelişmeme yardımcı oldu. Burada kazandığım teknik birikim ve zihinsel dayanıklılık müsabakalarda en büyük avantajım oldu. Bu kulüp benim ikinci ailem."
  },
  {
    author_name: "Azra Kocakuşak",
    title: "Wushu Türkiye Şampiyonu",
    content: "Hocalarım bana teknik becerinin ötesinde azim ve kararlılık aşıladı. Türkiye Şampiyonluğu'nu kazandığımda yaptığım çalışmaların ve hocalarımın desteğinin karşılığını aldım."
  },
  {
    author_name: "Öykü Yufka",
    title: "Sporcu",
    content: "Her antrenman bir öncekinden daha fazla geliştiğimi hissediyorum. Eğitmenim bireysel tempoma saygı gösterirken beni sürekli bir adım ileriye taşıyor. Kleomarcus'a gelmek günümün en verimli ve keyifli anı."
  },
  {
    author_name: "Eymen Çevik",
    title: "Lisanslı Sporcu",
    content: "Burada hocalarım ve abilerimle birlikte çalışmak benim için büyük bir şans. Antrenmanlar geliştirici ve eğlenceli, ve her gün kendimi daha iyi hissediyorum."
  },
  {
    author_name: "Ecemsu Çıngı",
    title: "Lisanslı Sporcu",
    content: "Daha önce spor salonlarını sıkıcı bulurdum ancak Kleomarcus tamamen farklı bir deneyim sunuyor. Antrenmanlar hem eğitici hem de son derece eğlenceli; üstelik burada edindiğim dostluklar hayatıma büyük değer kattı."
  },
  {
    author_name: "Aziz & Onur Koca",
    title: "Baba-Oğul Sporcular",
    content: "Oğlumla kendimizi geliştireceğimiz bir spor salonu arıyorduk ve Kleomarcus bunun için mükemmel bir ortam sağladı. Burada birlikte keyifle antrenman yapıp kaliteli zaman geçirmeyi seviyoruz."
  }
]

testimonials_data.each do |attrs|
  testimonial = Testimonial.find_or_initialize_by(author_name: attrs[:author_name])
  testimonial.title = attrs[:title]
  testimonial.content = attrs[:content]
  testimonial.rating = 5
  testimonial.save!
end

# Weekly lesson schedule. Mirrors the previous Public::ClubsHelper#lesson_data.
hours = [
  [ "10:00", "11:00" ],
  [ "11:00", "12:00" ],
  [ "12:00", "13:00" ],
  [ "13:00", "14:00" ],
  [ "14:00", "15:00" ],
  [ "15:00", "16:00" ],
  [ "16:00", "17:00" ],
  [ "17:00", "18:00" ],
  [ "18:15", "19:15" ],
  [ "19:15", "20:15" ],
  [ "20:15", "21:15" ],
  [ "21:15", "22:15" ]
]

mw_groups = { "19:15" => "Gençler", "20:15" => "Yetişkinler" }
tt_groups = {
  "17:00" => "Çocuklar 1",
  "18:15" => "Çocuklar 2",
  "19:15" => "Gençler",
  "20:15" => "Yetişkinler 1",
  "21:15" => "Yetişkinler 2"
}

schedule = {
  monday:    { groups: mw_groups, until_hour: nil },
  tuesday:   { groups: tt_groups, until_hour: nil },
  wednesday: { groups: mw_groups, until_hour: nil },
  thursday:  { groups: tt_groups, until_hour: nil },
  friday:    { groups: {},        until_hour: nil },
  saturday:  { groups: {},        until_hour: "17:00" },
  sunday:    { groups: {},        until_hour: "17:00" }
}

schedule.each do |day, config|
  day_hours = config[:until_hour] ? hours.select { |start, _finish| start <= config[:until_hour] } : hours

  day_hours.each do |start_time, end_time|
    name, kind =
      if config[:groups].key?(start_time)
        [ config[:groups][start_time], :team ]
      else
        [ "Özel Ders", :solo ]
      end

    lesson = Lesson.find_or_initialize_by(day_of_week: day, start_time: start_time)
    lesson.end_time = end_time
    lesson.name = name
    lesson.kind = kind
    lesson.save!
  end
end

puts "Seeded #{User.count} users, #{Trainer.count} trainers, #{Discipline.count} disciplines, #{Testimonial.count} testimonials, #{Lesson.count} lessons."
