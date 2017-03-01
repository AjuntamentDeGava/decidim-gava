# frozen_string_literal: true
# Checks the authorization against the census for Barcelona.
require "digest/md5"

# This class performs a check against the official census database in order
# to verify the citizen's residence.
class CensusAuthorizationHandler < Decidim::AuthorizationHandler
  include ActionView::Helpers::SanitizeHelper

  attribute :document_number, String
  validates :document_number, format: { with: /\A[A-z0-9]*\z/ }, presence: true

  validate :registered_in_town
  validate :district_is_blank_or_over_16

  def self.from_params(params, additional_params = {})
    instance = super(params, additional_params)

    params_hash = hash_from(params)

    if params_hash["date_of_birth(1i)"]
      date = Date.civil(
        params["date_of_birth(1i)"].to_i,
        params["date_of_birth(2i)"].to_i,
        params["date_of_birth(3i)"].to_i
      )

      instance.date_of_birth = date
    end

    instance
  end

  # If you need to store any of the defined attributes in the authorization you
  # can do it here.
  #
  # You must return a Hash that will be serialized to the authorization when
  # it's created, and available though authorization.metadata
  def metadata
    #super.merge(postal_code: postal_code, scope: scope.name)
  end

  def scope
    Decidim::Scope.find(scope_id)
  end

  def census_document_types
    %i(dni nie passport).map do |type|
      [I18n.t(type, scope: "decidim.census_authorization_handler.document_types"), type]
    end
  end

  def unique_id
    Digest::MD5.hexdigest(
      "#{document_number}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  private

  def document_type_valid
    return nil if response.blank?

    #errors.add(:document_number, I18n.t("census_authorization_handler.invalid_document")) unless response.xpath("//codiRetorn").text == "01"
  end

  def registered_in_town
    return nil if response.blank?
    errors.add(:base, 'No empadronat') unless first_person_element.present? && first_person_element.text != ""
  end

  def first_person_element
    response.xpath('//ssagavaVigents').first
  end

  def first_district_element
    response.xpath('//ssagavaVigents//ssagavaVigent//barri').first
  end

  def first_age_element
    response.xpath('//ssagavaVigents//ssagavaVigent//edat').first
  end

  def district_is_blank_or_over_16
    return nil if response.blank?
    return nil if errors.any? # Don't need to check anything if there are errors already
    errors.add(:base, 'Menor de 16 anys') unless first_district_element.present? && first_district_element.text == "-" || first_age_element.present? && first_age_element.text.to_i > 15
  end

  def response
    return nil if document_number.blank?

    return @response if defined?(@response)

    response ||= Faraday.new(:url => Rails.application.secrets.census_url).get do |request|
      request.url('findEmpadronat', dni: document_number)
    end

    @response ||= Nokogiri::XML(response.body).remove_namespaces!
  end

end
