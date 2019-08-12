# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $student_id = ""
  initializeDatatable = (standard) ->
    $("#dttb").DataTable({
      destroy: true,
      'ajax': '/'+locale+'/students?standard_id='+ standard,
      "columnDefs": [{
        "targets": 5,
        render: (data, type, full, meta) -> 
          '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link show-button btn btn-sm btn-show btn-space"><i class="fa fa-eye" id='+data+' ></i></button>' +
          '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link edit-button edit-btn btn btn-sm btn-space"><i class="fa fa-edit" id='+data+' ></i></button>' +
          '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link btn btn-sm delete-button btn-danger"><i class="fa fa-trash" id='+data+' ></i></button>'
          
      }]
      'ajax': '/'+locale+'/students?standard_id='+ standard,
    });

  initializeDatatable(document.getElementById('standard').value)
  $('.standard-select').on 'change', (e) ->
    initializeDatatable(e.target.value)
    return
  $('#dttb').on 'click', '.edit-button', (e) ->
      $student_id = e.target.id
      window.location = '/'+locale+'/students/'+$student_id+'/edit';
      return false;

  $('#dttb').on 'click', '.show-button', (e) ->
      $student_id = e.target.id
      window.location = '/'+locale+'/students/'+$student_id;
      return false;

  $('#dttb').on 'click', '.delete-button', (e) ->
    $student_id = e.target.id
    $(".bd-example-modal-sm").modal('show');

  $('.delete-student').on 'click', (e) ->
    $.ajax '/'+locale+'/students/'+$student_id,
      type: 'DELETE'
      error: (jqXHR, textStatus, errorThrown) ->
      success: (data, textStatus, jqXHR) ->
        $(".bd-example-modal-sm").modal('hide');
      document.location.reload()
      $student_id = ""

