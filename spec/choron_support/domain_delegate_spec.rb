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