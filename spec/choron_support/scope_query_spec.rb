RSpec.describe ChoronSupport::ScopeQuery do
  describe ".scope_query" do
    describe User do
      describe ".by_name" do
        before do
          create(:user, name: "neko")
          create(:user, name: "inu")
          create(:user, name: "saru")
        end

        it "Usable by_name scope" do
          users1 = User.by_name("neko")
          expect(users1.size).to eq 1
          expect(users1[0].name).to eq "neko"

          users2 = User.by_name("saru")
          expect(users2.size).to eq 1
          expect(users2[0].name).to eq "saru"
        end
      end

      describe ".email_to" do
        before do
          create(:user, email: "neko@example.com")
          create(:user, email: "inu@example.com")
          create(:user, email: "saru@example.com")
        end

        it "Usable email_to scope" do
          users1 = User.email_to("neko@example.com")
          expect(users1.size).to eq 1
          expect(users1[0].email).to eq "neko@example.com"

          users2 = User.email_to("saru@example.com")
          expect(users2.size).to eq 1
          expect(users2[0].email).to eq "saru@example.com"
        end
      end

      describe ".limit_to" do
        before do
          create_list(:user, 3)
        end

        it "Usable limit_to scope" do
          users1 = User.limit_to(1)
          expect(users1.size).to eq 1

          users2 = User.limit_to(2)
          expect(users2.size).to eq 2
        end
      end
    end
  end
end