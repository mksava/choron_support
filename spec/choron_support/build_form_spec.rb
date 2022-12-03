RSpec.describe ChoronSupport::BuildForm do
  describe MockController do
    describe "#build_form" do
      let!(:controller_path) { "users" }
      let!(:current_user) { build(:user) }
      context "(when no type)" do
        let!(:controller) { MockController.new(controller_path, current_user, {}) }
        it do
          form = controller.build_form

          expect(form.create).to eq :create
          expect(form.update).to eq :update
        end
      end

      context "(when type is :search)" do
        let!(:controller) { MockController.new("users", current_user, { name: "neko"}) }
        before do
          create(:user, name: "neko")
          create(:user, name: "inu")
        end
        context "(when no params)" do
          it do
            form = controller.build_form(:search)

            users = form.search
            expect(users.size).to eq 1
            expect(users[0].name).to eq "neko"
          end
        end

        context "(when given params)" do
          it do
            form = controller.build_form(:search, { name: "inu" })

            users = form.search
            expect(users.size).to eq 1
            expect(users[0].name).to eq "inu"
          end
        end
      end
    end
  end
end