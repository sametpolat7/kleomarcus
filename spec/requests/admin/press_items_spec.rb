require "rails_helper"

RSpec.describe "Admin Press Items", type: :request do
  let(:admin) { create(:user, :admin) }

  let(:valid_params) do
    {
      publisher: "Çanakkale Olay",
      publisher_kind: "local_press",
      headline: "Kleomarcus'tan Ceyda Güven, Balkan Şampiyonasından gümüş madalya ile döndü",
      url: "https://www.canakkaleolay.com/haber/gumus-madalya-114206",
      archive_url: "https://web.archive.org/web/20251116/https://www.canakkaleolay.com/haber/gumus-madalya-114206",
      published_on: "2025-11-16",
      byline: "Hadiye Ayşe İrim",
      quote: "70 kilo Kadınlar Sanda Kategorisinde Balkan İkincisi olarak, gümüş madalya kazandı.",
      published: "1"
    }
  end

  describe "unauthenticated access" do
    it "redirects to login" do
      get admin_press_items_path

      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  context "authenticated as admin" do
    before { sign_in(admin) }

    describe "GET /admin/basinda-biz" do
      it "returns 200 and lists existing records with their publisher kind" do
        create(:press_item, publisher: "Çanakkale Kalem", publisher_kind: :official_statement, headline: "Türkiye Şampiyonasında büyük başarı")

        get admin_press_items_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Çanakkale Kalem", "Türkiye Şampiyonasında büyük başarı", "Resmî Açıklama Kaynaklı")
      end

      it "warns about a published record that has no archive copy" do
        create(:press_item, :unarchived)

        get admin_press_items_path

        expect(response.body).to include("Arşivlenmedi")
      end

      it "does not warn once an archive copy is recorded" do
        create(:press_item, :visible)

        get admin_press_items_path

        expect(response.body).not_to include("Arşivlenmedi")
      end
    end

    describe "POST /admin/basinda-biz" do
      it "creates the record and redirects to the list" do
        expect { post admin_press_items_path, params: { press_item: valid_params } }
          .to change(PressItem, :count).by(1)

        expect(response).to redirect_to(admin_press_items_path)
        expect(PressItem.last).to have_attributes(publisher: "Çanakkale Olay", published: true, byline: "Hadiye Ayşe İrim")
      end

      it "re-renders the form with the error when the address is not https" do
        expect { post admin_press_items_path, params: { press_item: valid_params.merge(url: "canakkaleolay.com/haber") } }
          .not_to change(PressItem, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("https:// ile başlayan bir adres olmalıdır")
      end
    end

    describe "PATCH /admin/basinda-biz/:id" do
      it "updates the headline" do
        item = create(:press_item, headline: "Eski başlık")

        patch admin_press_item_path(item), params: { press_item: { headline: "Yeni başlık" } }

        expect(response).to redirect_to(admin_press_items_path)
        expect(item.reload.headline).to eq("Yeni başlık")
      end
    end

    describe "DELETE /admin/basinda-biz/:id" do
      it "removes the record" do
        item = create(:press_item)

        expect { delete admin_press_item_path(item) }.to change(PressItem, :count).by(-1)

        expect(response).to redirect_to(admin_press_items_path)
      end
    end
  end
end
