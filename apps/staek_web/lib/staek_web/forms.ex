defmodule StaekWeb.Forms do
  @moduledoc ~S"""
  Helpers for dealing with Web forms.
  """

  @doc ~S"""
  Clean up `params` returned by a multiple choice form field, i.e. remove the empty string value
  and update `params` to contain a possibly empty list of values.
  """
  def cleanup_params_array(params, array_field) do
    Map.put(params, array_field, (params[array_field] || []) -- [""])
  end
end
