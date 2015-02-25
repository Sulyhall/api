require 'rails_helper'

RSpec.describe ProvisionWorker do
  it 'provisions cloud instances using manage iq' do
    client = get_client
    order_item = get_order_item
    provision_worker = setup_provision_worker_spec(order_item, client)

    provision_worker.perform
    order_item.reload

    expect(client).to have_received(:post)
    expect(order_item.provision_status).to eq "pending"
    expect(order_item.reply_from_provisioning_payload).to eq({
      "results" => "good job"
    })
    expect(order_item.begin_provisioning_payload).to be_present
  end

  it "sets the status to critical when a response between 400 and 407 happens" do
    client = get_client
    order_item = get_order_item
    provision_worker = setup_provision_worker_spec(order_item, client)

    provision_worker.perform
    order_item.reload

    expect(order_item.provision_status).to eq "critical"
  end

  it "sets the status to warning when a response other than 200s or 400 to 407 happens" do
    client = get_client
    order_item = get_order_item
    provision_worker = setup_provision_worker_spec(order_item, client)

    provision_worker.perform
    order_item.reload

    expect(order_item.provision_status).to eq "warning"
  end

  def get_order_item
    create(:order_item, uuid: "61810e22-f212-4429-a1ca-f1aae51904a0")
  end

  def get_client
    post_response = double('response', body: '{"results": "good job"}', code: 500)
    client = double('client', post: post_response)
  end

  def setup_provision_worker_spec(order_item, client)
    create(:setting, hid: 'aws')
    create(:staff, email: 'test@example.com')
    create(
      :setting,
      hid: 'manageiq',
      setting_fields: [
        build(:setting_field, hid: 'enabled', value: true),
        build(:setting_field, hid: 'email', value: 'test@example.com'),
      ]
    )

    allow(RestClient::Resource).to receive(:new) do
      double('rest client', :[] => client)
    end

    ProvisionWorker.new(order_item)
  end
end
