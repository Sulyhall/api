class AdjustProductColumns < ActiveRecord::Migration
  class Product < ActiveRecord::Base
  end

  class ManageIqProduct < ActiveRecord::Base
  end

  def up
    add_column :products, :provisionable_type, :string
    add_column :products, :provisionable_id, :integer
    add_index :products, :provisionable_id

    create_table :manage_iq_products do |t|
      t.timestamps
      t.integer :service_type_id
      t.integer :service_catalog_id
      t.integer :cloud_id
      t.string :chef_role, limit: 100
      t.text :options
    end

    create_table :team_member_products do |t|
      t.timestamps
    end

    Product.reset_column_information
    ManageIqProduct.reset_column_information
    Product.all.each do |product|
      manage_iq_product = ManageIqProduct.create(
        service_type_id: product.service_type_id,
        service_catalog_id: product.service_catalog_id,
        cloud_id: product.cloud_id,
        chef_role: product.chef_role,
        options: product.options.to_json
      )

      product.provisionable_id = manage_iq_product.id
      product.provisionable_type = "ManageIqProduct"
      product.save!
    end

    rename_column :products, :service_type_id, :deprecated_service_type_id
    rename_column :products, :service_catalog_id, :deprecated_service_catalog_id
    rename_column :products, :cloud_id, :deprecated_cloud_id
    rename_column :products, :chef_role, :deprecated_chef_role
    rename_column :products, :options, :deprecated_options

    rename_column :order_items, :payload_to_miq, :begin_provisioning_payload
    rename_column :order_items, :payload_reply_from_miq, :reply_from_provisioning_payload
    rename_column :order_items, :payload_response_from_miq, :response_provisioning_payload
  end

  def down
    remove_column :products, :provisionable_type
    remove_column :products, :provisionable_id

    drop_table :manage_iq_products
    drop_table :team_member_products

    rename_column :products, :deprecated_service_type_id, :service_type_id
    rename_column :products, :deprecated_service_catalog_id, :service_catalog_id
    rename_column :products, :deprecated_cloud_id, :cloud_id
    rename_column :products, :deprecated_chef_role, :chef_role
    rename_column :products, :deprecated_options, :options

    rename_column :order_items, :begin_provisioning_payload, :payload_to_miq
    rename_column :order_items, :reply_from_provisioning_payload, :payload_reply_from_miq
    rename_column :order_items, :response_provisioning_payload, :payload_response_from_miq
  end
end
