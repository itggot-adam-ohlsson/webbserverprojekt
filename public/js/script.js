$('document').ready(function() {
  let is_chkd = false;
  for (let chkbx of $(".checkbox-seat")) {
    if (chkbx.checked) is_chkd = true;

    if (is_chkd == true) {
      $(this.find(".checkbox")).addClass("checkbox-checked");
    }
    else {
      $(".checkbox").removeClass("checkbox-checked");
    }
  }
});
