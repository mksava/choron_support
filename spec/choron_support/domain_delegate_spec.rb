RSpec.describe ChoronSupport::DomainDelegate do
  describe ".domain_delegate" do
    describe User do
      let!(:user) { build(:user, name: "cat") }
      describe "#register" do
        it "Usable register method" do
          result = user.register

          expect(result).to eq "Register!"
        end
      end

      describe "#purchase" do
        it "Usable purchase method" do
          result = user.purchase

          expect(result).to eq "Purchase cat!"
        end
      end

      describe "#hit" do
        it "Usable hit method" do
          result = user.hit("mksava")

          expect(result).to eq "Hit mksava!"
        end
      end

      describe "#clear_to" do
        it "Usable clear_to method" do
          result = user.clear_to(target: "boku")

          expect(result).to eq "Clear boku!"
        end
      end

      describe "#clear_hello" do
        it "Usable clear_hello method" do
          result = user.clear_hello

          expect(result).to eq "hello clear"
        end
      end

      describe "#clear_spec1" do
        it "Usable clear_spec1 method" do
          result = user.clear_spec1("wan")

          expect(result).to eq "spec1 wan"
        end
      end

      describe "#clear_spec2" do
        it "Usable clear_spec2 method" do
          result = user.clear_spec2(arg: "nyan")

          expect(result).to eq "spec2 nyan"
        end
      end
    end
  end

  describe ".class_domain_delegate" do
    describe User do
      describe ".fire" do
        it "Usable fire class method" do
          result = User.fire

          expect(result).to eq "fire"
        end
      end

      describe ".import_csv" do
        it "Usable import_csv class method" do
          result = User.import_csv("a,b,c", format: :simple)

          expect(result).to eq "csv_string: a,b,c. format: simple."
        end
      end

      describe ".age_destroy" do
        it "Usable age_destroy class method" do
          result = User.age_destroy

          expect(result).to eq "destroy age"
        end
      end

      describe ".age_create" do
        it "Usable age_create class method" do
          result = User.age_create

          expect(result).to eq "create age"
        end
      end
    end
  end

  describe Master::Plan do
    let!(:master_plan) { build(:master_plan, id: 10) }
    describe "#register" do
      subject { master_plan.register }
      it { is_expected.to eq "10だよ" }
    end
  end
end