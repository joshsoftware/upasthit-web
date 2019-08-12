# frozen_string_literal: true

# Responsible for importing item master vessel tags
module Import
  class Students
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
      @student_data = @data.collect.with_index do |data, index|
        data[:preferred_language] = LOCALES.invert[(data[:preferred_language]).to_s]
        data[:gender] = GENDER.invert[(data[:gender]).to_s]
        if data[:guardian_mobile_no] !~ /^[6-9]\d{9}$/ || data[:guardian_alternate_mobile_no] !~ /^[6-9]\d{9}$/
          errors.add(:base, "#{index}": "Mobile no. format not correct, line no: #{index + 1}")

        else
          standard = Standard.find_by(standard: data[:standard], section: data[:section])
          data = data.merge(standard_id: standard&.id, school_id: school_id).except(:standard, :section)
          Student.new(data)
        end
      end
      errors.blank?
    end

    def import_records
      result = Student.bulk_import!(@student_data, recursive: true, validate_uniqueness: true)
      @result = {records_added: result.ids.count}
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
      errors.add(:base, "1": "Duplicate registration_no found, assign new registration_no")
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
      %i[registration_no roll_no first_name_en
         gender dob address guardian_name guardian_mobile_no
         guardian_alternate_mobile_no preferred_language]
    end

    def required_fields
      %i[registration_no roll_no first_name_en first_name_mr_in
         gender dob address guardian_name guardian_mobile_no
         guardian_alternate_mobile_no preferred_language]
    end

    def key_mapping
      {
        :reg_no                            => :registration_no,
        :first_name_english                => :first_name_en,
        :first_name_marathi                => :first_name_mr_in,
        :last_name_english                 => :last_name_en,
        :last_name_marathi                 => :last_name_mr_in,
        :mobile_number_1                   => :guardian_mobile_no,
        :mobile_number_2                   => :guardian_alternate_mobile_no,
        "date_of_birth(dd/mm/yyyy)".to_sym => :dob
      }
    end
  end
end
