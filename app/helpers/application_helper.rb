# frozen_string_literal: true

module ApplicationHelper
  def flash_class(type)
    {
      notice: 'alert alrert-info',
      success: 'alert alert-success',
      error: 'alert alert-danger',
      alert: 'alert alert-warning',
      default: 'alert alert-info'
    }[type.to_sym] || type.to_s
  end
end
