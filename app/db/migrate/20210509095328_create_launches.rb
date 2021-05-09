class CreateLaunches < ActiveRecord::Migration[6.1]
  def change
    create_table :launches, id: :string do |t|
      t.string :name
      t.datetime :time
      t.string :youtube_id
      t.string :wikipedia
      t.string :patch
    end
  end
end
