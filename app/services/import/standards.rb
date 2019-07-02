# Responsible for importing item master vessel tags
class Import::Standards
  include ActiveModel::Validations
  attr_reader :result, :file_path, :school_id

  def initialize(file_path, school_id)
    @file_path = file_path
    @school_id = school_id
  end

  def call
    process_file &&
      prepare_data &&
      import_records
  end

  private

  def process_file
    @data = SmarterCSV.process(file_path, options)
    if SmarterCSV.errors.present?
      errors.add(:base, SmarterCSV.errors)
      return false
    end
    true
  end

  def prepare_data
    @standard_data = @data.collect do |data|
      data[:sections].split(',').collect do |section|
        Standard.new({standard: data[:standard], section: section,
                    school_id: school_id, start_time: data[:start_time]})
      end
    end.flatten
  end

  def import_records
    result = Standard.bulk_import!(@standard_data, recursive: true, validate_uniqueness: true)
    @result = { records_added: result.ids.count }
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    errors.add(:base, {"1": "Duplicate Standard record found"})
    false
  end

  def options
    {
      header_transformations: [key_mapping: key_mapping],
      header_validations: [required_headers: required_headers],
      hash_validations: [required_fields: required_fields]
    }
  end

  def required_headers
    [:standard, :sections]
  end

  def required_fields
    [:standard, :sections, :start_time]
  end

  def key_mapping
    {
      "start_time_(24_hour_format)": :start_time
    }
  end

end
