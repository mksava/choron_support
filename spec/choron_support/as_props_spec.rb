RSpec.describe ChoronSupport::AsProps do
  describe User do
    let!(:user) { build(:user, id: 10, name: "cat", email: "mail@example.com") }
    describe "#as_props" do
      context "(when no symbol)" do
        it do
          props = user.as_props
          expect(props).to eq({ id: 10, name: "cat", email: "mail@example.com" })
        end
      end

      context "(when given :compare symbol)" do
        context "(when no args)" do
          it do
            props = user.as_props(:compare)
            expect(props).to eq({ userId: 10, compareSpec: "compare" })
          end
        end

        context "(when { camel: true })" do
          it do
            props = user.as_props(:compare, camel: true)
            expect(props).to eq({ userId: 10, compareSpec: "compare" })
          end
        end

        context "(when { camel: false })" do
          it do
            props = user.as_props(:compare, camel: false)
            expect(props).to eq({ user_id: 10, compare_spec: "compare" })
          end
        end
      end
    end
  end

  describe ActiveRecord::Relation do
    before do
      create(:user, id: 1, name: "cat", email: "mail1@example.com")
      create(:user, id: 2, name: "dog", email: "mail2@example.com")
    end
    describe "#as_props" do
      context "(when no symbol)" do
        it do
          props = User.all.as_props
          expect(props.size).to eq 2
          expect(props[0]).to eq({ id: 1, name: "cat", email: "mail1@example.com" })
          expect(props[1]).to eq({ id: 2, name: "dog", email: "mail2@example.com" })
        end
      end

      context "(when given :compare symbol)" do
        context "(when no args)" do
          it do
            props = User.all.as_props(:compare)
            expect(props.size).to eq 2
            expect(props[0]).to eq({ userId: 1, compareSpec: "compare" })
            expect(props[1]).to eq({ userId: 2, compareSpec: "compare" })
          end
        end

        context "(when { camel: true })" do
          it do
            props = User.all.as_props(:compare)
            expect(props.size).to eq 2
            expect(props[0]).to eq({ userId: 1, compareSpec: "compare" })
            expect(props[1]).to eq({ userId: 2, compareSpec: "compare" })
          end
        end

        context "(when { camel: false })" do
          it do
            props = User.all.as_props(:compare, camel: false)
            expect(props.size).to eq 2
            expect(props[0]).to eq({ user_id: 1, compare_spec: "compare" })
            expect(props[1]).to eq({ user_id: 2, compare_spec: "compare" })
          end
        end
      end
    end
  end
end