class Public::SitemapsController < Public::BaseController
  def show
    expires_in 12.hours, public: true

    @entries = [
      entry(root_path, content_updated_at),
      entry(club_path),
      entry(trainers_path, Trainer.maximum(:updated_at)),
      entry(lessons_path, Lesson.maximum(:updated_at)),
      entry(gallery_path),
      entry(press_items_path, PressItem.visible.maximum(:updated_at)),
      entry(new_enrollment_path)
    ]
  end

  private

  def entry(path, lastmod = nil)
    { loc: URI.join(Rails.configuration.x.club.url, path).to_s, lastmod: lastmod }
  end

  def content_updated_at
    [ Trainer.maximum(:updated_at), Lesson.maximum(:updated_at), Testimonial.maximum(:updated_at), PressItem.visible.maximum(:updated_at) ].compact.max
  end
end
