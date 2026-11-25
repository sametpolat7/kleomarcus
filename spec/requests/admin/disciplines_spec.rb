require "rails_helper"

RSpec.describe "Admin Disciplines", type: :request do
  let(:admin) { create(:user, :admin) }

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_disciplines_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/branslar" do
      it "lists each discipline with the trainers it is assigned to, in panel order" do
        boks = create(:discipline, name: "Boks")
        create(:discipline, name: "Judo")
        create(:trainer, name: "Mazlum Orak").disciplines << boks
        create(:trainer, name: "Ali Kaya").disciplines << boks

        get admin_disciplines_path

        expect(response).to have_http_status(:ok)
        rows = Nokogiri::HTML(response.body).css("table tbody tr").map { |row| row.css("td").first(2).map { |cell| cell.text.squish } }
        expect(rows).to eq([ [ "Boks", "Mazlum Orak ve Ali Kaya" ], [ "Judo", "—" ] ])
      end
    end

    describe "GET /admin/branslar/new" do
      it "renders the blank form inside the modal turbo-frame" do
        get new_admin_discipline_path

        expect(response).to have_http_status(:ok)
        form = Nokogiri::HTML(response.body).at_css("turbo-frame#admin_modal_frame form")
        expect(form.css("[name^='discipline']").map { |field| field[:name] }).to eq([ "discipline[name]" ])
      end
    end

    describe "POST /admin/branslar" do
      it "creates the discipline and redirects to the index" do
        expect {
          post admin_disciplines_path, params: { discipline: { name: "Judo" } }
        }.to change(Discipline, :count).by(1)

        expect(response).to redirect_to(admin_disciplines_path)
      end

      it "returns 422 with the error block for a name that already exists in another case" do
        create(:discipline, name: "Muay Thai")

        expect {
          post admin_disciplines_path, params: { discipline: { name: "muay thai" } }
        }.not_to change(Discipline, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("hata oluştu")
      end
    end

    describe "PATCH /admin/branslar/:id" do
      it "renames the discipline and redirects to the index" do
        discipline = create(:discipline, name: "Kickboks")

        patch admin_discipline_path(discipline), params: { discipline: { name: "Kick Boks" } }

        expect(discipline.reload.name).to eq("Kick Boks")
        expect(response).to redirect_to(admin_disciplines_path)
      end
    end

    describe "DELETE /admin/branslar/:id" do
      it "deletes a discipline no trainer carries" do
        discipline = create(:discipline)

        expect {
          delete admin_discipline_path(discipline)
        }.to change(Discipline, :count).by(-1)

        expect(response).to redirect_to(admin_disciplines_path)
        expect(flash[:notice]).to eq("Branş silindi.")
      end

      it "refuses to delete a discipline assigned to a trainer and keeps the assignment" do
        discipline = create(:discipline)
        trainer = create(:trainer)
        trainer.disciplines << discipline

        expect {
          delete admin_discipline_path(discipline)
        }.not_to change(Discipline, :count)

        expect(trainer.reload.disciplines).to contain_exactly(discipline)
        expect(response).to redirect_to(admin_disciplines_path)
        expect(flash[:alert]).to include("antrenörlere atanmış")
      end
    end
  end

  context "authenticated as staff" do
    before { sign_in(create(:user, :staff)) }

    it "lets a staff member manage disciplines as well" do
      expect {
        post admin_disciplines_path, params: { discipline: { name: "Judo" } }
      }.to change(Discipline, :count).by(1)

      expect(response).to redirect_to(admin_disciplines_path)
    end
  end
end
