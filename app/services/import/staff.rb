# frozen_string_literal: true

# Responsible for importing item master vessel tags
module Import
  class Staff
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
      @staff_data = @data.collect.with_index do |data, index|
        if data[:mobile_number] !~ /^[6-9]\d{9}$/
          errors.add(:base, "#{index}": "Mobile no. format not correct, line no: #{index + 1}")
        else
          standard_id = Standard.find_by(standard: data[:standard], section: data[:section]).id
          Staff.new(data.merge(school_id: school_id, password: "12345678", standard_ids: [standard_id]))
        end
      end
      errors.blank?
    end

    def import_records
      result = Staff.bulk_import!(@staff_data, recursive: true, validate_uniqueness: true)
      @result = {records_added: result.ids.count}
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      errors.add(:base, "1": "Duplicate mobile_number OR registration_no found")
      false
    end

    def options
      {
        header_transformations: [key_mapping: key_mapping],
        header_validations:     [required_headers: required_headers],
        hash_validations:       [required_fields: required_fields]
      }
    end

    def required_headers
      %i[registration_no mobile_number first_name designation]
    end

    def required_fields
      %i[registration_no mobile_number first_name designation]
    end

    def key_mapping
      {
        reg_no:     :registration_no,
        mobile:     :mobile_number,
        first_name: :first_name,
        last_name:  :last_name
      }
    end
  end
end
