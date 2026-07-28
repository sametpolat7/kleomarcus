require "rails_helper"

RSpec.describe "Admin Trainers", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    { name: "Mehmet Demir", title: "Baş Antrenör", bio: "Deneyimli antrenör." }
  end

  let(:png_bytes) do
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8DwHwAFAAH/q842iQAAAABJRU5ErkJggg==")
  end

  def upload(bytes, content_type:, filename:)
    file = Tempfile.new([ File.basename(filename, ".*"), File.extname(filename) ])
    file.binmode
    file.write(bytes)
    file.rewind

    Rack::Test::UploadedFile.new(file.path, content_type, original_filename: filename)
  end

  def error_alert
    Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame [role=alert]").text.squish
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_trainers_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/egitmenler" do
      it "returns 200 and lists existing trainers" do
        create(:trainer, name: "Mehmet Demir")

        get admin_trainers_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Mehmet Demir")
      end
    end

    describe "GET /admin/egitmenler/new" do
      it "renders the blank form with a tick box per discipline" do
        create(:discipline, name: "Boks")

        get new_admin_trainer_path

        expect(response).to have_http_status(:ok)
        form = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")
        expect(form.css("[name]").map { |field| field[:name] })
          .to include("trainer[name]", "trainer[title]", "trainer[discipline_ids][]")
        expect(form.text).to include("Boks")
      end
    end

    describe "POST /admin/egitmenler with valid params" do
      it "creates the trainer and redirects to the index" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params }
        }.to change(Trainer, :count).by(1)

        expect(response).to redirect_to(admin_trainers_path)
      end
    end

    describe "POST /admin/egitmenler with a photo" do
      it "attaches the uploaded photo to the trainer" do
        photo = upload(png_bytes, content_type: "image/png", filename: "trainer.png")

        post admin_trainers_path, params: { trainer: valid_params.merge(photo: photo) }

        expect(response).to redirect_to(admin_trainers_path)
        expect(Trainer.find_by(name: "Mehmet Demir").photo).to be_attached
      end

      it "returns 422 and creates nothing when the upload is not an image" do
        pdf_bytes = "%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\ntrailer\n<< /Root 1 0 R >>\n%%EOF\n"
        pdf = upload(pdf_bytes, content_type: "application/pdf", filename: "ozgecmis.pdf")

        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(photo: pdf) }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_alert).to include("Fotoğraf JPEG, PNG veya WebP olmalıdır")
      end

      it "returns 422 and creates nothing when the image is over 5 MB" do
        oversized = png_bytes + ("\0" * (Trainer::PHOTO_MAX_SIZE - png_bytes.bytesize + 1))
        photo = upload(oversized, content_type: "image/png", filename: "buyuk.png")

        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(photo: photo) }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_alert).to include("Fotoğraf en fazla 5 MB olabilir")
      end
    end

    describe "POST /admin/egitmenler with disciplines ticked" do
      it "attaches every discipline the form submitted" do
        boks = create(:discipline, name: "Boks")
        mma = create(:discipline, name: "MMA")

        post admin_trainers_path, params: { trainer: valid_params.merge(discipline_ids: [ boks.id, mma.id ]) }

        expect(Trainer.find_by(name: "Mehmet Demir").disciplines).to contain_exactly(boks, mma)
      end
    end

    describe "POST /admin/egitmenler with invalid params" do
      it "returns 422 and does not create a trainer" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(name: "") }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end

      it "returns 422 and creates nothing when the position is not a positive number" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(position: 0) }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_alert).to include("Sıra 0 sayısından büyük olmalı")
      end

      it "returns 422 and creates nothing when the position is not a number at all" do
        expect {
          post admin_trainers_path, params: { trainer: valid_params.merge(position: "abc") }
        }.not_to change(Trainer, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(error_alert).to include("Sıra")
      end

      it "re-renders the form with the discipline tick boxes still in place" do
        boks = create(:discipline, name: "Boks")
        mma = create(:discipline, name: "MMA")

        post admin_trainers_path, params: { trainer: valid_params.merge(name: "") }

        expect(response).to have_http_status(:unprocessable_content)
        form = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")
        expect(form.css("input[type=checkbox][name='trainer[discipline_ids][]']").map { |box| box[:value] })
          .to contain_exactly(boks.id.to_s, mma.id.to_s)
        expect(form.text).to include("Boks", "MMA")
      end
    end

    describe "PATCH /admin/egitmenler/:id" do
      it "updates the trainer and redirects to the index" do
        trainer = create(:trainer)

        patch admin_trainer_path(trainer), params: { trainer: { title: "Kıdemli Antrenör" } }

        expect(trainer.reload.title).to eq("Kıdemli Antrenör")
        expect(response).to redirect_to(admin_trainers_path)
      end

      it "shifts the ranking to make room when the new position is already taken" do
        create(:trainer, name: "Ali Vural", position: 1)
        burak = create(:trainer, name: "Burak Şen", position: 2)

        patch admin_trainer_path(burak), params: { trainer: { position: 1 } }

        expect(response).to redirect_to(admin_trainers_path)
        expect(Trainer.order(:position).pluck(:name, :position))
          .to eq([ [ "Burak Şen", 1 ], [ "Ali Vural", 2 ] ])
      end
    end

    describe "DELETE /admin/egitmenler/:id" do
      it "deletes the trainer and redirects to the index" do
        trainer = create(:trainer)

        expect {
          delete admin_trainer_path(trainer)
        }.to change(Trainer, :count).by(-1)

        expect(response).to redirect_to(admin_trainers_path)
      end

      it "deletes a trainer who still teaches lessons, keeping the lessons on the schedule" do
        trainer = create(:trainer)
        lesson = create(:lesson, trainer: trainer)

        expect {
          delete admin_trainer_path(trainer)
        }.to change(Trainer, :count).by(-1)

        expect(lesson.reload.trainer_id).to be_nil
        expect(response).to redirect_to(admin_trainers_path)
      end
    end
  end
end
