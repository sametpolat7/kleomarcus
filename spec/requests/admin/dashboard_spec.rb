require "rails_helper"

RSpec.describe "Admin Dashboard", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_root_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "panel access" do
    it "lets a staff member in" do
      sign_in(create(:user, :staff))

      get admin_root_path

      expect(response).to have_http_status(:ok)
    end

    it "turns away and signs out a user whose role no longer carries panel access" do
      staff = create(:user, :staff)
      sign_in(staff)
      staff.update_column(:role, User.roles[:athlete])

      get admin_root_path

      expect(response).to redirect_to(new_admin_session_path)
      expect(flash[:alert]).to include("yetkiniz yok")
      expect(staff.sessions.reload).to be_empty
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin" do
      it "counts every resource on its own stat card" do
        create(:trainer)
        create_list(:lesson, 2)
        create(:enrollment)

        get admin_root_path

        expect(response).to have_http_status(:ok)
        cards = Nokogiri::HTML(response.body).css("a.admin-card").map { |card| card.text.squish }
        expect(cards).to include(
          a_string_starting_with("Antrenörler 1"),
          a_string_starting_with("Dersler 2"),
          a_string_starting_with("Yorumlar 0"),
          a_string_starting_with("Kullanıcılar 1"),
          a_string_starting_with("Başvurular 1")
        )
      end

      it "lists recent lessons and testimonials by name" do
        lesson = create(:lesson, name: "Muay Thai")
        testimonial = create(:testimonial, author_name: "Ayşe Yılmaz")

        get admin_root_path

        expect(response.body).to include(lesson.name)
        expect(response.body).to include(testimonial.author_name)
      end

      it "lists new applications by name and formatted phone number" do
        create(:enrollment, full_name: "Deniz Kaya", phone: "05321234567")

        get admin_root_path

        expect(response.body).to include("Deniz Kaya")
        expect(response.body).to include("0532 123 45 67")
      end

      it "keeps applications that have already been handled out of the new applications panel" do
        create(:enrollment, full_name: "Deniz Kaya", status: :positive)

        get admin_root_path

        expect(response.body).not_to include("Deniz Kaya")
        expect(response.body).to include("Henüz başvuru yok.")
      end

      it "renders an empty state when there is no activity" do
        get admin_root_path

        expect(response.body).to include("Henüz ders yok.")
        expect(response.body).to include("Henüz yorum yok.")
        expect(response.body).to include("Henüz başvuru yok.")
      end

      it "offers the users screen from the sidebar and from its own stat tile" do
        get admin_root_path

        doc = Nokogiri::HTML(response.body)
        expect(doc.css(%(aside a[href="#{admin_users_path}"]))).not_to be_empty
        expect(doc.css(%(a.admin-card[href="#{admin_users_path}"]))).not_to be_empty
        expect(doc.at_css("aside").text).to include("Sistem")
      end
    end

    describe "the flash after a write" do
      let(:frame_headers) { { "Turbo-Frame" => "admin_modal_frame" } }
      let(:trainer_params) { { name: "Mehmet Demir", title: "Baş Antrenör" } }

      context "submitted from inside the modal frame" do
        it "survives the frame's own fetch and shows up on the visit that follows it" do
          post admin_trainers_path, params: { trainer: trainer_params }, headers: frame_headers
          expect(response).to redirect_to(admin_trainers_path)
          follow_redirect!(headers: frame_headers)
          get admin_trainers_path
          expect(response.body).to include("Antrenör oluşturuldu.")
        end

        it "survives a destroy the same way" do
          trainer = create(:trainer)

          delete admin_trainer_path(trainer), headers: frame_headers
          follow_redirect!(headers: frame_headers)
          get admin_trainers_path

          expect(response.body).to include("Antrenör silindi.")
        end
      end

      context "submitted outside the modal frame" do
        it "shows up on the very next page and on that page only" do
          post admin_trainers_path, params: { trainer: trainer_params }
          follow_redirect!
          expect(response.body).to include("Antrenör oluşturuldu.")
          get admin_trainers_path
          expect(response.body).not_to include("Antrenör oluşturuldu.")
        end
      end
    end
  end

  context "authenticated as staff" do
    before { sign_in(create(:user, :staff)) }

    describe "GET /admin" do
      it "hides both entry points to the admin-only users screen" do
        get admin_root_path

        doc = Nokogiri::HTML(response.body)
        expect(doc.css(%(a[href="#{admin_users_path}"]))).to be_empty
        expect(doc.at_css("aside").text).not_to include("Sistem")
        expect(doc.css("a.admin-card").map { |card| card.text.squish })
          .not_to include(a_string_starting_with("Kullanıcılar"))
      end
    end
  end
end
