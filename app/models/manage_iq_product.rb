# == Schema Information
#
# Table name: manage_iq_products
#
#  id                 :integer          not null, primary key
#  created_at         :datetime
#  updated_at         :datetime
#  service_type_id    :integer
#  service_catalog_id :integer
#  cloud_id           :integer
#  chef_role          :string(100)
#  options            :text
#

class ManageIqProduct < ActiveRecord::Base
  has_many :products, as: :provisionable

  def provision
  end
end
