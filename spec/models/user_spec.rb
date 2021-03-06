# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  name                   :string
#  affiliation            :string
#  user_type              :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  admin                  :boolean          default(FALSE)
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

describe User do
  let(:user) { create(:user) }

  it 'can be created' do
    expect(User.exists?(user.id)).to be true
  end

  it 'must have an e-mail address' do
    expect {
      create(:user, email: '')
    }.to raise_error ActiveRecord::RecordInvalid
  end

  it 'can author changesets' do
    changeset = create(:changeset, user: user)
    expect(changeset.user).to eq user
  end
end
