# frozen_string_literal: true

Band = Struct.new(:id, :name) do
  def [](*attrs)
    attrs.collect { |attr| send(attr) }
  end
end
