defmodule Staek.ExpensesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Staek.Expenses` context.
  """

  @doc """
  Generate a group.
  """
  def group_fixture(attrs \\ %{}) do
    {:ok, group} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Staek.Expenses.create_group()

    group
  end

  @doc """
  Generate a expense.
  """
  def expense_fixture(attrs \\ %{}) do
    {:ok, expense} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Staek.Expenses.create_expense()

    expense
  end

  @doc """
  Generate a credit.
  """
  def credit_fixture(attrs \\ %{}) do
    {:ok, credit} =
      attrs
      |> Enum.into(%{
        amount: "120.5"
      })
      |> Staek.Expenses.create_credit()

    credit
  end

  @doc """
  Generate a debit.
  """
  def debit_fixture(attrs \\ %{}) do
    {:ok, debit} =
      attrs
      |> Enum.into(%{
        amount: "120.5"
      })
      |> Staek.Expenses.create_debit()

    debit
  end
end
