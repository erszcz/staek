defmodule StaekWeb.GroupHTML do
  use StaekWeb, :html

  embed_templates "group_html/*"

  @doc """
  Renders a group form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def group_form(assigns)
end
