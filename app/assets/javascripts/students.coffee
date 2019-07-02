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
          '<button type=button style=border:1px solid black; background-color: transparent; class="icon-link delete-button">
            <i class="fa fa-trash" id='+data+' ></i>
          </button>'
      }]
      'ajax': '/'+locale+'/students?standard_id='+ standard,
    });

  initializeDatatable("")
  $('.standard-select').on 'change', (e) ->
    initializeDatatable(e.target.value)
    return

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

