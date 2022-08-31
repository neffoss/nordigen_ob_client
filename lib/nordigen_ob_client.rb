require 'json'
require 'net/http'
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
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/institutions/?country=#{country}",
      headers=request_header)

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
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/requisitions/#{requisition_id}",
      headers=request_header)
    accounts = JSON.parse(response.body)
    accounts
  end

  def get_account_details account_id
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/details",
      headers=request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  def get_account_balances account_id
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/balances",
      headers=request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  def get_account_overview account_id
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}",
      headers=request_header)
    accounts = JSON.parse(response.body)
    accounts
  end


  def get_account_transactions account_id
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.get(
      "https://ob.nordigen.com/api/v2/accounts/#{account_id}/transactions",
      headers=request_header)
    accounts = JSON.parse(response.body)
    accounts
  end



  def create_requisition redirect_url, selected_bank_id, reference
    request_body = {
                    "redirect" => redirect_url,
                    "institution_id" => selected_bank_id,
                    "user_language" => "EN",
                    "reference" => reference
    }.to_json

    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.post(
      "https://ob.nordigen.com/api/v2/requisitions/",
      request_body,
      headers=request_header)
    JSON.parse(response.body)
  end


  def delete_requisition requisition_id
    request_header = {
      content_type: :json,
      accept: :json,
      authorization: "Bearer #{@access_token}"
    }

    response = RestClient.delete(
      "https://ob.nordigen.com/api/v2/requisitions/#{requisition_id}",
      request_body,
      headers=request_header)
    JSON.parse(response.body)
    response
  end

end
