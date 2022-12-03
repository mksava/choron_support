# frozen_string_literal: true

RSpec.describe ChoronSupport do
  describe "#using" do
    context "(Unit Pattern)" do
      where(:using_name) { [:domains, :queries, :forms, :props, :all] }
      with_them do
        it { expect { ChoronSupport.using(using_name) }.not_to raise_error }
      end
    end

    context "(Multi Pattern)" do
      where(using_names:
        [
          [:domains, :queries],
          [:forms, :props],
          [:domains, :queries, :forms, :props],
        ]
      )
      with_them do
        it { expect { ChoronSupport.using(*using_names) }.not_to raise_error }
      end
    end

    context "(Not Exist Pattern)" do
      with_them do
        it { expect { ChoronSupport.using(:invalid_foo) }.to raise_error(ArgumentError) }
      end
    end
  end
end
