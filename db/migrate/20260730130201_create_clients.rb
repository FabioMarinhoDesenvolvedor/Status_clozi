class CreateClients < ActiveRecord::Migration[8.1]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :approval_status, null: false, default: "sem_posts"
      t.string :approval_detail
      t.date :released_until
      t.date :scheduled_until
      t.text :notes

      t.timestamps
    end

    add_index :clients, :released_until
  end
end
