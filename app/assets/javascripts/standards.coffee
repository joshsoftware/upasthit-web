# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
  $('.standard-select').select2({
    dropdownAutoWidth: 'true',
    width: '100%'
  })
$('#standard_table').on 'click', '.delete-button', (e) ->
  $student_id = e.target.id
  $(".bd-example-modal-sm").modal('show');