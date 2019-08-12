# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $staff_id = ""
  $("#staffdt").DataTable({
    'ajax': '/'+locale+'/staffs',
    "columnDefs": [{
      "targets": 4,
      render: (data, type, full, meta) -> 
        '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link show-button btn btn-sm btn-show btn-space"><i class="fa fa-eye" id='+data+' ></i></button>' +
        '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link edit-button edit-btn btn btn-sm btn-space"><i class="fa fa-edit" id='+data+' ></i></button>' +
        '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link delete-button btn btn-sm btn-danger"><i class="fa fa-trash" id='+data+' ></i></button>'
    }]
  });
  $('#staffdt').on 'click', '.edit-button', (e) ->
      $staff_id = e.target.id
      window.location = '/'+locale+'/staffs/'+$staff_id+'/edit';
      return false;
  $('#staffdt').on 'click', '.show-button', (e) ->
      $staff_id = e.target.id
      window.location = '/'+locale+'/staffs/'+$staff_id;
      return false;

  $('#staffdt').on 'click', '.delete-button', (e) ->
    $staff_id = e.target.id
    $(".bd-example-modal-sm").modal('show');

  $('.delete-staff').on 'click', (e) ->
    $.ajax '/'+locale+'/staffs/'+$staff_id,
      type: 'DELETE'
      error: (jqXHR, textStatus, errorThrown) ->
      success: (data, textStatus, jqXHR) ->
        $(".bd-example-modal-sm").modal('hide');
      document.location.reload()
      $staff_id = ""


