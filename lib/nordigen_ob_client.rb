require 'json'
require 'rest-client'

class NordigenOBClient

  def initialize
  end

  #############################################################################
  #
  # => Name: get_access_token
  #
  # => Description: Retrieve the access token that will be used to access all
  #                 other endpoints in Nordigen's backend.
  #
  # => Parameters: secret_id: The Secret ID part of the credentials,
  #                           provided by Nordigen.
  #
  #                secret_key: The Secret Key part of the credentials,
  #                            provided by Nordigen.
  #
  # => Returns: The access token
  #
  #############################################################################
  def get_access_token secret_id, secret_key
    access_token_params = {
      "secret_id" => secret_id,
      "secret_key" => secret_key
    }.to_json

    response_json = RestClient.post("https://ob.nordigen.com/api/v2/token/new/",
                                    access_token_params,
                                    {content_type: :json, accept: :json})
    response = JSON.parse(response_json.body)
    @access_token = response["access"]

    @request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    @access_token
  end

  #############################################################################
  #
  # => Name: get_banks_by_country
  #
  # => Description: Returns a list of the available institutions by country,
  #                 including
  #
  # => Parameters: country: The selected country, in ISO 3166 format.
  #                         Supported countries are EEA countries.
  #
  #
  # => Returns: The list of supported institutions in the selected country.
  #
  #############################################################################
  def get_banks_by_country country
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/institutions/?country=#{country}",
      headers=@request_header)

    available_banks = JSON.parse(response.body,
                                :external_encoding => 'iso-8859-1')
    available_banks
  end


  #############################################################################
  #
  # => Name: list_accounts
  #
  # => Description: Return a list of the available accounts connected to the
  #                 given user account.
  #
  # => Parameters: requisition_id: The id of the requisition (bank login)
  #                for which the parameters will be parsed.
  #
  #
  # => Returns: The list of available accounts.
  #
  #############################################################################
  def list_accounts requisition_id
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/requisitions/#{requisition_id}",
      headers=@request_header)
    accounts = JSON.parse(response.body)
    accounts
  end

  #############################################################################
  #
  # => Name: get_account_details
  #
  # => Description: Return's all the information available for the account.
  #
  # => Parameters: account_id: The id of the account (IBAN)
  #                for which the information will be returned.
  #
  #
  # => Returns: The details available for the account. They can vary from bank
  #             to bank. The fields we see been returned always are:
  #               - IBAN
  #               - Currency
  #               - Owner Name
  #               - Product / account type (e.g. Savings, holding, etc.)
  #               - BIC
  #               - Usage: Private / Bureau
  #
  #############################################################################
  def get_account_details account_id
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/details",
      headers=@request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  #############################################################################
  #
  # => Name: get_account_balances
  #
  # => Description: Return's the balances for the given account. The balances
  #                 can be more than one, since accounts allow overdraft or
  #                 might have frozen limits.
  #
  # => Parameters: account_id: The id of the account (IBAN)
  #                for which the balances will be returned.
  #
  #
  # => Returns: The details available for the account. They can vary from bank
  #             to bank. The fields we see been returned always are:
  #               - Balance amount
  #               - Currency
  #               - Type of balances
  #               - Balance date
  #
  #############################################################################
  def get_account_balances account_id
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/balances",
      headers=@request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  #############################################################################
  #
  # => Name: get_account_overview
  #
  # => Description: Return's the basic information available for the account.
  #
  # => Parameters: account_id: The id of the account (IBAN)
  #                for which the information will be returned.
  #
  #
  # => Returns: A summaru available for the account. THe fields included are:
  #               - IBAN
  #               - Nordigen's institution ID
  #               - Status: ready, inactive
  #               - Owner's name
  #
  #############################################################################
  def get_account_overview account_id
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}",
      headers=@request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  #############################################################################
  #
  # => Name: get_account_transactions
  #
  # => Description: Return's the account statement for the last 90 days.
  #
  # => Parameters: account_id: The id of the account (IBAN)
  #                for which the information will be returned.
  #
  #
  # => Returns: The list of transactions performed. THe fields included are:
  #               - Booking date, when the transaction was logged on the account.
  #               - Reference date, when it actually occured.
  #               - Transaction amount
  #               - Currency
  #               - Debitor BIC
  #               - Creditor BIC
  #
  #############################################################################
  def get_account_transactions account_id
    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/transactions",
      headers=@request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  #############################################################################
  #
  # => Name: create_requisition
  #
  # => Description: It creates a new requisition ID that will enable the user
  #                 to connect his bank accounts.
  #
  # => Parameters: redirect_url: The URL to which the user will be redirected
  #                after logging in to his bank environment.
  #
  #                selected_bank_id: The Nordigen ID of the bank the user
  #                will be redirected.
  #
  #                reference: A unique user identifier that will associate
  #                the user who will log in with the new requisition ID.
  #
  # => Returns: The access token
  #
  #############################################################################
  def create_requisition redirect_url, selected_bank_id, reference
    request_body = {
                    "redirect" => redirect_url,
                    "institution_id" => selected_bank_id,
                    "user_language" => "EN",
                    "reference" => reference
    }.to_json

    response = RestClient.post(
      "https://ob.nordigen.com/api/v2/requisitions/",
      request_body,
      headers=@request_header)
    JSON.parse(response.body)
  end


  #############################################################################
  #
  # => Name: delete_requisition
  #
  # => Description: It deletes the provided requisition ID.
  #
  # => Parameters: requisition_id: The requisition to delete.
  #
  # => Returns: The result of the operation
  #
  #############################################################################
  def delete_requisition requisition_id
    response = RestClient.delete(
      "https://ob.nordigen.com/api/v2/requisitions/#{requisition_id}/",
      headers=@request_header)
    JSON.parse(response.body)
    response
  end

end
