RSpec.describe SaveTemplateService do
  let(:user) { create :user }

  context 'create' do
    context 'when params are valid' do
      let(:valid_params) do
        {
          title: 'template1',
          config: {
            fields: [
              { title: 'Email', input_type: 'email', order: 1, name: 'email' },
              { title: 'Password', input_type: 'password', order: 2, name: 'password' }
            ]
          }
        }
      end

      it 'creates new template' do
        res = {}
        expect { res = described_class.new(user: user, params: valid_params).call }.
          to change { Template.count }.by(1).
          and change { user.templates.count }.by(1)

        expect(res.result[:template].title).to eq 'template1'
        expect(res.result[:template].config['fields'][0]['title']).to eq 'Email'
        expect(res.valid?).to be_truthy
      end
    end

    context 'when config is invalid' do
      let(:invalid_params) do
        {
          title: 'template1',
          config: { fields: [] }
        }
      end

      it 'returns corresponding error message' do
        res = {}
        expect { res = described_class.new(user: user, params: invalid_params).call }.
          to change { Template.count }.by(0).
          and change { user.templates.count }.by(0)
        expect(res.errors.count).to eq 1
        expect(res.errors.full_messages.to_sentence).to eq 'Template\'s config is invalid'
        expect(res.valid?).to be_falsey
      end
    end

    context 'when arguments are empty' do
      it 'returns corresponding error' do
        res = described_class.new(user: nil, params: nil).call
        expect(res.errors.full_messages.to_sentence).to eq 'Parameters are invalid'
      end
    end
  end

  context 'update' do
    context 'when parameters are valid' do
      let(:template) { create(:template, user: user) }
      let(:valid_params) do
        {
          user: user,
          template_id: template.id,
          params: {
            title: 'template2',
            config: {
              fields: [{ title: 'Email', input_type: 'email', order: 1, name: 'email' }]
            }
          }
        }
      end

      it 'updates user\'s template' do
        res = {}

        expect { res = described_class.new(valid_params).call }.
          to change { template.reload.config['fields'].count }.by(-1).
          and change { template.reload.title }.to('template2')

        expect(res.valid?).to be_truthy
      end
    end
  end
end
